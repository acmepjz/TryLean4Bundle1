#!/usr/bin/env python3
import io
import zipfile
import zlib
import threading
from http.server import SimpleHTTPRequestHandler, HTTPServer
from urllib.parse import quote, unquote

# Path to the zip file
ZIP_FILE_PATH = 'doc.zip'

class InMemoryZipHTTPRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.zip_file = None
        super().__init__(*args, **kwargs)

    def load_zip(self):
        if self.zip_file is None:
            self.zip_file = zipfile.ZipFile(ZIP_FILE_PATH, 'r')

    def send_response_from_zip(self, file_name):
        self.load_zip()
        file_name = unquote(file_name.lstrip('/'))
        try:
            file_name_br = file_name + ".br"
            file_data = self.zip_file.read(file_name_br)
            crc32 = self.zip_file.getinfo(file_name_br).CRC  # Get the CRC-32 value from the ZIP file info
            content_encoding = "br"
        except KeyError:
            try:
                file_data = self.zip_file.read(file_name)
                crc32 = self.zip_file.getinfo(file_name).CRC  # Get the CRC-32 value from the ZIP file info
                content_encoding = None
            except KeyError:
                # check if it's accessing a directory without trailing '/'
                if not file_name.endswith('/'):
                    namelist = self.zip_file.namelist()
                    if (file_name + '/index.html.br') in namelist or (file_name + '/index.html') in namelist:
                        self.send_response(301)  # Moved Permanently
                        self.send_header("Location", quote('/' + file_name + '/'))
                        self.end_headers()
                        return
                self.send_error(404, "File not found")
                return

        # Check If-None-Match header from the browser
        if 'If-None-Match' in self.headers and self.headers['If-None-Match'] == str(crc32):
            self.send_response(304)  # Not Modified
            self.end_headers()
            return

        # Send 200 OK with file data
        self.send_response(200)
        self.send_header("Content-type", self.guess_type(file_name))
        self.send_header("Content-length", len(file_data))
        self.send_header("ETag", str(crc32))  # Send CRC as ETag
        self.send_header("Cache-Control", "public, max-age=3600")  # Cache for 1 hour
        if not content_encoding is None:
            self.send_header("Content-Encoding", content_encoding)
        self.end_headers()
        self.wfile.write(file_data)

    def do_GET(self):
        """Serve a file from the zip archive"""
        # Normalize path to ensure no backslashes and no double slashes
        path = self.path.replace('\\', '/')
        while '//' in path:
            path = path.replace('//', '/')

        if path.startswith('/'):
            file_name = (path + 'index.html') if path.endswith('/') else path
            self.send_response_from_zip(file_name)
        else:
            super().do_GET()

class ServerThread(threading.Thread):
    def __init__(self, server_address, handler_class):
        super().__init__()
        self.server_address = server_address
        self.handler_class = handler_class
        self.httpd = HTTPServer(self.server_address, self.handler_class)
        self.running = True

    def run(self):
        print(f"Server started on {self.server_address}")
        self.httpd.serve_forever()

    def stop(self):
        self.httpd.shutdown()
        self.httpd.server_close()
        self.running = False
        print("Server stopped.")

def run(handler_class=InMemoryZipHTTPRequestHandler, port=13480):
    print(f"Starting server on port {port}...")
    server_address = ('127.0.0.1', port)
    httpd = HTTPServer(server_address, handler_class)
    print(f"Serving files from zip archive '{ZIP_FILE_PATH}'")
    httpd.serve_forever()

if __name__ == '__main__':
    run()
