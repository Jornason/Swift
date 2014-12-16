var teamAuthors = document.querySelector('ul.team-members') 
var authors = teamAuthors.querySelectorAll('li')

function parseAuthors() {
  result = []
  for (var i = 0; i < authors.length; i++) {
    var author = authors[i];
    var authorName = author.querySelector('h3').textContent; 
    var authorURL = "http://www.raywenderlich.com" +
    author.querySelector('a').getAttribute('href'); 
    result.push({'authorName' : authorName, 'authorURL' : authorURL}); 
  }
  return result; 
}

var authors = parseAuthors(); 
webkit.messageHandlers.didFetchAuthors.postMessage(authors);