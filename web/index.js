function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

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
            console.log(this.responseText);  
            var printMsg = document.getElementById('printer-msg');
            var newMsg = this.responseText.replace(/(?:\r\n|\r|\n)/g, '<br>');
            if(!printMsg.endsWith(newMsg)){
                printMsg += newMsg;

                if(printMsg.length > 1000){
                    printMsg = printMsg.substring(printMsg.length - 1000);
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
