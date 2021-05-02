#!/usr/bin/python3

# Retrieves printer status

import socket

HOST = "localhost"
PORT = 2000
MSG_TIMEOUT = 10
UARTMSG = [
    "M27 S4",
]

for msg in UARTMSG:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Connect to server and send data
        sock.connect((HOST, PORT))
        sock.sendall(bytes(msg + "\n", "utf-8"))
        rx = sock.recv(1024)

        print(rx.decode('utf-8'))



