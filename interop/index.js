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

app.ports.saveScore.subscribe(function(score) {
  console.log('saveScore()', score);
  localStorage.setItem(HIGHSCORE, score);
  saveHighScore('C*B', score);
});

// initialize

var highScore = parseInt(localStorage.getItem(HIGHSCORE)) || 0;
app.ports.getSavedScore.send(highScore);

// firebase methods

function saveHighScore(username, score) {
  db.ref('highscores').push({
    username: username,
    score: score,
  });
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
