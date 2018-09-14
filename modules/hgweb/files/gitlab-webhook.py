#!/usr/bin/env python3

import argparse
import json
import sys
import threading

from http.server import BaseHTTPRequestHandler, HTTPServer
from subprocess import check_call, CalledProcessError
from os import path

_lock = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    git_command = [
        'sudo', '-u', 'hg', 'git', 'pull', '--quiet',
    ]
    hg_command = [
        'sudo', '-u', 'hg', 'hg', 'pull', '--quiet', '--update',
    ]

    def send_simple_response(self, status, response=None):
        self.send_response(status)
        self.end_headers()
        # responses is an attribute that contains mapping of error codes
        # wfile has the output stream for writing a response back to client
        # https://docs.python.org/3/library/http.server.html
        if response is None:
            response = bytes(self.responses[status][0], 'UTF-8')
        self.wfile.write(response)

    def write_info(self, args):
        with _lock:
            self.output.write(str(args))
            self.output.flush()

    def do_POST(self):
        request_body_len = int(self.headers.get('content-length', 0))
        request_body = self.rfile.read(request_body_len).decode('UTF-8')
        json_request_body = json.loads(request_body)
        repository_name = json_request_body['repository']['name']
        URL = json_request_body['repository']['homepage']
        hg_directory = path.join(self.hg_dir, repository_name)
        git_directory = path.join(self.git_dir, repository_name)
        if 'gitlab.com' in URL:
            git_directory = path.join(self.git_dir, 'gitlab', repository_name)
        # GitLab ignores the HTTP status code returned by your endpoint.
        # https://gitlab.com/help/user/project/integrations/webhooks
        try:
            if path.isdir(git_directory) and path.isdir(hg_directory):
                check_call(self.git_command, cwd=git_directory)
                check_call(self.hg_command, cwd=hg_directory)
                self.send_simple_response(202)
            else:
                self.send_simple_response(400)
        except CalledProcessError:
            self.send_simple_response(500)
        finally:
            self.write_info(json_request_body)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', action='store',
                        default=8000, type=int,
                        nargs='?',
                        help='Port to use [default: 8000]')
    parser.add_argument('--address', action='store',
                        type=str, nargs='?',
                        default='127.0.0.1',
                        help='Address to listen on [default: 127.0.0.1]')
    parser.add_argument('--hg-dir', action='store',
                        default='/home/hg/web/', type=str, nargs='?',
                        help='Directory where mercurial repositories live')
    parser.add_argument('--git-dir', action='store',
                        default='/home/hg/import/', type=str, nargs='?',
                        help='Directory where git repositories live')
    parser.add_argument('output', action='store',
                        type=str, nargs='?', default='-',
                        help='The file where the logs will be written')
    args = parser.parse_args()
    if args.output and args.output != '-':
        fh = open(args.output, 'a')
    else:
        fh = open(sys.stdout.fileno(), 'w', closefd=False)
    try:
        Handler.output = fh
        Handler.git_dir = args.git_dir
        Handler.hg_dir = args.hg_dir
        server_address = (args.address, args.port)
        httpd = HTTPServer(server_address, Handler)
        httpd.serve_forever()
    finally:
        fh.close()
