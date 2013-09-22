class @Scroller
  constructor: (@selector) ->
    @is_touch = false
    try
      document.createEvent("TouchEvent")
      @is_touch = true

    #if(@isTouchDevice() and navigator.userAgent.match(/Android/i))
    #$(@selector).live 'touchstart', @_start_scrolling
    #$(@selector).live 'touchmove', @_scroll
    #$(@selector).live 'touchend', @finish_scrolling

    #$(@selector).live 'mousedown', @start_scrolling
    #$(@selector).live 'mousemove', @scroll
    #$(@selector).live 'mouseup', @finish_scrolling

  isTouchDevice: () ->
    @is_touch

  _scroll: (e) =>
    e.preventDefault()

    if e.originalEvent?
      e = e.originalEvent

    @scroll e

  _start_scrolling: (e) =>
    if e.originalEvent?
      e = e.originalEvent

    @is_touch = true
    @start_scrolling e

  start_scrolling: (e) =>
    @scrollable = $ @selector
    console.log @scrollable, @scrollable[0].scrollTop

    @current_position = e.pageY + @scrollable[0].scrollTop
    @scrollable.css 'position', 'relative'
    @min_top = @scrollable.parent().innerHeight() - @scrollable.height()

  finish_scrolling: (e) =>
    @scrollable = null
    @hide_scrollbar()

  hide_scrollbar: () =>
    @scrollbar?.fadeOut()

  is_scrolling: () =>
    _mouse.is_down()

  eval_scrollbar_height: () =>
    @scrollable.parent().height()*@scrollable.parent().height() / @scrollable.height()

  eval_scrollbar_top_function: () =>
    y0 = @scrollable.parent().offset().top

    b = y0
    a = (@scrollable.parent().height() - @scrollbar.height())/
        (@scrollable.height() - @scrollable.parent().height())

    (new_top) =>
      D = - new_top
      a*D + b

  add_scrollbar: () =>
    unless $('.scroller-scrollbar', @selector).length > 0
      @scrollbar = $ '<div class="scroller-scrollbar"> &nbsp; </div>'
      
      @scrollbar.height @eval_scrollbar_height()
      @scrollbar.f = @eval_scrollbar_top_function()

      $(@selector).append @scrollbar
    else
      @scrollbar.fadeIn()

  scrollbar_content_scrolled: (new_top, dx) =>
    @scrollbar.offset { top: @scrollbar.f new_top }

  on_scroll: (new_top, dx) =>
    @add_scrollbar()
    @scrollbar_content_scrolled new_top, dx

  scroll: (e) =>
    if @scrollable? #@is_scrolling() or @isTouchDevice
      # dx = @current_position - e.pageY

      # top = parseInt @scrollable.css('top').replace 'px', ''
      # top = 0 if isNaN top
      # new_top = top - dx

      console.log @current_position + e.pageY, @current_position, e.pageY
      @scrollable[0].scrollTop = @current_position + e.pageY

      # unless new_top > 0 or new_top < @min_top
      #   @current_position -= dx
      #   if @scrollable.parent().css('position') == 'absolute'
      #     @scrollable.offset(top: new_top)
      #   else
      #     @scrollable.css 'top', new_top+'px'

      #   @on_scroll new_top, dx

      e.preventDefault()
      return false

  reset: () =>
    @scrollable = null
    @scrollable = $(@selector)
