// Initialize Firebase

(function() {

  const config = {
    apiKey: "AIzaSyAvmqVyXoZk9Xwo6eJY9FiCc4mQSmfjzHk",
    authDomain: "test-daef2.firebaseapp.com",
    databaseURL: "https://test-daef2.firebaseio.com",
    projectId: "test-daef2",
    storageBucket: "test-daef2.appspot.com",
    messagingSenderId: "225539781616"
  };
  firebase.initializeApp(config);
  

}());

// Reading access code input field and connecting to Firebase

function connect() {
  var access_code = $('#access').val().trim();
  var ref = firebase.database().ref();

  // Loads initial strokes (catch up with live version)
  ref.once("value").then(function(snapshot) {
    if( access_code != "" && snapshot.hasChild( access_code ) ) {

      console.log(snapshot.child(access_code).val());

      $('#splash').hide();
      $('#app').show();
      init( snapshot.child(access_code).val() );

    } else {
      alert('Not a valid access code. Please try again.');
    }
  }, function (error) {
    console.log("Error: " + error.code);
  });
}

// Opening animation

$('#icon').click(function() {
  $('#icon').fadeOut('slow');
  $('#intro').fadeIn('slow');
});

// Close button on the canvas

$('#close').click(function() {
  $('#app').hide();
  $('#splash').show();
});

// Initializing the canvas

function init( data ) {
  var c = document.getElementById("canvas");
  c.height = data.screen_height;
  c.width = data.screen_width;

  var ctx = c.getContext("2d");
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  var strokes = data.strokes;
  for ( var i = 1; i <= data.current_stroke; i++ ) {

    var numOfCoords = JSON.stringify(strokes[1]).split('x').length;
    curr = strokes[i];

    for ( var j = 1; j < numOfCoords - 1; j++ ) {
      draw( curr['x'+j], curr['y'+j], curr['x'+(j+1)], curr['y'+(j+1)], curr['red'], curr['green'], curr['blue'], curr['opacity'], curr['brush_width'] );
    }

  }
}

// Generic draw function on a canvas

function draw( x1, y1, x2, y2, r, g, b, a, thickness ) {
  var c = document.getElementById("canvas");
  var ctx = c.getContext("2d");
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.strokeStyle = "rgba("+r+", "+g+", "+b+","+a+")";
  ctx.lineWidth = thickness;
  ctx.lineTo(x2, y2);
  ctx.closePath();
  ctx.stroke();
}

// Download button on canvas (saves as file)

function downloadCanvas(link, canvasId, filename) {
  link.href = document.getElementById(canvasId).toDataURL();
  link.download = filename;
}
document.getElementById('download').addEventListener('click', function() {
  downloadCanvas(this, 'canvas', 'test.png');
}, false);