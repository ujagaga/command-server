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

STOPMSG = "M25\nG1 E-2 Z0.2 F2400\nM106 S0\nM104 S0\nM140 S0\nM84 X Y E\nM18\nM300 S440 P200\nM300 S660 P250\nM300 S880 P300\n"

serial_dev = serial.Serial()
serial_dev.port = "/dev/ttyUSB0"
serial_dev.baudrate = 115200
serial_dev.timeout = 0.5
serial_dev.open()
serial_dev.readline(100)       # Just emty the buffer
serial_dev.write(STOPMSG.encode())
response_msg = serial_dev.readline(100).decode()
serial_dev.close()

print(response_msg.replace('\n', '|'))

