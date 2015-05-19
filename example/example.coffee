Renderer = require '../lib/ObjectRenderer'

renderer = new Renderer
  basePath: "../test/templates"

templates =
  text:
    dust: 'text.dust'
  html:
    jade: 'html.jade'
  fixedText: -> "Fixed text"
  templateFunction: (obj) -> "templateFunction " + obj.variable

values =
  variable: "Variable"

renderer.render templates, values, (err, content) ->
  console.log content.text # 'Text template: Variable'
  console.log content.html # '<p>HTML template: Variable</p>'
  console.log content.fixedText # "Fixed text"
  console.log content.templateFunction # "Fixed text"
