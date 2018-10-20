# node-object-renderer@1.0.0
## !!! This package is no longer maintained !!!
A node module to render all properties of an object individually from files and functions to strings.
All renderers that are supported by [consolidate][consolidate] are supported by this module, too.

Define a validator by combining rules:
```coffeescript
values =
  email: "john@doe.com"
  firstName: "John"
  lastName: "Doe"
  link: "http://www.example.com/ResetPasswordLink"

templates =
  to: (values) -> values.email
  subject: -> "Example.com password reset request"
  text: jade: "textTemplate"

new ObjectRenderer({basePath: "templates"}).render(templates, values).done(console.log)
result =
  to: "john@doe.com"
  subject: "Example.com password reset request"
  text: "Hello John, [...]"
```

## API

The module can be required via node's require, or as an AMD module via requirejs. 
There is a [codo][codo] created documentation in the doc folder with more details.

### Constructor options

**basePath**: A base path to be added whenever a template is loaded. Default: ""
**addExtensions**: If true the engine name will be added as an extension to each template name. Default: true

### render
Render the properties of the template object to strings. The resulting  object has the same keys
as the templates object set in the constructor.
```templates``` needs to be an object with each property either being an object ```{engine: templatePath}```,
or a rendering function ```([Object] values) -> [String] rendered template```
render can either be called with a callback, or, if called without, will return a promise.


[codo]: https://github.com/coffeedoc/codo
[consolidate]: https://github.com/tj/consolidate.js
