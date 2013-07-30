@Scalator = {
  parse_scallable_objects: () ->
    @parse_width_full_objects()
    @parse_height_full_objects()
    @parse_children_equalized_height_objects()

  parse_width_full_objects: () ->
    $('.width_full').each (index, _element) =>
      t = $(_element)
      @fill_width t, t.children('.width_fixed'), t.children('.width_filler')

  parse_height_full_objects: () ->
    $('.height_full').each (index, _element) =>
      t = $(_element)
      @fill_height t, t.children('.height_fixed'), t.children('.height_filler')

  parse_children_equalized_height_objects: () ->
    $('[data-equalized-children-height]').each (index, _element) =>
      t = $(_element)
      direction = t.attr('data-equalized-children-height')
      @equalize_children_heights t, '.height-equalization-reference', direction

  equalize_children_heights: (container, _refereces, direction = 'max') ->
    references = container.children _refereces
    children = container.children().not('.height-equalization-ignore')

    unless references.length > 0
      unless children.length > 0
        return

      references = children

    height_list = @list_heights references

    if direction == 'max'
      target_height = Math.max height_list...
    else if direction == 'min'
      target_height = Math.min height_list...

    children.innerHeight target_height

  list_heights: (elems) ->
    (parseFloat($(elem).innerHeight()) for elem in elems)

  fill_width: (container, fixed, filler) ->
    fixed_total_width = 0.0
    for f in fixed
      fixed_total_width += parseFloat $(f).outerWidth()

    remaining_width = container.width() - fixed_total_width

    n  = filler.length
    fillers_width = Math.floor(remaining_width / n)
    residual_width = remaining_width - fillers_width * n

    #FUCKING HACK
    fillers_width -= 1 if filler.length == 1

    filler.slice(0, residual_width).outerWidth (fillers_width + 1)
    filler.slice(residual_width, n).outerWidth fillers_width

  fill_height: (container, fixed, filler) ->
    fixed_total_height = 0
    for f in fixed
      fixed_total_height += $(f).outerHeight()

    container_height = container.outerHeight()
    remaining_height = container_height - fixed_total_height

    n  = filler.length
    fillers_height_candidate = Math.floor(remaining_height / n)

    # First Phase, check elements with 'min-height'
    filler.each (i, _t) ->
      t = $ _t
 
      min_height = t.css 'min-height'

      if min_height? and min_height > fillers_height_candidate
        t.outerHeight min_height
        remaining_height -= parseInt(min_height)
        _t.addClass 'filled_with_min_height'

    free_height_filler = filler.filter ':not(.filled_with_min_height)'

    # Second Phase, without min-height matched elements
    n  = free_height_filler.length
    fillers_height = Math.floor(remaining_height / n)
    residual_height = remaining_height - fillers_height * n

    free_height_filler.slice(0, residual_height).outerHeight (fillers_height + 1)
    free_height_filler.slice(residual_height, n).outerHeight fillers_height

    filler.filter('line_height_filler').each () ->
      $(this).css('line-height', $(this).height() + 'px')
}
