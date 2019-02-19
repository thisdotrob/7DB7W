/***
 * Day 2 Homework, 'Do' section.
***/

function(doc) {
  if ('albums' in doc && doc.albums.length) {
    doc.albums.forEach(function (album) {
      if ('tracks' in album && album.tracks.length) {
        album.tracks.forEach(function (track) {
          emit(track.random, track.name)
        })
      }
    });
  }
}

// Use the above view to get a random track with the following curl:
// curl "localhost:5984/music/_design/random/_view/track?\
// startkey=$(ruby -e 'puts rand')&limit=1"
