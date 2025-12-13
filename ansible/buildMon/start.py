import http.server, ssl, socketserver, os

PORT = 443
handler = http.server.SimpleHTTPRequestHandler

httpd = socketserver.TCPServer(('0.0.0.0', PORT), handler)

# Create an SSL context
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile="server.pem", keyfile="server.key")

# Wrap the socket with the context
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Serving HTTPS on port {PORT}")
with open("server.pid", "w") as f:
    f.write(str(os.getpid()))

httpd.serve_forever()
