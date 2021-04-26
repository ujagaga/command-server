#!/usr/bin/python3

# Stops the 3D printer

import socket

HOST = "printer.local"
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

for msg in UARTMSG:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Connect to server and send data
        sock.connect((HOST, PORT))
        print("TX:", msg)
        sock.sendall(bytes(msg + "\n", "utf-8"))
        rx = sock.recv(1024)

        print(rx.decode('utf-8'))



