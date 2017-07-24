document.getElementById('connect').addEventListener('click', function(event) {
  
  var socket = new WebSocket('ws://localhost:8081/');

  socket.onopen = function(event) {
    console.log('Opened connection 🎉');

    var accessCode = document.getElementById('access').value;

    var json = JSON.stringify({ code: accessCode });
    socket.send(json); //websocket has a send method for pushing data to the server and you can provide an onmessage handler for receiving data from the serve
    console.log('Sent: ' + json);
  }

  socket.onerror = function(event) { //connects to the  socket.on('message', function(message) {}); 
    console.log('Error: ' + JSON.stringify(event));
  }

  socket.onmessage = function (event) {
    console.log('Received: ' + event.data);
  }

  socket.onclose = function(event) {
    console.log('Closed connection 😱');
  }

  document.querySelector('#close').addEventListener('click', function(event) {
    socket.close();
    console.log('Closed connection 😱');
  });

  window.addEventListener('beforeunload', function() {
    socket.close();
  });

});
