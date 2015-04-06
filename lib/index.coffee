_ = require('lodash')
parse = require('jade-parser')
lex = require('jade-lexer')
walk = require('jade-walk')
serializers = require('./serializers')

spaces = (n = 2) -> _.repeat(' ', n)

indent = (options, indentLevel = 0) ->
  space = spaces(options.spaces)
  _.repeat(space, Math.max(indentLevel - 1, 0))

serializeNode = (node, options, indentLevel = 0) ->
  serializer = serializers[node.type]
  if serializer?
    return indent(options, indentLevel) + serializer(node)
  else
    throw new Error("unexpected token '#{node.type}'")

serializeAST = (ast, options, indentLevel = 0) ->
  lines = {}
  switch ast.type
    when 'NamedBlock', 'Block'
      result = _.map(ast.nodes, (node) -> serializeAST(node, options, indentLevel + 1)).join('\n')
      return if result.length then "\n#{result}" else result
    when 'Case', 'Each', 'Mixin', 'Tag', 'When', 'Code'
      result = serializeNode(ast, options, indentLevel)
      # console.log result, ast.block
      if ast.block
        # result += '\n'
        result += serializeAST(ast.block, options, indentLevel)
      return result
    when 'Extends', 'Include'
      return serializeNode(ast, options, indentLevel)
      # arguably we should walk into the asts, but that's not what the linker wants
      # ast.ast = walkAST(ast.ast, before, after) if ast.ast
      break
    when 'Attrs', 'BlockComment', 'Comment', 'Doctype', 'Filter', 'Literal', 'MixinBlock', 'Text'
      return serializeNode(ast, options, indentLevel)
    else
      throw new Error("Unexpected node type #{ast.type}")

  lineNumbers = _.keys(lines)
  min = _.min(lineNumbers)
  max = _.max(lineNumbers)

  result = ("#{lines[i] ? ''}" for i in [min..max]).join('\n')
  result

module.exports = (filename, content, options = {}) ->
  ast = parse(lex(content, filename))
  # console.log ast
  {
    ast
    source: content
    result: serializeAST(ast, options)
  }
