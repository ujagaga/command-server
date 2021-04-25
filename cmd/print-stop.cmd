#!/usr/bin/python3

# Stops the 3D printer

import serial
from time import time

UART = "/dev/ttyUSB0"
MSG_TIMEOUT = 10

UARTMSG = [
    "M25",                  # Pause SD print. Any command would do because the printer will reset at this point on serial connect.
    "G91",                  # Ensure relative coordinates
    "G1 Z10",               # Raise head
    "M106 S0",              # Turn-off fan
    "M104 S0",              # Turn-off hotend
    "M140 S0",              # Turn-off bed
    "M18",                  # Disable steppers
]

serial_dev = serial.Serial()
serial_dev.port = UART
serial_dev.baudrate = 115200
serial_dev.timeout = 0.1
serial_dev.open()
serial_dev.readline()       # Just empty the buffer
serial_dev.timeout = 1

for msg in UARTMSG:
    print("TX:", msg)
    outmsg = msg + '\n'
    serial_dev.write(outmsg.encode())

    start_time = time()

    while (time() - start_time) < MSG_TIMEOUT:
        response_msg = serial_dev.readline(1024).decode()
        if response_msg is not None and len(response_msg) > 1:
            print(" ", response_msg.replace('\n', ''))
            if response_msg.startswith("ok"):
                break

serial_dev.close()
