_ = require('lodash')

parenthesize = (str) -> "(#{str})"
escapeQuotes = (str) -> str.replace(/"/g, "\\\"")
unescapeQuotes = (str) -> str.replace(/\\"/g, "\"")
stripQuotes = (str) -> str.replace(/^(["'])(.+)\1$/g, '$2')

serializeAttributes = (attrs) ->
  groupedByEscaped = _.groupBy attrs, 'escaped'
  unescaped = _.map groupedByEscaped.false, (attr) ->
    val = stripQuotes(attr.val)
    if attr.name is 'class'
      return ".#{val}"
    else if attr.name is 'id'
      return "##{val}"
    else
      return "WTF: #{val}"
  escaped = _.map groupedByEscaped.true, (attr) -> "#{attr.name}=#{attr.val}"

  return "#{unescaped.join('')}#{parenthesize(escaped.join(', '))}"


getVal = (node) -> node.val

# exports.NamedBlock = getVal
exports.Block = getVal
# exports.Case = getVal
# exports.Each = getVal
# exports.Mixin = getVal

# exports.When = getVal
# exports.Code = getVal
# exports.Extends = getVal
# exports.Include = getVal
# exports.Attrs = getVal
# exports.BlockComment = getVal
# exports.Comment = getVal
# exports.Doctype = getVal
# exports.Filter = getVal
# exports.Literal = getVal
# exports.MixinBlock = getVal
exports.Text = _.flow getVal, (s) -> " #{s}"
exports.Tag = (node) ->
  str = node.name
  str += serializeAttributes node.attrs
  return str
# exports.Mixin = getVal
