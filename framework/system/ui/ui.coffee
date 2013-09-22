window.layout =
  debug: is_debug 'layout'
  call_once: =>
    @scrollers = {}
    layout.add_scroller '.content'
    layout.add_scroller '.inner_content'
    layout.add_scroller '.scrollable'

  global_adjustments: =>
    slow = true

    layout.adjust_image_size '.size_adjustable'
    layout.checkbox()

    Scalator.parse_scallable_objects()

    layout.shrink_height()
    layout.shrink_width()

    layout.fill_parents_padding()
    layout.placeholder_styling()

    layout.labelize_placeholder '.labelized_placeholder'

    layout.horizontal_centralize '.horizontal_centralize'
    layout.vertical_centralize '.wm-checkbox,
      .vertical_centralize, [type=radio] ~ label,
      [type=checkbox] ~ label'

    Positioner.parse_positionable_objects()
    position_labels()
    layout.reset_scrollers()

    console.log "LO: Global Adjustments" if @debug

position_labels = () ->

#DEPRECATED: use positioner instead
positioner = () ->
  # This module is used to position elements relatively to others
  #
  # data-position-pos="position|[outset=true]|" -> bottom left
  #
  # data-position-pos="bottom" -> bottom left
  # data-position-pos="top right" -> top right
  # data-position-rel="selector" -> a selector to target element
  $('[data-position-pos]').each () ->
    t = $ this
    pos = t.attr "data-position-pos"
    rel = $ t.attr "data-position-rel"

    if rel.length == 0
      rel = $ '[name='+t.attr('for')+']' #can this be a label?

    if is_string pos
      if pos == 'bottom'
        layout.positionOnBottom t, rel
      else if pos == 'top'
        layout.positionOnTop t, rel

layout.adjust_image_size = (selector) ->
  $(selector).load (e) ->
    # FIX: Must cover the case with more images per wrapper
    img = $ e.target

    wrp = img.parent()

    img_prop = img.width() / img.height()
    wrp_prop = wrp.width() / wrp.height()

    if img_prop <= wrp_prop
      img.height wrp.height()
      img.width img.height() * img_prop
    else
      img.width wrp.width()
      img.height img.width() / img_prop

    img.fadeIn()

layout.search_icon = () ->
  input = $ '#search'
  icon = $ '#search_icon'

  os = input.offset()
  icon_os = {}
  icon_os.top = os.top + (input.outerHeight() - icon.height())/2
  icon_os.left = os.left + input.width() - icon.width()

  icon.offset icon_os

layout.add_scroller = (selector) =>
  @scrollers[selector] = new Scroller selector

layout.reset_scrollers = () ->
  # for selector, scroller of @scrollers
  #   scroller.reset()

layout.labelize_placeholder = (container) ->
  $('[data-placeholder]', $ container).each () ->
    t = $ this
    label = $ '[for='+t.attr('name')+']'

    if label.length > 0
      label.addClass 'tip_tool_label'
      layout.positionOnTop label, t
    else
      layout.positionOnTop $('<label class="tip_tool_label">'+t.attr('data-placeholder')+'</label>'), t

_placeholder_styling = (e) ->
  t = $ e.target
  if t.val() == ''
    t.removeClass 'not_empty'
  else
    t.addClass 'not_empty'

layout.placeholder_styling = ->
  # $('[placeholder]').live 'change', _placeholder_styling
  # $('[placeholder]').live 'keyup', _placeholder_styling
  # $('[placeholder]').live 'blur', _placeholder_styling

layout.checkbox = ->
  cbs = $ '[type=checkbox]:not(.wmcheckbox-ized, .hidden),
          [type=radio]:not(.wmcheckbox-ized, .hidden)'

  cbs.each () ->
    WMCheckbox.create $ this

layout.fill_parents_padding = ->
  $('.fill_parents_padding').each () ->
    t = $ this
    p = t.parent()
    t.height p.outerHeight()
    t.css 'margin-top', '-'+p.css('padding-top')
    t.css 'line-height', t.height()+'px'

layout.horizontal_centralize = (selector, method = 'margin') ->
  if method == 'margin'
    $(selector).each () ->
      $(this)
        .css('position', 'relative')
        .css('margin-left', -$(this).width()/1.9)
        .css('left', '50%')

  else if method == 'pos'
    $(selector).each () ->
      t = $ this
      p = t.parent()
      p_left = p.offset().left
      t.offset {left : p_left + p.outerWidth() / 2 - t.innerWidth()/2}

layout.vertical_centralize = (selector) ->
  $(selector).each () ->
    t = $ this
    p = t.parent()
    p_top = p.offset().top

    t.offset {top : p_top + p.outerHeight() / 2 - t.innerHeight()/2}

window.layout.width_full = ->
  $('.width_full').each ->
    fixed = $(this).children '.width_fixed'
    filler = $(this).children '.width_filler'

    fixed_total_width = 0
    for f in fixed
      fixed_total_width += $(f).outerWidth()

    remaining_width = $(this).width() - fixed_total_width

    fillers_width = remaining_width / filler.length
    filler.innerWidth fillers_width

window.layout.shrink_height = ->
  # Shrink height to fill parents.
  $('.shrink_height').each () ->
    t = $ this
    available_height = t.parent().innerHeight()
    used_by_siblings = 0
    t.siblings().each () ->
      u = $ this
      used_by_siblings += u.outerHeight()

    candidate_height = available_height - used_by_siblings
    unless candidate_height > t.outerHeight()
      t.outerHeight candidate_height

window.layout.shrink_width = ->
  # Shrink width to fill parents.
  $('.shrink_width').each () ->
    t = $ this
    available_width = t.parent().innerWidth()
    used_by_siblings = 0
    t.siblings().each () ->
      u = $ this
      used_by_siblings += u.outerWidth()

    candidate_width = available_width - used_by_siblings
    console.log candidate_width, available_width, used_by_siblings

    unless candidate_width > t.outerWidth()
      t.outerWidth candidate_width

window.layout.height_full = (elements = $('.height_full')) ->
  console.log 'told ia it isnt cald'
  elements.each ->
    console.log '----- layout . height_full -----' if layout.debug
    console.log 'Adjusting height for', $(this).outerHeight(), $(this) if layout.debug

    fixed = $(this).children '.height_fixed'
    filler = $(this).children '.height_filler, .line_height_filler'
    filler_shrink = filler.filter '.height_filler_shrink'

    fixed_total_height = 0
    for f in fixed
      console.log 'fixed_height_elem', $(f).outerHeight(), $(f) if layout.debug
      fixed_total_height += $(f).outerHeight()

    container_height = $(this).outerHeight()
    remaining_height = container_height - fixed_total_height

    fillers_height = remaining_height / filler.length

    filler_height_delta = Math.abs(filler.outerHeight() - fillers_height)

    min_height = filler.css 'min-height'

    if min_height? and min_height > fillers_height
      filler.outerHeight min_height
    else
      filler.outerHeight fillers_height

    console.log 'fillers height: ', filler, fillers_height if layout.debug

    console.log 'fixed total height', fixed_total_height if layout.debug
    console.log 'remaining height', remaining_height if layout.debug

    filler.each () ->
      if $(this).hasClass 'line_height_filler'
        $(this).css('line-height', $(this).height() + 'px')

    total_fixed_height = 0
    $('> *', this).each () ->
      total_fixed_height += $(this).outerHeight();

    #   This was removed because it was messing with height on "back",
    # if it should go back, please ensure good testing on "back"
    # navigation
    #
    # e = $(this)
    # while(e.attr('id') != 'content' and total_fixed_height > e.outerHeight())
    #   e.height total_fixed_height
    #   e = e.parent()

layout.blockContainer = (container) ->
  container.html JSV.common.ajax_loader()

layout.blockScreen = (msg = 'Please wait...') ->
  $('body').after(JSV.common.message msg, "loading")

  layout.vertical_centralize '.overlay_message_content'
  layout.vertical_centralize '.overlay_message_text'

layout.m = (text, type="error", callback = null) ->
  html = $ JSV.common.message text, type

  $('body').after html;

  layout.vertical_centralize '.overlay_message_content'

  # Ugly fix! Please come back here and review this shit
  html.one 'click', () ->
    html.one 'click', () ->
      callback() if callback?
      $(this).remove()

layout.defaultError = ->
  layout.m 'An error has ocurred'

layout.unblockScreen = ->
  $('#overlay').remove();

layout.positionOnTop = (element, target) ->
  target.before element
  fp = target.offset()

  if fp?
    element.offset
      top: fp.top - element.outerHeight()
      left: fp.left

layout.positionOnBottom = (element, target) ->
  target.after element
  fp = target.offset()

  if fp?
    element.offset
      top: fp.top + target.outerHeight()
      left: fp.left

layout.positionOnTopRight = (element, target) ->
  target.before element
  fp = target.offset()

  if fp?
    element.offset
      top: fp.top - element.height()
      left: fp.left + target.outerWidth() - element.outerWidth()

layout.icon_filler = (container) ->
