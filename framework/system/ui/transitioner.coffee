class @Transitioner
  _instance = null

  @get: ->
    window._transitioner ?= new Transitioner

  constructor: ->
    @debug = is_debug 'transitioner'
    @default_time = 500

  register_on_complete_callback: (target, complete) =>
    target.one 'webkitTransitionEnd transitionend', () ->
      play_list complete

  pre: ->
    # This should be injected here
    layout.global_adjustments()
    Form.init()

  cross_fade: (o_el, n_el, container, before, complete) =>
    console.log 'TR: cross fade' if @debug

    container.append n_el
    o_el.hide()
    play_list before
    play_list complete
    o_el.remove()

  slide_up: (o_el, n_el, container, before, complete) =>
    console.log 'TR: slide up' if @debug

    container.append n_el

    play_list(before)

    complete.push () ->
      n_el.removeClass 'current_page slider hide_bottom'

    @register_on_complete_callback n_el, complete

    n_el_h = n_el.height()
    c_h = container.height()
    n_el.width n_el.width()

    n_el.prev_post = n_el.css 'position'
    n_el.css 'position', 'absolute'

    o_el.height o_el.height()
    n_el.height n_el.height()

    n_el.addClass 'hide_bottom'
    n_el.show()
    n_el.css 'z-index', '3000'
    n_el.addClass 'slider'

    n_el.addClass 'current_page'

  slide_down: (o_el, n_el, container, before, complete) =>
    console.log 'TR: slide down' if @debug

    play_list(before)

    complete.push () ->
      o_el.remove()

    @register_on_complete_callback o_el, complete

    n_el.css 'position', 'absolute'

    o_el.addClass 'slider'
    o_el.addClass 'hide_bottom'

  slide_left: (o_el, n_el, container, before, complete) =>
    console.log 'TR: slide left' if @debug

    container.append n_el

    play_list(before)

    complete.push () ->
      o_el.remove()
      n_el.removeClass 'current_page slider hide_right'

    @register_on_complete_callback n_el, complete

    n_el.addClass 'hide_right'

    o_el.css 'z-index', (n_el.css 'z-index') - 1

    n_el.addClass 'slider'
    n_el.addClass 'current_page'

  slide_right: (o_el, n_el, container, before, complete) =>
    console.log 'TR: slide right' if @debug
    curr_offset = o_el.offset()

    container.prepend n_el

    n_el.css 'position', 'absolute'
    
    play_list(before)

    complete.push () ->
      o_el.remove()

    @register_on_complete_callback o_el, complete

    o_el.offset curr_offset
    o_el.addClass 'slider'
    o_el.addClass 'hide_right'
