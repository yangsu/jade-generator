# jade-generator

Generated jade code using a jade AST

## Installation

    npm install jade-generator

## Usage

```js
var lex = require('jade-lexer');
var parse = require('jade-parser');
var generator = require('jade-generator');

var ast = parse(lex('.my-class food'));

assert.deepEqual(parse(lex(generator(ast))), ast);
```

## TODOs

- [ ] correctly generate selfClosing properties on tags
- [ ] support inline tag syntaxt
- [ ] correctly generate line numbers

## License

  MIT
