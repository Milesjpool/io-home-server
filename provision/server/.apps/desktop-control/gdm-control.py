#!/usr/bin/env python3
"""Simple HTTP service to control GDM via network requests"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess
import sys

PORT = 8888

class GDMControlHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/start':
            try:
                subprocess.run(['sudo', 'systemctl', 'start', 'gdm'], check=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'GDM started\n')
            except subprocess.CalledProcessError:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b'Failed to start GDM\n')
                
        elif self.path == '/stop':
            try:
                subprocess.run(['sudo', 'systemctl', 'stop', 'gdm'], check=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'GDM stopped\n')
            except subprocess.CalledProcessError:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b'Failed to stop GDM\n')
                
        elif self.path == '/status':
            result = subprocess.run(['systemctl', 'is-active', 'gdm'], 
                                   capture_output=True, text=True)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(result.stdout.encode())
            
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Available: /start, /stop, /status\n')
    
    def log_message(self, format, *args):
        sys.stderr.write(f"{self.client_address[0]} - {format%args}\n")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), GDMControlHandler)
    print(f'GDM control server listening on http://0.0.0.0:{PORT}')
    server.serve_forever()

