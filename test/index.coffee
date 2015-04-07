fs = require('fs')
path = require('path')
Q = require('q')
_ = require('lodash')
{assert} = require('chai')
parse = require('jade-parser')
lex = require('jade-lexer')
walk = require('jade-walk')
lib = require('../')

casesPath = "#{__dirname}/cases"

dirfile = (f) -> path.join(casesPath, f)
readFile = (f) -> fs.readFileSync(dirfile(f), 'utf8')
writeFile = (f, content) -> fs.writeFileSync(dirfile(f), content, 'utf8')

cases = _.filter fs.readdirSync(casesPath), (testCase) ->
  not /\.generated/.test(testCase) and
  /\.jade$/.test(testCase) and
  # TODO: support inline-tag
  testCase isnt 'inline-tag.jade'

stripUnsupportedProperties = (ast) ->
  walk ast, (node, replace) -> replace(_.omit(node, 'line', 'selfClosing'))

describe 'cases', ->
  _.each cases, (testCase, i) ->
    describe "#{i}. #{testCase}:", ->
      it "resulting source should have the same ast as the original", ->
        ast = parse(lex(readFile(testCase), testCase))
        result = lib(ast)
        writeFile(testCase.replace('.jade', '.generated.jade'), result)
        newAst = parse(lex(result, testCase))

        assert.deepEqual stripUnsupportedProperties(ast), stripUnsupportedProperties(newAst)
