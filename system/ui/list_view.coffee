class @ListView
  close: () =>
    @args.onClose @list_overlay

  get: () =>
    @list_view

  constructor: (@args) ->
    id = 'list-view-container-'+unique_id()

    default_args = {
      add_class: ''
      container: 'body'
      close_politics: 'fade'
    }

    for name, value of default_args
      @args[name] = @args[name] || value

    list = $ '<div class="list-view">
              </div>'

    @list_overlay = $ '<div class="list-view-overlay '+@args.add_class+'">
                      </div>'

    list_wrapper = $ '<div class="list-view-html-wrapper scroll-y">
                      </div>'

    @list_view = $ '<div id="'+id+'"
                          class="list-view-container">
                       </div>'

    list_wrapper.append list

    @list_view.append list_wrapper

    list.html @args.html

    @list_overlay.append @list_view
    $(@args.container).append(@list_overlay)

    if @args.title
      @list_view.prepend('<div class="list-view-header width_full">
        '+@args.title+'
      </div>')
    else
      list_wrapper.addClass 'list-view-no-header'

    @list_view.append('<div class="actions width_full list-view-close list-view-action-close">
          CLOSE
        </div>')

    ListView.configuration.after_show() if is_function ListView.configuration.after_show
    @args.after_show() if is_function @args.after_show

    unless @args.onClose?
      @args.onClose = (ls) =>
        if @args.close_politics == 'fade'
          ls.fadeOut()
        else
          ls.remove()

    $('.list-view-action-close').click () =>
      @close()

    @args.on_show() if is_function @args.on_show
