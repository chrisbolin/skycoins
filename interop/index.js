// initialize firebase

firebase.initializeApp({
  apiKey: "AIzaSyDGhkpnpn9s89X-AZvn7M04ZPLG_4X8P1c",
  authDomain: "skycoins-ce718.firebaseapp.com",
  databaseURL: "https://skycoins-ce718.firebaseio.com",
  storageBucket: "skycoins-ce718.appspot.com",
  messagingSenderId: "674859543788"
});

var db = firebase.database();

var app = Elm.Main.fullscreen();

var HIGHSCORE = 'HIGHSCORE';

// subscriptions

app.ports.saveScore.subscribe(function(payload) {
  var username = payload[0];
  var score = payload[1];
  saveLocalHighscore(score);
  saveLeaderboardScore(username, score);
});

// initialize

var highScore = getLocalHighScore();
app.ports.getSavedScore.send(highScore);

// firebase methods

function saveLeaderboardScore(username, score) {
  console.log('Saving new leaderboard entry', score, 'for', username);
  db.ref('highscores').push({
    username: username,
    score: score,
    timestamp: firebase.database.ServerValue.TIMESTAMP,
  });
}

function saveLocalHighscore(score) {
  if (score > getLocalHighScore()) {
    console.log('Saving new LOCAL best', score);
    localStorage.setItem(HIGHSCORE, score);
  }
}

function getLeaderboard() {
  return db.ref('highscores').orderByChild('score').limitToLast(10).on('value', function(snapshot) {
    var raw = snapshot.val();
    var leaderboard = Object.keys(raw)
      .map(function(key){
        return raw[key]
      })
    app.ports.getLeaderboard.send(leaderboard);
  });
}

getLeaderboard();


// helpers

function getLocalHighScore() {
  return parseInt(localStorage.getItem(HIGHSCORE)) || 0;
}
