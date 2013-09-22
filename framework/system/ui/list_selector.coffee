# TODO
# Dependency injection througt hooks
#   1. "afterShow" to call for layout
#
# Allow multiple instances
#
# If html_unselect isnt set, copy from html_selected

class @ListSelector
  constructor: (input, @args, options) ->

    #This dependency should be injected here
    #document.addEventListener("backbutton", @close_list_selector, false)

    if ListSelector.show_if_exists input
      return

    id = 'list-selector-container-'+unique_id()

    input.attr 'data-list-selector-id', '#'+id
    input.blur()

    default_args = {
      add_class: ''
      container: 'body'
      filter: false
      mode: 'multiple'
      display: '.list-selector-display'
      value: '.list-selector-values'
      close_politics: 'fade'
      sort: false
      html_controller: '<div class="actions width_full list-selector-controller">
          <div class="width_filler ok list-selector-select-button">
             SELECT
          </div>
        </div>'
    }

    unless @args?
      # If args is null, consider searching for args sources on the markup
      @args = JSON.parse input.siblings('.list-selector-args-source').html()

    unless options?
      # If options is null, consider searching for options sources on the markup
      options = @normalize_options JSON.parse input.siblings('.list-selector-options-source').html()

    if @args.sort
      options = @sort options

    for name, value of default_args
      @args[name] = @args[name] || value

    list = $ '<ul class="'+@args.add_class+' list-selector">
              </ul>'

    list_wrapper = $ '<div class="list-selector-list-wrapper scroll-y">
                      </div>'

    @list_selector = $ '<div id="'+id+'"
                          class="list-selector-container">
                       </div>'

    list_wrapper.append list
    @list_selector.append list_wrapper
    # Option Structure
    # html_unselected: "",
    # html_selected: "",
    # selected: bool,
    # value: mixed

    for option in options
      if option.selected? and option.selected
        _class = 'selected'
      else if option.disabled? and option.disabled == true
        _class = 'disabled'
      else
        _class = 'unselected'

      list.append $ '<li
                         id="list-selector-value-'+option.value+'"
                         data-list-selector-value="'+option.value+'"
                         data-list-selector-display="'+option.display+'"
                         class="list-selector-state-'+_class+' list-selector-option" >'+
                       '<span class="list-selector-option-selected">'+
                         option.html_selected+
                       '</span>'+
                       '<span class="list-selector-option-unselected">'+
                         option.html_unselected+
                       '</span>'+
                    '</li>'

    @list_selector.append(@args.html_controller)
    $(@args.container).append(@list_selector)

    @args.on_create() if is_function @args.on_create
    layout.width_full() # Must go somewhere else

    unless @args.onSelect?
      @args.onSelect = (values, displays) =>
        $(@args.value).val values.toString()

        if displays.length > 0
          $(@args.display).val displays.reduceRight (x, y) -> x + ", " + y
          $(@args.display) #GATO GATO GATO
            .addClass('input_active')
            .removeClass('input_blured')
        else
          $(@args.display).val $(@args.display).attr 'data-placeholder'
          $(@args.display) #GATO GATO GATO
            .addClass('input_blured')
            .removeClass('input_active')

    unless @args.onClose?
      @args.onClose = @close_list_selector

    $('.list-selector-option', @list_selector).click @toggle_selection

    $('.list-selector-select-button', @list_selector).click () =>
      values = []
      displays = []
      $('.list-selector-state-selected', @list_selector).each () ->
        values.push $(this).attr 'data-list-selector-value'
        displays.push $(this).attr 'data-list-selector-display'

      @args.onSelect(values, displays)
      @args.onClose(@list_selector)

    $('.list-selector-close-button', @list_selector).click () =>
      @args.onClose(@list_selector)

  @show_if_exists: (input) ->
    ls = $ input.attr 'data-list-selector-id'

    if ls.length == 1
      ls.fadeIn()
      return true

  toggle_selection: (e) =>
    t = ensure $(e.target), '.list-selector-option'

    if t.is '.list-selector-state-disabled'
      return false

    if @args.mode == 'single'
      $('.list-selector-state-selected', t.parent())
        .removeClass('list-selector-state-selected')
        .addClass('list-selector-state-unselected')

    t.toggleClass 'list-selector-state-selected list-selector-state-unselected'

    e.preventDefault()
    e.stopPropagation()
    return false

  close_list_selector: (ls) =>
    if @args.close_politics == 'fade'
      ls.fadeOut()
    else
      ls.remove()

  make_option_obj: (arg) =>
    _opt = {
      html_selected: '<span>'+arg+'</span>'
      html_unselected: '<span>'+arg+'</span>'
      selected: arg in @args.previously_selected_values
      value: arg
      display: arg
    }

    unless is_string arg #is object
      for key, val of arg
        _opt[key] ?= val

    return _opt

  normalize_options: (_options) =>
    @args.previously_selected_values = ($.trim v for v in $(@args.value).val().split(','))

    options = (@make_option_obj d for d in _options)
    options ?= []
    return options

  get: () =>
    @list_selector

  sort: (options) ->
    if @args.sort == 'disabled_last'
      options.sort (a, b) ->
        if a.disabled and ! b.disabled
          return 1
        else if ! a.disabled and b.disabled
          return -1
        return 0

    options
