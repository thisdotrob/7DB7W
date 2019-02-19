/***
 * Day 2 Homework, 'Do' section.
***/

function(doc) {
  if ('albums' in doc && doc.albums.length) {
    doc.albums.forEach(function (album) {
      if ('tracks' in album && album.tracks.length) {
        album.tracks.forEach(function (track) {
          if ('tags' in track && track.tags.length) {
            track.tags.forEach(function (tag) {
              emit(tag.random, tag.idstr);
            });
          }
        });
      }
    });
  }
}

// Use the above view to get a random tag with the following curl:
// curl "localhost:5984/music/_design/random/_view/tag?\
// startkey=$(ruby -e 'puts rand')&limit=1"
