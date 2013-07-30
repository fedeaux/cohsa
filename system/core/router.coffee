class @Router
  @_routes = []

  constructor: () ->
    @debug = is_debug 'router'
    @routes = {}

    @parse_routes()

    # This should be injected by Setup.coffee
    @global_completes = [
      Navigation.navigation_complete
    ]

    # This should be injected by Setup.coffee
    @global_befores = [
      Form.init
      layout.global_adjustments
    ]

  @add: (routes) =>
    Router._routes.push routes

  parse_routes: () =>
    for func in Router._routes
      for name, route of func()
        @routes[name] = route

  def_html: (route) ->
    try
      f = eval 'JSV.'+route
      return f() if f?
    catch error
      return ''

  get_interface_bindings: (route) =>
    try
      f = eval 'InterfaceBindings.'+route
      return f if f?
    catch error
      return null

  get_route: (route) =>
    unless @routes[route]?
      content = ContentFactory.make {}, @def_html route
    else
      content = ContentFactory.make @routes[route], @def_html route

    interface_bindings = @get_interface_bindings route
    content.complete.push interface_bindings if interface_bindings?
    return content

  route: (route, back = false, refresh = false) =>
    console.log '[R] route:', route if @debug

    content = @get_route route

    if back
      content.context = 'back'
    else if refresh
      content.context = 'refresh'

    Array::push.apply content.complete, @global_completes
    Array::push.apply content.before, @global_befores

    content
