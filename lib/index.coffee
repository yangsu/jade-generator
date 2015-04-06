_ = require('lodash')
parse = require('jade-parser')
lex = require('jade-lexer')
walk = require('jade-walk')
serializers = require('./serializers')

serializeNode = (node) ->
  serializer = serializers[node.type]
  if serializer?
    return serializer(node)
  else
    throw new Error('unexpected token "' + node.type + '"')
  return

serializeAST = (ast) ->
  lines = {}
  console.log ast
  switch ast.type
    when 'NamedBlock', 'Block'
      return _.map(ast.nodes, serializeAST).join('\n')
    when 'Case', 'Each', 'Mixin', 'Tag', 'When', 'Code'
      result = serializeNode(ast)
      if ast.block
        result += serializeAST(ast.block)
      return result
    when 'Extends', 'Include'
      return serializeNode(ast)
      # arguably we should walk into the asts, but that's not what the linker wants
      # ast.ast = walkAST(ast.ast, before, after) if ast.ast
      break
    when 'Attrs', 'BlockComment', 'Comment', 'Doctype', 'Filter', 'Literal', 'MixinBlock', 'Text'
      return serializeNode(ast)
    else
      throw new Error('Unexpected node type ' + ast.type)

  lineNumbers = _.keys(lines)
  min = _.min(lineNumbers)
  max = _.max(lineNumbers)

  result = ("#{lines[i] ? ''}" for i in [min..max]).join('\n')
  result

module.exports = (filename, content, options) ->
  ast = parse(lex(content, filename))
  serializeAST ast
