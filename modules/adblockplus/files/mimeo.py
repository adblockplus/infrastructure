#!/usr/bin/env python3

import argparse
import re
import sys
import threading
import traceback

from http.server import BaseHTTPRequestHandler, HTTPServer
from string import Template

# The token used for the headers passed by nginx is: http_
REGEX = r'\$http_\w+\b'
DEFAULT_LOG = '$remote_addr - - [$time_local] "$request" $status $bytes_sent'
_lock = threading.Lock()


class Handler(BaseHTTPRequestHandler):
    def get_header_values(self):
        values = {}
        headers = re.findall(REGEX, self.format)
        for name in headers:
            new_var = name[6:].replace('_', '-')
            values[name[1:]] = self.headers.get(new_var, '-')
        return values

    def send_simple_response(self, status, response=None):
        self.send_response(status)
        self.end_headers()
        if response is None:
            response = bytes(self.responses[status][0], 'UTF-8')
        self.wfile.write(response)

    def write_info(self, args):
        message = Template(self.format).safe_substitute(args) + '\n'
        with _lock:
            self.output.write(message)
            self.output.flush()

    def do_POST(self):
        status = 200
        content = bytes(self.response, 'UTF-8')
        values = {
            'remote_addr': self.address_string(),
            'time_local': self.log_date_time_string(),
            'request': self.requestline,
            'status': status,
            'bytes_sent': len(content),
        }
        values.update(self.get_header_values())
        try:
            self.write_info(values)
            self.send_simple_response(status, content)
        except:
            traceback.print_exc(file=sys.stderr)
            self.send_simple_response(500)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', action='store',
                        default=8000, type=int,
                        nargs='?',
                        help='Port to use [default: 8000]')
    parser.add_argument('--response', action='store',
                        type=str, nargs='?', default='OK',
                        help='The response send to the client')
    parser.add_argument('--format', action='store',
                        type=str, nargs='?',
                        default=DEFAULT_LOG,
                        help='Format of the log ouput')
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
        Handler.format = args.format
        Handler.response = args.response
        server_address = ('', args.port)
        httpd = HTTPServer(server_address, Handler)
        httpd.serve_forever()
    finally:
        fh.close()
