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
  //TODO test drawing code for iOS, currently not detecting changes b/c of brush being sent first
  const drawingObject = ref.child(access_code);
  const strokesList = drawingObject.child('strokes');

//TODO NOT REGISTERING REGULAR DOTS
//TODO update logic for previous point & figure out current point
  strokesList.on("child_changed", function(snapshot) {
    console.log(snapshot.val().x1)
    if (snapshot.child("x1").exists()) { //there is at least one coordinate. ok.
      console.log("JEJ");
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

//TODO NOT REGISTERING REGULAR DOTS
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
    // console.log(numOfCoords)
    curr = strokes[i];
    if (numOfCoords == 1) {
      console.log("jej"); //currently not happening for points
      draw( curr['x'+1], curr['y'+1], curr['x'+1], curr['y'+1], curr['red'], curr['green'], curr['blue'], curr['opacity'], curr['brush_width']);
    }
    else {
      for ( var j = 1; j < numOfCoords - 1; j++ ) {
        draw( curr['x'+j], curr['y'+j], curr['x'+(j+1)], curr['y'+(j+1)], curr['red'], curr['green'], curr['blue'], curr['opacity'], curr['brush_width'] );
      }
    }
  }
}

// Update canvas
//TODO test: 1. starting from init, 2. starting from middle 
function updateCanvas(data) {
    console.log("this is the key")
    console.log(data.key)
    console.log(JSON.stringify(data.val()))
    var numOfCoords = JSON.stringify(data.val()).split('x').length;
    console.log(numOfCoords);
    for ( var j = 1; j < numOfCoords - 1; j++ ) {
      draw( data['x'+j], data['y'+j], data['x'+(j+1)], data['y'+(j+1)], data['red'], data['green'], data['blue'], data['opacity'], data['brush_width'] );
    }

}

//Reset canvas
//TODO write
function reset() {
  console.log("finish this method");
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