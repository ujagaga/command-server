#!/usr/bin/python3

# Stops the 3D printer
# M25 - Pause SD print
# G1 E-2 Z0.2 F2400 ;Retract and raise Z
# M106 S0 ;Turn-off fan
# M104 S0 ;Turn-off hotend
# M140 S0 ;Turn-off bed
# M84 X Y E ;Disable all steppers but Z
# M18 - Disable steppers
# M300 S440 P200 ; Play sound
# M300 S660 P250
# M300 S880 P300

import serial

UART = "/dev/ttyUSB0"

UARTMSG = [
    "M25",                  # Pause SD print
    "G1 E-2 Z0.2 F2400",    # Retract and raise Z
    "M106 S0",              # Turn-off fan
    "M104 S0",              # Turn-off hotend
    "M140 S0",              # Turn-off bed
    "M84 X Y E",            # Disable all steppers but Z
    "M18",                  # Disable steppers
    "M300 S440 P200",       # Play sound
    "M300 S660 P250",       # Play sound
    "M300 S880 P300"        # Play sound
]

serial_dev = serial.Serial()
serial_dev.port = UART
serial_dev.baudrate = 115200
serial_dev.timeout = 0.1
serial_dev.open()
serial_dev.readline()       # Just empty the buffer
serial_dev.timeout = 5

for msg in UARTMSG:
    outmsg = msg + '\n'
    serial_dev.write(outmsg.encode())
    response_msg = serial_dev.readline(100).decode()
    print(response_msg.replace('\n', ''))

serial_dev.close()
