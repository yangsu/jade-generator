_ = require('lodash')

parenthesize = (str = '') -> "(#{str})"
stripQuotes = (str) -> str.replace(/^(["'])(.+)\1$/g, '$2')

escapedKeyValueAttr = (attr) -> "#{attr.name}=#{attr.val}"
keyValueAttr = (attr) -> "#{attr.name}!=#{attr.val}"

unwrapConditionals = (cond) ->
  cond
    .replace(/^if\s*\(\s*!\s*\(\s*(.+)\s*\)\s*\)$/, 'unless $1')
    .replace(/^(if|while)\s*\(\s*(.+)\s*\)$/, '$1 $2')

serializeAttributes = (attributes) ->
  return '' if attributes?.length is 0
  needsAttrsBlock = false
  attrs = []
  attrsBlock = []

  pushAttrsBlock = (attr) ->
    unless needsAttrsBlock
      needsAttrsBlock = true
      attrs.push attrsBlock

    attrsBlock.push attr

  pushSpecialAttr = (attr, prefix) ->
    val = stripQuotes(attr.val)
    if /^[\w-]+$/.test(val)
      attrs.push prefix + val
    else
      pushAttrsBlock keyValueAttr(attr)

  _.each attributes, (attr) ->
    if attr.val is true
      return pushAttrsBlock attr.name
    else if attr.escaped is true
      return pushAttrsBlock escapedKeyValueAttr attr
    else if attr.escaped is false
      if _.isString(attr.val)
        if attr.name is 'class'
          return pushSpecialAttr attr, '.'
        else if attr.name is 'id'
          return pushSpecialAttr attr, '#'
        else
          return pushAttrsBlock keyValueAttr attr

    throw new Error("unknown attribute: #{attr}")

  attrs = _.map attrs, (attrOrAttrBlock) ->
    if _.isArray(attrOrAttrBlock)
      parenthesize(attrOrAttrBlock.join(', '))
    else
      attrOrAttrBlock

  return attrs.join('')


serializeAttributeBlocks = (attributeBlocks) ->
  if attributeBlocks?.length
    "&attributes#{parenthesize(attributeBlocks.join(', '))}"
  else
    ''

exports.Block = (node) -> if node.yield then 'yield' else ''

exports.BlockComment = (node) -> if node.buffer then '//' else '//-'

exports.Case = (node) -> "case #{node.expr}"

exports.Code =  (node) ->
  val = node.val
  prefix = if 'buffer' of node and 'escape' of node
    if node.buffer then (if node.escape then '=' else '!=') else '-'
  else
    val = unwrapConditionals(val)
    ''

  if prefix.length
    "#{prefix} #{val}"
  else
    val


exports.Comment = (node) ->
  if node.buffer
    "//#{node.val}"
  else
    "//-#{node.val}"

exports.Doctype = (node) ->
  if node.val then "doctype #{node.val}" else "doctype"

exports.Each = (node) ->
  "for #{node.val}, #{node.key} in #{node.obj}"

exports.Extends = (node) -> "extends #{node.path}"

exports.Filter = (node) ->
  ":#{node.name}#{serializeAttributes(node.attrs)}"

exports.Include = (node) ->
  filter = if node.filter then ":#{node.filter}" else ''
  attrs = serializeAttributes(node.attrs)
  "include#{filter}#{attrs} #{node.path}"

exports.Mixin = (node) ->
  str = ''
  if node.call
    if node.args is null
      str += "mixin #{node.name}"
    else
      str += "+#{node.name}"
  else
    str += "mixin #{node.name}"

  str += parenthesize(node.args) if _.isString(node.args)
  str += serializeAttributes(node.attrs)
  str += serializeAttributeBlocks(node.attributeBlocks)
  str

exports.MixinBlock = (node) -> 'block'

exports.NamedBlock = (node) ->
  if node.mode is 'replace'
    "block #{node.name}"
  else if node.mode is 'append'
    "append #{node.name}"
  else if node.mode is 'prepend'
    "block prepend #{node.name}"
  else
    throw new Error("unknown NamedBlock: #{node}")

exports.NewLine = -> ''

exports.Tag = (node) ->
  str = if node.buffer then "\#{#{node.name}}" else node.name
  str += serializeAttributes(node.attrs)
  str += serializeAttributeBlocks(node.attributeBlocks)
  str += '/' if node.selfClosing
  return str

exports.Text = (text, options) ->
  text = text.val
  if text.length and not options.noPrefix
    "| #{text}"
  else
    text

exports.When = (node) -> "when #{node.expr}"
