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

      // console.log(snapshot.child(access_code).val());

      $('#splash').hide();
      $('#app').show();
      init( snapshot.child(access_code).val() );

    } else {
      alert('Not a valid access code. Please try again.');
    }
  }, function (error) {
    console.log("Error: " + error.code);
  });

  //Listens for realtime updates
  const drawingObject = ref.child(access_code);
  const strokesList = drawingObject.child('strokes');
  const numAttrKeys = 5

//TODO clean up code

  strokesList.on("child_changed", function(snapshot) {
    const numCoordParts = (snapshot.numChildren() - 5) 

    if (numCoordParts % 2 == 0 && numCoordParts > 2) { //there is more than  one coordinate. ok.
      const numCoords = numCoordParts / 2;
      const toX = snapshot.child("x" + (numCoords)).val(); //last coordinate
      const toY = snapshot.child("y" + (numCoords)).val();
      const fromX = snapshot.child("x" + (numCoords - 1)).val();
      const fromY = snapshot.child("y" + (numCoords - 1)).val();
      draw(fromX, fromY, toX, toY, snapshot.child("red").val(), snapshot.child("green").val(),  snapshot.child("blue").val(), snapshot.child("opacity").val(), snapshot.child("brush_width").val()) 

    // updateCanvas(snapshot);
    }

  });

  // Listens for reset event
  ref.child(access_code).on("child_removed", function(snapshot) {
    console.log(snapshot.key)
    if (snapshot.key == "strokes") {
      reset();
    }
    
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

  reset();

  var strokes = data.strokes;
  for ( var i = 1; i <= data.current_stroke; i++ ) {

    var numOfCoords = JSON.stringify(strokes[i]).split('x').length-1;
    curr = strokes[i];

    if (numOfCoords == 1) {
      draw( curr['x'+1], curr['y'+1], curr['x'+1]+0.4, curr['y'+1]+0.4, curr['red'], curr['green'], curr['blue'], curr['opacity'], curr['brush_width']);
    }
    else {
      for ( var j = 1; j < numOfCoords; j++ ) {
        draw( curr['x'+j], curr['y'+j], curr['x'+(j+1)], curr['y'+(j+1)], curr['red'], curr['green'], curr['blue'], curr['opacity'], curr['brush_width'] );
      }
    }

  }
}

//Reset canvas

function reset() {
  var ctx = document.getElementById('canvas').getContext("2d");
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

// Generic draw function on a canvas

function draw( x1, y1, x2, y2, r, g, b, a, thickness ) {
  var c = document.getElementById("canvas");
  var ctx = c.getContext("2d");
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.strokeStyle = "rgba("+r+", "+g+", "+b+", "+a+")";
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
  downloadCanvas(this, 'canvas', 'project_'+date()+'.png');
}, false);
function date() {
  var today = new Date();
  var dd = today.getDate();
  var mm = today.getMonth()+1; //January is 0!
  var yyyy = today.getFullYear();

  if(dd<10) {
      dd = '0'+dd
  } 

  if(mm<10) {
      mm = '0'+mm
  } 

  today = mm + '-' + dd + '-' + yyyy;
  return today;
}