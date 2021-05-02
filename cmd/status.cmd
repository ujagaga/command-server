#!/usr/bin/python3

# Retrieves printer status

import socket

HOST = "localhost"
PORT = 2000
MSG_TIMEOUT = 10
GET_STATUS_MSG = "M27 S4"

# send a short message so there is no usrt msg sent, but just wait for any response from printer
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    # Connect to server and send data
    sock.connect((HOST, PORT))
    sock.sendall(bytes("\n", "utf-8"))
    rx = sock.recv(1024)

    print(rx.decode('utf-8'))

if len(rx) < 5:
    # No valid response from printer. Request status.
    print("No printer response. Requesting status...")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Connect to server and send data
        sock.connect((HOST, PORT))
        sock.sendall(bytes(GET_STATUS_MSG + "\n", "utf-8"))
        rx = sock.recv(1024)

        print(rx.decode('utf-8'))



