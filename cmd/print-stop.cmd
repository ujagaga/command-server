#!/usr/bin/python3

# Stops the 3D printer
import serial

serial_dev = serial.Serial()
serial_dev.port = "/dev/ttyUSB0"
serial_dev.baudrate = 115200
serial_dev.timeout = 0.5
serial_dev.open()
serial_dev.readline(100)       # Just emty the buffer
serial_dev.write('stop\n'.encode())
response_msg = serial_dev.readline(100).decode()
serial_dev.close()

print(response_msg.replace('\n', ''))

