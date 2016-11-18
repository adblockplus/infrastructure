from trac.web.session import Session
orig_get = Session.get
def patched_get(self, key, default=None):
    if key == 'accesskeys':
        return '1'
    return orig_get(self, key, default)
Session.get = patched_get

