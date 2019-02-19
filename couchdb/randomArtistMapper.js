/***
 * Day 2 Homework, 'Do' section.
***/

function(doc) {
  if ('name' in doc && 'random' in doc) {
    emit(doc.random, doc.name);
  }
}

// Use the above view to get a random artist with the following curl:
// curl "localhost:5984/music/_design/random/_view/artist?\
// startkey=$(ruby -e 'puts rand')&limit=1"
