/***
 * Day 2 Homework, 'Do' section.
***/

function(doc) {
  if ('albums' in doc && doc.albums.length) {
    doc.albums.forEach(function (album) {
      if ('random' in album) {
        emit(album.random, album.name);
      }
    });
  }
}

// Use the above view to get a random album with the following curl:
// curl "localhost:5984/music/_design/random/_view/album?\
// startkey=$(ruby -e 'puts rand')&limit=1"

