_ = require('lodash')
serializers = require('./serializers')
{inspect} = require('util')

spaces = (n = 2) -> _.repeat(' ', n)

indent = (options, indentLevel = 0) ->
  space = spaces(options.spaces)
  _.repeat(space, Math.max(indentLevel - 1, 0))

NO_PREFIX = {noPrefix: true}

serializeNode = (node, options, indentLevel = 0) ->
  serializer = serializers[node.type]
  if serializer?
    serialized = serializer(node, options)
    if serialized.length
      indent(options, indentLevel) + serialized
    else
      serialized
  else
    throw new Error("unexpected token '#{node.type}'")

serializeAST = (ast, options, indentLevel = 0) ->
  result = serializeNode(ast, options, indentLevel)

  switch ast.type
    when 'NamedBlock', 'Block'
      children = _.chain(ast.nodes)
        .map((node) -> serializeAST(node, options, indentLevel + 1))
        .filter((str) -> _.isString(str))
        .value()

      if children.length
        result += '\n' if ast.line isnt 0
        return "#{result}#{children.join('\n')}"
      else
        return "#{result}"

    when 'Case', 'Each', 'When', 'Code'
      result += serializeAST(ast.block, options, indentLevel) if ast.block
      if ast.alternative
        result += "\n#{indent(options, indentLevel)}else"
        result += serializeAST(ast.alternative, options, indentLevel)
      # NOTE no indent need for code
      result += serializeAST(ast.code, options, 0) if ast.code
    when 'BlockComment', 'Filter'
      result += serializeAST(ast.block, _.extend({}, options, NO_PREFIX), indentLevel) if ast.block
    when 'Mixin', 'Tag'
      if ast.block
        blockOptions = _.clone(options)
        if ast.textOnly
          result += '.'
          _.extend(blockOptions, NO_PREFIX)
        result += serializeAST(ast.block, blockOptions, indentLevel)

      # NOTE no indent need for code
      result += serializeAST(ast.code, options, 0) if ast.code
    when 'Include'
      result += serializeAST(ast.block, options, indentLevel) if ast.block
    when 'Extends', 'Attrs', 'Comment', 'Doctype', 'Literal', 'MixinBlock', 'Text'
      return result
    when 'NewLine'
      return undefined
    else
      throw new Error("Unexpected node type #{ast.type}")

  return result

module.exports = (ast, options = {}) ->
  console.log(inspect(ast, {depth: 20})) if options.debug
  serializeAST(ast, options)
