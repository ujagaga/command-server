var lastMsg = "";

function execute(cmd_name) {
    var request = new XMLHttpRequest();
    request.open("GET", window.location.protocol + "//" + window.location.host + "/cmd/" + cmd_name);

    request.onreadystatechange = function() {
        if(this.readyState === 4 && this.status === 200) {
            console.log(this.responseText);
            var msglog = document.getElementById('msglog');
            msglog.style.opacity = '1';
            msglog.innerHTML = this.responseText.replace(/(?:\r\n|\r|\n)/g, '<br>');
            window.setTimeout(function(){
                msglog.style.opacity = '0';
            }, 5000);
        }
    };

    request.send();
}

function get_status() {
    var request = new XMLHttpRequest();
    request.open("GET", window.location.protocol + "//" + window.location.host + "/cmd/status");

    request.onreadystatechange = function() {
        if(this.readyState === 4 && this.status === 200) { 
            if(lastMsg != this.responseText){
                // Received new status. Display it in printer message box
                lastMsg = this.responseText;

                var printMsg = document.getElementById('printer-msg');
                var printMsgText = printMsg.innerHTML;
                var newMsg = this.responseText.replace(/(?:\r\n|\r|\n)/g, '<br>');
                printMsgText += newMsg.replace("<br><br>", "<br>");

                if(printMsgText.length > 1000){
                    printMsgText = printMsgText.substring(printMsgText.length - 1000);
                }  

                printMsg.innerHTML = printMsgText;
                printMsg.scrollTop = printMsg.scrollHeight;
                
                // Parse the progress             
                var lines = this.responseText.split('\n');
                for (i = lines.length - 1; i >= 0; i--) {
                    line = lines[i];
                    if(line.includes('printing byte')){
                        var progress = line.split('printing byte')[1].split('/');
                        var percentage = (progress[0]/progress[1]) * 100;
                        document.getElementById('status-msg').innerHTML = "" + percentage + "%";
                        break;
                    }
                }
            }

            setTimeout(get_status, 1000);   
        }
    };

    request.send();
}

function setPreviewSize(){
	var img = document.getElementById('preview');
	
	const width  = (window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth) - 20;
	const height = (window.innerHeight|| document.documentElement.clientHeight|| document.body.clientHeight) - 55;
	
	img.style.width = width + 'px';
	img.style.height = 'auto';
	
	if(img.height > height){
		img.style.height = height + 'px';
		img.style.width = 'auto';
	}	
}

window.onload = function() {
    var img = document.getElementById('preview');
    img.src = window.location.protocol + "//" + window.location.hostname + ":8080/?action=stream";
	setPreviewSize();	
    get_status();
}
