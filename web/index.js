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

window.onload = function() {
    var img = document.getElementById('preview');
    img.src = window.location.protocol + "//" + window.location.hostname + ":8080/?action=stream";

    img.onload = function() {
        if(img.height > img.width) {
            img.height = '100%';
            img.width = 'auto';
        }
    };    
}