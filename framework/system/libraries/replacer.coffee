# Reference jQuery
$ = jQuery

# Adds plugin object to jQuery
$.fn.extend
  replace: (content) ->
    debug = is_debug 'replacer'
    _t = Transitioner.get()

    if is_string content
      html = content
    else
      html = content.html

    # Insert magic here.
    return @each (i, _container)->
      container = $ _container

      n_el = $ html #create new element
      o_el = $ "#"+container.attr('data-content') #get current element

      console.log '[Replacer] context:', content.context if debug

      if content.context == 'show_map'
        _t.slide_down o_el, n_el, container, content.before, content.complete

      else if content.context == 'show_content'
        if _nav.is_map()
          _t.slide_up o_el, n_el, container, content.before, content.complete
        else
          _t.slide_left o_el, n_el, container, content.before, content.complete

      else if content.context == 'back'
        _t.slide_right o_el, n_el, container, content.before, content.complete

      else if content.context == 'refresh'
        _t.cross_fade o_el, n_el, container, content.before, content.complete

      container.attr 'data-content', n_el.attr 'id'