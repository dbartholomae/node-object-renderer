((modules, factory) ->
  # Use define if amd compatible define function is defined
  if typeof define is 'function' && define.amd
    define modules, factory
  # Use node require if not
  else
    module.exports = factory (require m for m in modules)...
)( ['path', 'when', 'when/keys', 'consolidate'], (pathLib, When, whenKeys, consolidate) ->
  # Renders an object of templates. Each entry must either be an engine object
  # {engine: templatePath} or a rendering function ([Object] values) -> [String] rendered template
  #
  # @example
  #   values =
  #     email: "john@doe.com"
  #     firstName: "John"
  #     lastName: "Doe"
  #     link: "http://www.example.com/ResetPasswordLink"
  #
  #   templates =
  #     to: (values) -> values.email
  #     subject: -> "Example.com password reset request"
  #     text: jade: "textTemplate"
  #
  #   new ObjectRenderer({basePath: "templates"}).render(templates, values).done(console.log)
  #   result =
  #     to: "john@doe.com"
  #     subject: "Example.com password reset request"
  #     text: "Hello John, [...]"
  #
  class ObjectRenderer

    # Create a new ObjectRenderer.
    #
    # @param [Object] (options) Optional set of options
    # @option options [String] basePath A base path to append to all templates. Default: ""
    # @option options [Boolean] addExtensions add ".{engine}" to all templatePaths in templateObjects {engine: templatePath}. Default: true
    constructor: (@options) ->
      @options ?= {}
      @options.basePath ?= ""
      @options.addExtensions ?= true

    # Render the properties of the template object to strings. The resulting
    # object has the same keys as the templates object set in the constructor.
    # templates needs to be an object with each property either being an
    # object {engine: templatePath}, or a rendering function
    # ([Object] values) -> [String] rendered template
    # render can either be called with a callback, or, if called without,
    # will return a promise.
    #
    # @overload render(templates, values, callback)
    #   @param [Object] templates The template object
    #   @param [Object] values The values to render
    #   @param [Function] callback The callback to call with (err, result)
    #
    # @overload render(templates, values)
    #   @param [Object] templates The template object
    #   @param [Object] values The values to render
    #   @return [Object] A promise for an object containing the rendered strings
    # @throw "templates should be an object, is " + typeof templates + " instead"
    # @throw keys " should be of length 1"
    # @throw key " isn't a renderer engine supported by consolidate"
    # @throw templates should be an object of functions and template objects
    render: (templates, values, callback) ->
      if typeof values is 'function'
        callback = values
        values = null

      unless typeof templates == "object"
        throw new TypeError "templates should be an object, is " + typeof templates + " instead"
      for key, template of templates
        if typeof template is 'object'
          keys = Object.keys template
          if keys.length isnt 1
            throw new TypeError key + " should be of length 1"
          else unless consolidate[keys[0]]?
            throw new TypeError keys[0] + " isn't a renderer engine supported by consolidate"
        else unless typeof template is 'function'
          throw new TypeError "templates should be an object of functions and template objects"

      obj = {}
      for key, template of templates
        obj[key] =
          if typeof template is "object"
            (for engine, path of template
              When.promise (resolve, reject) =>
                templatePath = pathLib.join @options.basePath, path + if @options.addExtensions then "." + engine else ""
                consolidate[engine] templatePath, values, (err, content) ->
                  return reject err if err
                  resolve content
            )[0]
          else template(values)
      promise = whenKeys.all obj

      if callback
        promise.done ((result) -> callback null, result), ((err) -> callback err)
      else
        return promise
)