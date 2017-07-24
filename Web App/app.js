
(function() {

  // Initialize Firebase
  const config = {
    apiKey: "AIzaSyAvmqVyXoZk9Xwo6eJY9FiCc4mQSmfjzHk",
    authDomain: "test-daef2.firebaseapp.com",
    databaseURL: "https://test-daef2.firebaseio.com",
    projectId: "test-daef2",
    storageBucket: "test-daef2.appspot.com",
    messagingSenderId: "225539781616"
  };
  firebase.initializeApp(config);
  

  const preObject = document.getElementById('object');
  //get reference to data
  const dbRefObject = firebase.database().ref().child('object'); //creates a child object for root

  //sync changes in realtime on that particular object
  dbRefObject.on('value', snap => console.log(snap.val()))
  //.on(event type controls level of synchronization, callback function)
  //snap is a data snapshot; returns key name and ways to iterate children as well
  //optimize by synchronizing particular dictionaries: https://www.youtube.com/watch?v=dBscwaqNPuk&t=514s
}());