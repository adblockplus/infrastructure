#!/usr/bin/env python

from ConfigParser import SafeConfigParser
import hashlib
import hmac
import json
import os
import re
import sys
import urllib

OAUTH2_AUTHURL = 'https://accounts.google.com/o/oauth2/auth'
OAUTH2_TOKENURL = 'https://accounts.google.com/o/oauth2/token'
OAUTH2_DATAURL = 'https://www.googleapis.com/plus/v1/people/me'
OAUTH2_SCOPE = 'email'

OAUTH2_TOKEN_EXPIRATION = 5 * 60

def setup_paths(engine_dir):
  sys.path.append(engine_dir)

  import wrapper_util
  paths = wrapper_util.Paths(engine_dir)
  script_name = os.path.basename(__file__)
  sys.path[0:0] = paths.script_paths(script_name)
  return script_name, paths.script_file(script_name)

def adjust_server_id():
  from google.appengine.tools.devappserver2 import http_runtime_constants
  http_runtime_constants.SERVER_SOFTWARE = 'Production/2.0'

def fix_request_scheme():
  from google.appengine.runtime.wsgi import WsgiRequest
  orig_init = WsgiRequest.__init__
  def __init__(self, *args):
    orig_init(self, *args)
    self._environ['wsgi.url_scheme'] = self._environ.get('HTTP_X_FORWARDED_PROTO', 'http')
    self._environ['HTTPS'] = 'on' if self._environ['wsgi.url_scheme'] == 'https' else 'off'
  WsgiRequest.__init__ = __init__

def read_config(path):
  config = SafeConfigParser()
  config.read(path)
  return config

def set_storage_path(storage_path):
  sys.argv.extend(['--storage_path', storage_path])

def replace_runtime():
  from google.appengine.tools.devappserver2 import python_runtime
  runtime_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '_python_runtime.py')
  python_runtime._RUNTIME_PATH = runtime_path
  python_runtime._RUNTIME_ARGS = [sys.executable, runtime_path]

def protect_cookies(cookie_secret):
  from google.appengine.tools.devappserver2 import login

  def calculate_signature(message):
    return hmac.new(cookie_secret, message, hashlib.sha256).hexdigest()

  def _get_user_info_from_dict(cookie_dict, cookie_name=login._COOKIE_NAME):
    cookie_value = cookie_dict.get(cookie_name, '')

    email, admin, user_id, signature = (cookie_value.split(':') + ['', '', '', ''])[:4]
    if '@' not in email or signature != calculate_signature(':'.join([email, admin, user_id])):
      return '', False, ''
    return email, (admin == 'True'), user_id
  login._get_user_info_from_dict = _get_user_info_from_dict

  orig_create_cookie_data = login._create_cookie_data
  def _create_cookie_data(email, admin):
    result = orig_create_cookie_data(email, admin)
    result += ':' + calculate_signature(result)
    return result
  login._create_cookie_data = _create_cookie_data

def enable_oauth2(client_id, client_secret, admins):
  from google.appengine.tools.devappserver2 import login

  def request(method, url, data):
    if method != 'POST':
      url += '?' + urllib.urlencode(data)
      data = None
    else:
      data = urllib.urlencode(data)
    response = urllib.urlopen(url, data)
    try:
      return json.loads(response.read())
    finally:
      response.close()

  token_cache = {}
  def get_user_info(access_token):
    email, is_admin, expiration = token_cache.get(access_token, (None, None, 0))
    now = time.mktime(time.gmtime())
    if now > expiration:
      get_params = {
        'access_token': access_token,
      }
      data = request('GET', OAUTH2_DATAURL, get_params)
      emails = [e for e in data.get('emails') if e['type'] == 'account']
      if not emails:
        return None, None

      email = emails[0]['value']
      is_admin = email in admins

      for token, (_, _, expiration) in token_cache.items():
        if now > expiration:
          del token_cache[token]
      token_cache[access_token] = (email, is_admin, now + OAUTH2_TOKEN_EXPIRATION)
    return email, is_admin

  def get(self):
    def error(text):
      self.response.status = 200
      self.response.headers['Content-Type'] = 'text/plain'
      self.response.write(text.encode('utf-8'))

    def redirect(url):
      self.response.status = 302
      self.response.status_message = 'Found'
      self.response.headers['Location'] = url.encode('utf-8')

    def logout(continue_url):
      self.response.headers['Set-Cookie'] = login._clear_user_info_cookie()
      redirect(continue_url)

    def login_step1(continue_url):
      # See https://stackoverflow.com/questions/10271110/python-oauth2-login-with-google
      authorize_params = {
        'response_type': 'code',
        'client_id': client_id,
        'redirect_uri': base_url + login.LOGIN_URL_RELATIVE,
        'scope': OAUTH2_SCOPE,
        'state': continue_url,
      }
      redirect(OAUTH2_AUTHURL + '?' + urllib.urlencode(authorize_params))

    def login_step2(code, continue_url):
      token_params = {
        'code': code,
        'client_id': client_id,
        'client_secret': client_secret,
        'redirect_uri': base_url + login.LOGIN_URL_RELATIVE,
        'grant_type':'authorization_code',
      }
      data = request('POST', OAUTH2_TOKENURL, token_params)
      token = data.get('access_token')
      if not token:
        error('No token in response: ' + str(data))
        return

      email, is_admin = get_user_info(token)
      if not email:
        error('No email address in response: ' + str(data))
        return
      self.response.headers['Set-Cookie'] = login._set_user_info_cookie(email, is_admin)
      redirect(continue_url)

    action = self.request.get(login.ACTION_PARAM)
    continue_url = self.request.get(login.CONTINUE_PARAM)
    continue_url = re.sub(r'^http:', 'https:', continue_url)
    base_url = 'https://%s/' % self.request.environ['HTTP_HOST']

    if action.lower() == login.LOGOUT_ACTION.lower():
      logout(continue_url or base_url)
    elif self.request.get('error'):
      error('Authorization failed: ' + self.request.get('error'))
    else:
      code = self.request.get('code')
      if code:
        login_step2(code, self.request.get('state') or base_url)
      else:
        login_step1(continue_url or base_url)

  login.Handler.get = get

  from google.appengine.api import user_service_stub, user_service_pb
  from google.appengine.runtime import apiproxy_errors
  def _Dynamic_GetOAuthUser(self, request, response, request_id):
    environ = self.request_data.get_request_environ(request_id)
    match = re.search(r'^OAuth (\S+)', environ.get('HTTP_AUTHORIZATION', ''))
    if not match:
      raise apiproxy_errors.ApplicationError(
          user_service_pb.UserServiceError.OAUTH_INVALID_REQUEST)

    email, is_admin = get_user_info(match.group(1))
    if not email:
      raise apiproxy_errors.ApplicationError(
          user_service_pb.UserServiceError.OAUTH_INVALID_TOKEN)

    # User ID is based on email address, see appengine.tools.devappserver2.login
    user_id_digest = hashlib.md5(email.lower()).digest()
    user_id = '1' + ''.join(['%02d' % ord(x) for x in user_id_digest])[:20]

    response.set_email(email)
    response.set_user_id(user_id)
    response.set_auth_domain(user_service_stub._DEFAULT_AUTH_DOMAIN)
    response.set_is_admin(is_admin)
    response.set_client_id(client_id)
    response.add_scopes(OAUTH2_SCOPE)

  user_service_stub.UserServiceStub._Dynamic_GetOAuthUser = _Dynamic_GetOAuthUser


if __name__ == '__main__':
  engine_dir = '/opt/google_appengine'
  storage_path = '/var/lib/rietveld'

  script_name, script_file = setup_paths(engine_dir)
  adjust_server_id()
  fix_request_scheme()

  if script_name == 'dev_appserver.py':
    config = read_config(os.path.join(storage_path, 'config.ini'))

    set_storage_path(storage_path)
    replace_runtime()
    protect_cookies(config.get('main', 'cookie_secret'))
    enable_oauth2(
      config.get('oauth2', 'client_id'),
      config.get('oauth2', 'client_secret'),
      config.get('main', 'admins').split()
    )

  execfile(script_file)
