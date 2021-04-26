#!/usr/bin/python3
"""
Most 3D printers use Arduino compatible boards and bootloaders which reset the printer upon uart connection
to enable firmware update. This means that we need an application to stay connected to the printer to prevent reset.
This TCP server receives any data and sends it to the configured uart. The uart response is sent back to the client.
"""

import socketserver
import serial

UART = "/dev/ttyUSB0"
BAUD = 115200
HOST = "0.0.0.0"
PORT = 2000

serial_dev = serial.Serial()


def uart_init():
    global serial_dev

    serial_dev.port = UART
    serial_dev.baudrate = BAUD
    serial_dev.timeout = 10
    serial_dev.open()
    serial_dev.readline(1024)  # Just empty the buffer from the initial status message
    serial_dev.timeout = 0.1


def uart_send(data):
    serial_dev.write(data)
    serial_dev.write("\n".encode())
    return serial_dev.readline(1024)


class MyTCPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data = self.request.recv(1024).strip()
        self.request.sendall(uart_send())


if __name__ == "__main__":
    uart_init()

    with socketserver.TCPServer((HOST, PORT), MyTCPHandler) as server:
        server.serve_forever()