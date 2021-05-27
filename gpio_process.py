#!/usr/bin/env python3

'''
Orange PI GPIO module
sudo apt install python3-dev
pip3 install OrangePi.GPIO

This script provesses GPIO pins and executes printer commands. 
Main intention is to detect when filament brakes, so this script can stop the printer and wait for the filament to be replaced.
'''

import OPi.GPIO as GPIO
import time
import socket

BTN_PAUSE = 21
HOST = "localhost"
PORT = 2000


def setup():
    GPIO.setboard(GPIO.ZERO)
    GPIO.setmode(GPIO.BOARD)

    GPIO.setup(BTN_PAUSE, GPIO.IN, pull_up_down=GPIO.PUD_UP)


def pause_printer():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))
    sock.sendall(bytes("M600\n", "utf-8"))	# Change filament

    data = ""
    rx_str = ""
    while not rx_str == '\n':
        rx_raw = sock.recv(1)
        if rx_raw == b'':
            break
        else:
            rx_str = rx_raw.decode('utf-8')
            data += rx_str

    print("Received:" + data)
    sock.close()


setup()
time.sleep(10)

try:
    while True:
        if not GPIO.input(BTN_PAUSE):
            pause_printer()

        time.sleep(0.1)

finally:                        # this block will run no matter how the try block exits
    GPIO.cleanup()              # clean up after yourself
