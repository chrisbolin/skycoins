/*
Clean the anon scoreboard, because you can't have nice things

node scoreboard.js PATH_TO_JSON

PATH_TO_JSON - find at https://console.firebase.google.com/u/0/project/skycoins-ce718/database/skycoins-ce718/data
*/

const yargs = require("yargs");
const fs = require("fs");

function validate({ score, timestamp, username }) {
  if (!timestamp) return false;
  if (!username) return false;
  if (username[0] !== username[0].toUpperCase()) return false;
  if (score < 10000) return false;

  return true;
}

function run() {
  const { argv } = yargs;
  var path = argv._[0];

  try {
    var file = fs.readFileSync(path, { encoding: "utf-8" });
  } catch {
    console.error(
      `Invalid call. Must include valid JSON file path. Path: ${path}`
    );
    return;
  }
  const tree = JSON.parse(file);

  let total = 0;
  let removed = 0;

  for (const key of Object.keys(tree.highscores)) {
    const item = tree.highscores[key];
    const valid = validate(item);

    if (!valid) {
      delete tree.highscores[key];
      removed++;
    }

    console.log(item, valid ? "k" : "!! REMOVE !!");
    total++;
  }

  const newFile = JSON.stringify(tree, null, 2);
  const newPath = `${path}-${Date.now()}.json`;
  fs.writeFileSync(newPath, newFile);

  console.log(
    `${total} total. removed ${removed} and kept ${total - removed}.`
  );
  console.log("updated file:", newPath);
}

run();
