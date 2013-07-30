@Setup =
  export: window

  interface_bindings: () ->

  initialize_function: (init) ->
    if is_pg()
      document.addEventListener 'deviceready', (() -> init('Phonegap')), false

    else
      $ () ->
        init('Browser') 

  layout: () ->
    Setup.export._mouse = new Mouse()

  core: () ->
    Navigation.init()
    Validator.init()

    Setup.export._db = new Database
    Setup.export._router = new Router

  models: (args) ->

  cache: () ->
