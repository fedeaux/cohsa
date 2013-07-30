@Navigation = 
  init: ->
    @current_view = '__map__'
    @navigating = false
    @debug = is_debug 'navigation'
    @route_stack = []
    @current_args = {}

    # Interface bindings should be somewhere else
    $(document).on 'click', '[data-navigation]', @navigation_handler

  refresh: () =>
    @follow_route @current_view, false, true

  is_current: (route) =>
    console.log 'NV: is_current?', @current_view, route if @debug
    @current_view == route

  is_map: (route) =>
    @current_view == '__map__'

  back: =>
    @follow_route '__back__', true

  show_map: =>
    @follow_route '__map__' unless @is_map()

  is_last_view: (route) =>
    return @last_view() == route

  last_view: () =>
    if @route_stack.length >= 2
      return @route_stack[@route_stack.length - 1]

  is_navigating: ->
    @navigating

  navigation_handler: (e) =>
    # Handle clicks on navigation elements. Should be somewhere else?

    #Avoid multiple clicks to generate misbehaviour
    if @is_navigating()
      console.log 'NV: Navigation denied on [navigation_handler]: ', @navigating if @debug
      return

    t = ensure $(e.target), '[data-navigation]'

    _current_args = t.attr 'data-navigation-args'
    @current_args = JSV.set_parse_args _current_args if _current_args?

    route = t.attr 'data-navigation'

    console.log 'NV: Navigation triggered: ', t, route if @debug

    @route_handler route

  is_show_map_route: (route) =>
    /^menu\..*/.test route

  route_handler: (route) =>
    # Given a route, decides what to do. Is a back? Is a reload?

    if @is_current route
      console.log 'NV: Refresh' if @debug
      if @is_show_map_route route
        @follow_route '__map__'
      else
        @follow_route route, false, true

    else if @is_last_view route
      console.log 'NV: is_last_view: ' if @debug
      @follow_route '__back__', true

    else
      console.log 'NV: not is_current and not is_last: ', route if @debug
      @follow_route route

  navigation_complete: () =>
    @navigating = false
    console.log 'NV: Navigation Complete ' if @debug

  follow_route: (route, back = false, refresh = false) =>
    #   Once it is decided how to follow a route, actually follows it.
    # Shouldnt this be the function to be called programatically?

    # Avoid multiple calls to generate misbehaviour
    if @is_navigating() and not back
      console.log 'NV: Navigation denied on [follow_route]: ', route, @navigating, back if @debug
      return

    @navigating = true

    console.log 'NV: Following route: '+route if @debug
    console.log 'NV: (As back)' if @debug and @back
    console.log 'NV: From: '+@current_view if @debug

    #From the map there is no "back", so the route_stack must be empty
    if route == '__map__'
      @route_stack = []

    else if route == '__back__'
      @follow_route @route_stack.pop(), true
      return

    #Don't keep track of backing routes
    else if route != '__back__' and not back
      @route_stack.push @current_view

    #_router.route returns a content object
    content = _router.route route, back, refresh

    #before_route must return true in order to cancel the transition
    if play_list(content.before_route)
      @current_view = @route_stack.pop() unless route == '__back__' or back
      @navigation_complete()
      return

    unless content.error_404?
      @_forward_current_view = route if route != '__back__'
      _v content
      @current_view = route if route != '__back__'
    else
      @current_view = @route_stack.pop()
      @navigation_complete()
      console.log 'Route: Route not found: '+route+'[', @routes,']' if @debug

    console.log 'NV: Route Stack:', @route_stack if @debug
