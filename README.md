# command-server
Web server to remotely execute custom scripts.
Feel free to use as you wish.

# What it is for
I often use remote linux machines and need a simple web server to run custom commands via http get request. This is usefull for embedding in html pages so I can execute shell commands from a simple web page.

# Technology
The code is built based on open source Mongoose web server (https://github.com/cesanta/mongoose). You can configure the folder to serve and it expects to have a "cmd" sub-folder which contains scripts to execute (shell, python,...). The scripts must have a sheebang on the first line so the system knows how to execute it. The name of each shell script is considered to be a command name, so keep the script names free of white spaces to make them url safe. Sample scripts are provided for your conveniance. The first line after script shebang is the comment.

# Building
This is intended for use on linux systems, but can probably be adapted for other platforms. If you need this, consult original Mongoose repo.
To build the app just run build.sh. It uses gcc, so you might need to install it first.

# Contact
ujagaga@gmail.com
