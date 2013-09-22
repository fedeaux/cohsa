@Positioner = {
  # Pos args are Vertical | Horizontal, like tl or br.
  # say: "TOP LEFT"
  configure : () ->

  get_base_offset: (element, pos_arg) ->
    base_offset = element.offset()

    width = element.width()
    height = element.height()

    if pos_arg[0] == 'm'
      base_offset.top += height/2
    else if pos_arg[0] == 'b'
      base_offset.top += height

    if pos_arg[1] == 'c'
      base_offset.left += width/2
    else if pos_arg[1] == 'r'
      base_offset.left += width

    base_offset

  get_steps : (element) ->
    {h_step : element.width() / 2, v_step : element.height() / 2}

  get_final_offset : (base_offset, steps, position) ->
    _position = position.join()

    n_rights = _position.split('r').length - 1
    n_centers = _position.split('c').length - 1
    n_lefts = _position.split('l').length - 1

    n_tops = _position.split('t').length - 1
    n_middles = _position.split('m').length - 1
    n_bottons = _position.split('b').length - 1

    add_top = (n_bottons - n_tops - 1)*steps.v_step
    add_left = (n_rights - n_lefts - 1)*steps.h_step

    {top : base_offset.top + add_top, left : base_offset.left + add_left}

  set_position : (element, relative_to, position) ->
    base_offset = @get_base_offset relative_to, position[0]
    steps = @get_steps element
    final_offset = @get_final_offset base_offset, steps, position.slice(1, position.length)

    element.offset final_offset

  get_new_offset : (element, relative_to, position) ->
    if @is_side position
      return @get_side_position element, relative_to, position

  get_side_position : (element, relative_to, position) ->
    if @is_bottom_side position
      return @get_bottom_side_position element, relative_to, position

  get_bottom_side_position : (element, relative_to, position) ->
    relative_offset = relative_to.offset()

    left = relative_offset.left +
      relative_to.width() / 2 -
      element.width() / 2

    if @is_inset position
      top = relative_offset.top +
      relative_to.height() -
        element.height()

    {left : left, top : top}

  is_inset: (position) ->
    position[1] == 'i'

  is_bottom_side : (position) ->
    position[0] == 'b'

  is_side : (position) ->
    position[0].length == 1

  get_relative_to : (element) ->
    relative_to_selector = element.attr('data-positionable-relative-to')

    if relative_to_selector?
      return $ relative_to_selector

    element.parent()

  normalize_pos_arg : (pos_arg) ->
    if pos_arg.length == 1
      if pos_arg == 'l' or pos_arg == 'r' or pos_arg == 'c'
        return 'm' + pos_arg

      return pos_arg + 'c'

    pos_arg

  normalize_pos_args : (element) ->
    (@normalize_pos_arg pos_arg for pos_arg in element.attr('data-positionable').split(' '))

  parse_positionable_objects : () ->
    @position_objects()

  position_objects: (selector = '[data-positionable]') ->
    $(selector).each (index, _element) =>
      element = $(_element)

      @set_position element,
        @get_relative_to(element),
        @normalize_pos_args(element)
}