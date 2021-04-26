#!/usr/bin/python3

# Stops the 3D printer

import socket
from time import time

HOST = "localhost"
PORT = 2000
MSG_TIMEOUT = 10
UARTMSG = [
    "M25",                  # Pause SD print
    "G91",                  # Ensure relative coordinates
    "G1 Z10",               # Raise head
    "M106 S0",              # Turn-off fan
    "M104 S0",              # Turn-off hotend
    "M140 S0",              # Turn-off bed
    "M18",                  # Disable steppers
]

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
    # Connect to server and send data
    sock.connect((HOST, PORT))

    for msg in UARTMSG:
        print("TX:", msg)
        sock.sendall(bytes(msg + "\n", "utf-8"))

        # Receive data from the server
        start_time = time()
        rx = 0
        response = bytes(b'')
        while (rx != b'\r') and ((time() - start_time) < MSG_TIMEOUT):
            rx = sock.recv(1024)
            response += rx

        print(response.decode('utf-8'))



