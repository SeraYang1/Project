
var socket = new WebSocket('ws://localhost:8081/');
socket.onopen = function(event) {
  log('Opened connection 🎉');
  var json = JSON.stringify({ message: 'Hello' });
  socket.send(json); //websocket has a send method for pushing data to the server and you can provide an onmessage handler for receiving data from the serve
  log('Sent: ' + json);
}

socket.onerror = function(event) { //connects to the  socket.on('message', function(message) {}); 
  log('Error: ' + JSON.stringify(event));
}

socket.onmessage = function (event) {
  log('Received: ' + event.data);
}

socket.onclose = function(event) {
  log('Closed connection 😱');
}

document.querySelector('#close').addEventListener('click', function(event) {
  socket.close();
  log('Closed connection 😱');
});

document.querySelector('#send').addEventListener('click', function(event) {
  var json = JSON.stringify({ message: 'Hey there' });
  socket.send(json);
  log('Sent: ' + json);
});

var log = function(text) {
  var li = document.createElement('li');
  li.innerHTML = text;
  document.getElementById('log').appendChild(li);
}

window.addEventListener('beforeunload', function() {
  socket.close();
});
