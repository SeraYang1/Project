// Initialize Firebase
var userID;
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
  const auth = firebase.auth();
  if (auth.currentUser == null) {
    auth.signInAnonymously().then(function() { 
      this.userID = auth.currentUser.uid;
      console.log("In else")
      console.log(this.userID)
      }).catch(function(error) { 
      var errorCode = error.code;
      var errorMessage = error.message;
      console.log("OK");
      if (errorCode === 'auth/operation-not-allowed') {
       alert('You must enable Anonymous auth in the Firebase Console.');
      } else {
       console.error(error);
      }
    });
  }
  else {
      this.userID = auth.currentUser.uid;
      console.log("In else")
      console.log(this.userID)

  }

}());

// Reading access code input field and connecting to Firebase

function connect() {
  //Authenticate user
  

  var access_code = $('#access').val().trim(); 
  console.log(access_code)
  var ref = firebase.database().ref();
  var userNode = ref.child('sharing').child(this.userID).child(access_code).set(""); 
  ref.child('sharing').child(this.userID).child(access_code).onDisconnect().remove();

  // Loads initial strokes (catch up with live version)

  ref.child(access_code).once("value").then(function(snapshot) {

      $('#splash').hide();
      $('#app').show();
      init( snapshot.val() ); 

  }, function (error) {
    alert('Not a valid access code. Please try again.'); //TODO fix
  });
  const drawingObject = ref.child(access_code);
  const strokesList = drawingObject.child('strokes');
  const numAttrKeys = 4
 
  //Listens for realtime updates
  var strokeNo;
  var thickness;
  strokesList.on("child_changed", function(snapshot) {
    const numCoordParts = (snapshot.numChildren() - numAttrKeys) 

    if (numCoordParts % 2 == 0 && numCoordParts > 2) { //there is more than  one coordinate
      const numCoords = numCoordParts / 2;
      const toX = snapshot.child("x" + (numCoords)).val(); //last coordinate
      const toY = snapshot.child("y" + (numCoords)).val();
      const fromX = snapshot.child("x" + (numCoords - 1)).val();
      const fromY = snapshot.child("y" + (numCoords - 1)).val();
      const r = snapshot.child("red").val();
      const g = snapshot.child("green").val();
      const b = snapshot.child("blue").val();
      draw(fromX, fromY, toX, toY, r, g, b, 1, thickness);

    }
    else if (numCoordParts == 2) { //this is a point
      const x = snapshot.child("x1").val(); //last coordinate
      const y = snapshot.child("y1").val();
      const r = snapshot.child("red").val();
      const g = snapshot.child("green").val();
      const b = snapshot.child("blue").val();
      thickness = snapshot.child("brush_width").val();
      drawPoint( x, y, r, g, b, 1, thickness );
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
    drawStroke( strokes[i] );
  }
}

//Reset canvas
function reset() {
  var ctx = document.getElementById('canvas').getContext("2d");
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

// Drawing a single stroke

function drawStroke( stroke ) {
  var numOfCoords = JSON.stringify(stroke).split('x').length - 1;

  if (numOfCoords == 1) {
    drawPoint( stroke['x'+1], stroke['y'+1], stroke['red'], stroke['green'], stroke['blue'], 1, stroke['brush_width']);
  }
  else {
    for ( var j = 1; j < numOfCoords; j++ ) {
      draw( stroke['x'+j], stroke['y'+j], stroke['x'+(j+1)], stroke['y'+(j+1)], stroke['red'], stroke['green'], stroke['blue'], 1, stroke['brush_width'] );
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

  r = Math.round(r);
  g = Math.round(g);
  b = Math.round(b);

  ctx.strokeStyle = "rgba("+r+", "+g+", "+b+", "+a+")";
  ctx.lineWidth = thickness;
  ctx.lineTo(x2, y2);
  ctx.closePath();
  ctx.stroke();
}

// Drawing a single point

function drawPoint( x, y, r, g, b, a, thickness ) {
  draw( x, y, x+0.4, y+0.4, r, g, b, a, thickness);
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