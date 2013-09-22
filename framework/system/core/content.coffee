class @ContentFactory
  @make: (args, def_html) ->
    defs =
      html: def_html
      before_route: []
      before: []
      complete: []
      menu: null
      context: 'show_content'

    content = {}

    for key, val of defs
      if args[key]?
        content[key] = copy args[key]
      else
        content[key] = val

    content.html = content.html?() ? content.html

    unless content.html?
      content.error_404 = true

    content
