#!/usr/bin/python3

# Retrieves printer status

import socket
from time import time

HOST = "localhost"
PORT = 2000
TIMEOUT = 10
GET_STATUS_MSG = "M27 S4"
sock = None


def tx_msg(msg):
    global sock

    try:
        sock.close()
    except:
        pass

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))
    sock.sendall(bytes(msg, "utf-8"))


def rx_line():
    global sock

    data = ""
    rx_str = ""
    while not rx_str == '\n':
        rx_raw = sock.recv(1)

        if rx_raw == b'':
            break
        else:
            rx_str = rx_raw.decode('utf-8')
            data += rx_str

    return data


tx_msg(GET_STATUS_MSG + "\n")
response = ""
start = time()
while "ok" not in response and (time() - start) < TIMEOUT:
    response = rx_line()
    print(response, end="")

