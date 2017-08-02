var http = require('http');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('It\'s April!\n');
}).listen('%APP_PORT%', '127.0.0.1');

console.log('Server running at http://127.0.0.1:%APP_PORT%/');
