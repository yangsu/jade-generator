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

cases = _.filter fs.readdirSync(casesPath), (testCase) -> not /\.generated/.test(testCase)

stripLineNumbers = (ast) ->
  walk ast, (node, replace) -> replace(_.omit(node, 'line'))

describe 'cases', ->
  start = 2
  end = start + 1
  _.each cases[start...end], (testCase) ->
    describe "#{testCase}:", ->
      it "resulting source should have the same ast as the original", ->
        content = readFile(testCase)
        {ast, source, result} = lib(testCase, content)
        writeFile(testCase.replace('.jade', '.generated.jade'), result)
        # console.log result
        newAst = parse(lex(result, testCase))

        assert.deepEqual stripLineNumbers(ast), stripLineNumbers(newAst)
