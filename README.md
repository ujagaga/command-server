# command-server
Web server to remotely execute custom scripts.
Feel free to use as you wish. 

# What it is for
I often use remote linux machines and need a simple web server to run custom commands via http get request. This is usefull for embedding in html pages so I can execute shell commands from a simple web page.
I developed this as a very light weight alternative to Octoprint. All I wanted was a stop button and a web camera preview for my 3D printer. I am using MJPEG streamer to preview video and this server to send command to the printer.
If you need it for something else, a simplified version might be a better starting point so git checkout branch "Basic".
Recently I tested a python based web server using "FastAPI" which is about 3 times faster than "Flask". On my Raspberry Pi Zero, "mongoose web server" was more than 3 times faster. For this reason I believe my server would be a better choice than Octoprint if anyone were to continue the development. Personally, I might ask for a couple of more features, like code upload and print ETA, so I intend to implement those too, but that is where I would stop.

# Technology
The code is based on open source Mongoose web server (https://github.com/cesanta/mongoose). You can configure the folder to serve and it expects to have a "cmd" sub-folder which contains scripts to execute (shell, python,...). The scripts must have a sheebang (like "#!/bin/bash" or "#!/usr/bin/python3") on the first line so the system knows how to execute it. Make sure it is the absolute path to interpreter and not an environment variable because if you start the server as a service or from a cron job, the environment is not available.
The name of each script is considered to be a command name, so keep the script names free of white spaces to make them url safe. Sample scripts are provided for your conveniance. The first line after script shebang is the comment and should start with "#".
If you need more html sub-pages, just create a directory in the "web" folder, name it as you would like your page to be named and place your html, js and css files there.
You can pass command parameters using html escaped value for parameter "p" like:

	<server_addr>/cmd/<comand_name>?p=<comand_arguments>

My CrealtyEnder 3D Printer uses an Aruino compatible board which resets upon UART connect. This means that I need a program to maintain serial port connection and provide communication in some other way like TCP. For this purpose I prepared "uart_server.py" to run at system startup in the background and keep the serial port open while providing uart acccess via TCP.

# Building
This is intended for use on linux debian based systems, but can probably be adapted for other platforms. If you need to do this, consult original Mongoose repo. I only tested it on Ubuntu and Armbian.
To build the app just run build.sh. It uses gcc, so you might need to install it first (on Ubuntu run: sudo apt install build-essential). 
You can also run "install.sh" this willl download latest files, build and install the app in "/opt/cmdserver" and prepare startup services for you.

# Running
To run it manually, execute:

	./cmd-server -p <port> [-d <directory_to_serve>]

For more options run:

	./cmd-server -h

If you are happy with it, the install script takes care of startup services, so you do not need to run it manually.

# Extra
To stream webcam video, setup mjpegstreamer: 

	git clone https://github.com/jacksonliam/mjpg-streamer.git
	cd mjpg-streamer/mjpg-streamer-experimental
	make
	sudo make install
	cd ..
	rm -rf mjpg-streamer-experimental

Test if ok by running:

	/usr/local/bin/mjpg_streamer -i "input_uvc.so -f 20" -o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www"

Navigate on your computer to IP address, port 8080. To get just the stream, go to <ip_addr>:8080/?action=stream
If the video is lagging, reduce framerate by changing the value after "-f" parameter to a lower one. 

# Contact
email: ujagaga@gmail.com
web: http://radinaradionica.com

