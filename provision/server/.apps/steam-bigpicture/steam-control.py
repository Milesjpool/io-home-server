#!/usr/bin/env python3
"""Simple HTTP service to control Steam Big Picture via network requests"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess
import sys

PORT = 8889  # Different port from desktop control

class SteamControlHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/start':
            try:
                # Start Steam Big Picture (includes X server)
                subprocess.run(['sudo', 'systemctl', 'start', 'steam-bigpicture'], check=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'Steam Big Picture started\n')
            except subprocess.CalledProcessError:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b'Failed to start Steam\n')
                
        elif self.path == '/stop':
            try:
                # Stop Steam Big Picture (includes X server)
                subprocess.run(['sudo', 'systemctl', 'stop', 'steam-bigpicture'], check=True)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'Steam Big Picture stopped\n')
            except subprocess.CalledProcessError:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b'Failed to stop Steam\n')
                
        elif self.path == '/status':
            result = subprocess.run(['systemctl', 'is-active', 'steam-bigpicture'], 
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
    server = HTTPServer(('0.0.0.0', PORT), SteamControlHandler)
    print(f'Steam control server listening on http://0.0.0.0:{PORT}')
    server.serve_forever()
