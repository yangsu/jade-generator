lib = require('../')
fs = require('fs')
path = require('path')
Q = require('q')

_file = (f) -> path.join(__dirname, f)
_readFile = Q.nfbind(fs.readFile)

filename = 'test.jade'
readFile = (f) -> _readFile(_file(filename), 'utf8')

readFile(filename).done (content) ->
  result = lib(filename, content)
  console.log result

