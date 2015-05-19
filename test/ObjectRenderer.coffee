chai = require 'chai'
chai.use require 'chai-as-promised'
expect = chai.expect
When = require 'when'
path = require 'path'

requirejs = require 'requirejs'
requirejs.config
  baseUrl: 'lib'

Renderer = require '../lib/ObjectRenderer'

describe "An ObjectRenderer", ->
  renderer = null
  templates = null
  values = null
  expectedResult = null

  beforeEach ->
    renderer = new Renderer
      basePath: "test/templates"
    templates =
      text:
        dust: 'text'
      html:
        jade: 'html'
      fixedText: -> "Fixed text"
      templateFunction: (obj) -> "templateFunction " + obj.variable
    values =
      variable: "Variable"
    expectedResult =
      text: 'Text template: Variable'
      html: '<p>HTML template: Variable</p>'
      fixedText: "Fixed text"
      templateFunction: "templateFunction Variable"

  it "can be required via requirejs", (done) ->
    requirejs ['ObjectRenderer'], (ObjectRendererLoaded) ->
      expect(ObjectRendererLoaded).to.exist
      done()

  it "throws an error if the given templates object is not an object", ->
    templates = 10
    expect(-> renderer.render(templates, values, ->)).to.throw TypeError, "templates should be an object, is " + typeof templates + " instead"

  it "throws an error if any property of the object is neither a template object nor a function", ->
    templates =
      a: "stringA"
      b: ->
      c: ->
    expect(-> renderer.render(templates, values, ->)).to.throw TypeError, "templates should be an object of functions and template objects"

  it "throws an error if any template object has more than 1 key", ->
    templates =
      a:
        1: 1
        2: 2
    expect(-> renderer.render(templates, values, ->)).to.throw TypeError, "a should be of length 1"

  it "throws an error if any template object has no key", ->
    templates =
      a: {}
    expect(-> renderer.render(templates, values, ->)).to.throw TypeError, "a should be of length 1"

  it "throws an error if any template object has a key that is not a renderer", ->
    templates =
      a: xwer: ""
    expect(-> renderer.render(templates, values, ->)).to.throw TypeError, "xwer isn't a renderer engine supported by consolidate"

  it "accepts a list of renderer functions", ->
    templates =
      b: ->
      c: ->
    expect(-> renderer.render(templates, values, ->)).not.to.throw

  it "accepts a list of template objects", ->
    templates =
      b:
        "jade": "template"
      c:
        "dust": "template"
    expect(-> renderer.render(templates, values, ->)).not.to.throw

  it "renders an object as a promise", ->
    expect(renderer.render templates, values).to.eventually.deep.equal expectedResult

  it "renders an object via callback", (done) ->
    renderer.render templates, values, (err, content) ->
      expect(content).to.deep.equal expectedResult
      done()

  it "does not add extensions if turned off", ->
    renderer = new Renderer
      basePath: "test/templates"
      addExtensions: false
    templates =
      text:
        dust: 'text.dust'
      html:
        jade: 'html.jade'
      fixedText: -> "Fixed text"
      templateFunction: (obj) -> "templateFunction " + obj.variable
    expect(renderer.render templates, values).to.eventually.deep.equal expectedResult
