class @DummyTransitioner
  _instance = null

  @get: ->
    window._transitioner ?= new DummyTransitioner

  constructor: ->
    @debug = is_debug 'transitioner'
    @default_time = 500

  pre: ->
    layout.global_adjustments()
    Form.init()

  replace: (o_el, n_el, container, before, complete, original) =>
    container.prepend n_el
    play_list before

    unless original == 'slide_up'
      o_el.remove()

    n_el.show()
    play_list complete

  cross_fade : (o_el, n_el, container, before, complete) =>
    @replace(o_el, n_el, container, before, complete, 'cross_fade')

  slide_right : (o_el, n_el, container, before, complete) =>
    @replace(o_el, n_el, container, before, complete, 'slide_right')

  slide_up: (o_el, n_el, container, before, complete) =>
    @replace(o_el, n_el, container, before, complete, 'slide_up')

  slide_down: (o_el, n_el, container, before, complete) =>
    @replace(o_el, n_el, container, before, complete, 'slide_down')

  slide_left: (o_el, n_el, container, before, complete) =>
    @replace(o_el, n_el, container, before, complete, 'slide_left')