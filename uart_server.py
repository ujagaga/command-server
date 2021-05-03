#!/usr/bin/python3
"""
Most 3D printers use Arduino compatible boards and bootloaders which reset the printer upon uart connection
to enable firmware update. This means that we need an application to stay connected to the printer to prevent reset.
This TCP server receives any data and sends it to the configured uart. The uart response is sent back to the client.
The server considers the received message to be completed after it receives an "ok\n" from the printer
"""

import socketserver
import serial
from time import time

UART = "/dev/ttyUSB0"
BAUD = 115200
HOST = "0.0.0.0"
PORT = 2000
MSG_TIMEOUT = 20
serial_dev = serial.Serial()
CMD_TIMEOUT = 0.1
NO_CMD_TIMEOUT = 5


def uart_init():
    global serial_dev

    serial_dev.port = UART
    serial_dev.baudrate = BAUD
    serial_dev.timeout = 0.1
    serial_dev.open()
    # the printer will take some time to initialize, so wait for ok msg
    start_time = time()
    rx = ''
    while (time() - start_time) < MSG_TIMEOUT:
        rx = serial_dev.readline(1024).decode('utf-8')
        if len(rx) > 0:
            print(rx, end='')
            if rx.startswith('size'):
                print(serial_dev.readline(1024).decode('utf-8'))
                break

    print("Ready...")


def uart_send(data):
    global serial_dev

    cmd_request_flag = len(data) > 2
    if cmd_request_flag:
        # Command was requested. Send it.
        serial_dev.timeout = CMD_TIMEOUT
        print("\tTX:", data)
        serial_dev.write(data)
        serial_dev.write("\n".encode())
    else:
        # no command requested. Just waiting for status report if any.
        serial_dev.timeout = NO_CMD_TIMEOUT

    response = ""

    rx = serial_dev.readline().decode('utf-8')
    if len(rx) > 0:
        print(rx, end='')
        response += rx

        if cmd_request_flag:
            # Command was requested. Waiting for "ok"
            while "ok" not in response:
                rx = serial_dev.readline().decode('utf-8')
                if len(rx) > 0:
                    print(rx, end='')
                    response += rx
                else:
                    break

    return response.encode()


class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data = self.request.recv(1024).strip()
        response = uart_send(data)
        self.request.sendall(response)


if __name__ == "__main__":
    try:
        uart_init()

        with socketserver.TCPServer((HOST, PORT), MyTCPHandler) as server:
            server.serve_forever()
    except KeyboardInterrupt:
        print('Exiting')     

    serial_dev.close()