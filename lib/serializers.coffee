_ = require('lodash')

parenthesize = (str) -> "(#{str})"
escapeQuotes = (str) -> str.replace(/"/g, "\\\"")
unescapeQuotes = (str) -> str.replace(/\\"/g, "\"")
stripQuotes = (str) -> str.replace(/^(["'])(.+)\1$/g, '$2')

serializeAttributes = (attributes) ->
  needsAttrsBlock = false
  attrs = []
  attrsBlock = []

  pushAttrsBlock = (attr) ->
    unless needsAttrsBlock
      needsAttrsBlock = true
      attrs.push attrsBlock

    attrsBlock.push attr

  _.each attributes, (attr) ->
    if attr.val is true
      return pushAttrsBlock attr.name
    else if attr.escaped is true
      return pushAttrsBlock "#{attr.name}=#{attr.val}"
    else if attr.escaped is false
      if _.isString(attr.val)
        val = stripQuotes(attr.val)
        if attr.name is 'class'
          return attrs.push ".#{val}"
        else if attr.name is 'id'
          return attrs.push "##{val}"

    throw new Error("WTF: #{attr}")

  attrs = _.map attrs, (attrOrAttrBlock) ->
    if _.isArray(attrOrAttrBlock)
      parenthesize(attrOrAttrBlock.join(', '))
    else
      attrOrAttrBlock

  return attrs.join('')


serializeAttributeBlocks = (attributeBlocks) ->
  "&attributes#{parenthesize(attributeBlocks.join(', '))}"

getVal = (node) -> node.val

# exports.NamedBlock = getVal
exports.Block = getVal
# exports.Case = getVal
# exports.Each = getVal
# exports.Mixin = getVal

# exports.When = getVal
exports.Code =  _.flow getVal, (code) -> "- #{code}"
# exports.Extends = getVal
# exports.Include = getVal
# exports.Attrs = getVal
# exports.BlockComment = getVal
exports.Comment = (comment) ->
  if comment.buffer
    "//#{comment.val}"
  else
    "//-#{comment.val}"
# exports.Doctype = getVal
# exports.Filter = getVal
# exports.Literal = getVal
# exports.MixinBlock = getVal
exports.Text = _.flow getVal, (text) -> if text.length then "| #{text}" else text
exports.Tag = (node) ->
  str = node.name
  str += serializeAttributes node.attrs
  if node.attributeBlocks?.length
    str += serializeAttributeBlocks node.attributeBlocks
  return str
# exports.Mixin = getVal
