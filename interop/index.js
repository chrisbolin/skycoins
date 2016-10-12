var app = Elm.Main.fullscreen();

var HIGHSCORE = 'HIGHSCORE';

// subscriptions

app.ports.saveScore.subscribe(function(score) {
  localStorage.setItem(HIGHSCORE, score);
});

// initialize

var highScore = parseInt(localStorage.getItem(HIGHSCORE)) || 0;
app.ports.getSavedScore.send(highScore);
