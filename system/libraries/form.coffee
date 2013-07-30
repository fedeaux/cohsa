class @Form
  @init: () =>
    # Pre Process
    @pre_process()

    # Special Tratements
    @_phone $ "[data-special-field-type=\"phone\"]"
    @_cpf $ "[data-special-field-type=\"cpf\"]"
    @_cnpj $ "[data-special-field-type=\"cnpj\"]"
    @_number $ "[data-special-field-type=\"number\"]"
    @_currency $ "[data-special-field-type=\"currency\"]"
    @_select_others $ "[data-special-field-type=\"select_others\"]"
    @_datetime $ "[data-special-field-type=\"datetime\"]"
    @_time $ "[data-special-field-type=\"time\"]"
    @_date $ "[data-special-field-type=\"date\"]"
    @_datetime $ "[data-special-field-type=\"datetime\"]"
    @_confirm $ "[data-confirm]"
    @_clear_field $ '[data-placeholder]';
    @_generic_list_selector $ "[data-special-field-type=\"generic_list_selector\"]"
    @_gmaps_location $ "[data-special-field-type=\"gmaps_location\"]"
    #@_cache_value

    # Markers
    @_required $ "[data-validation-required=\"\"]"

  @_apply_datetime: (field, args) ->
    new Datetime field, args

  @parse_date_range_string: (s) ->
    from_date = new Date();
    to_date = new Date();

    if s == '+1w'
      to_date.setDate to_date.getDate() + 7

    [from_date, to_date]

  @_datetime: (f) ->
    f.each (index, _f) =>
      modifiers = $(_f).attr 'data-special-field-modifiers'

      date_args = {}

      # Refactor to encapsultate date date_args evaluation
      if modifiers == 'future'
        date_args.min_date = new Date
      else if modifiers == 'past'
        date_args.max_date = new Date
      else if is_string(modifiers)
        [date_args.min_date, date_args.max_date] = @parse_date_range_string(modifiers)

      new DatetimePicker $(_f), date_args

  @_date: (f) ->
    f.each (index, _f) =>
      modifiers = $(_f).attr 'data-special-field-modifiers'

      args = {}

      if modifiers == 'future'
        args.min_date = new Date
      else if modifiers == 'past'
        args.max_date = new Date
      else if is_string(modifiers)
        [args.min_date, args.max_date] = @parse_date_range_string(modifiers)

      new DatePicker $(_f), args

  @_time: (f) ->
    f.each (index, _f) ->
      new TimePicker $(_f)

  @_persistent_field: (f) ->
    f.each() ->
      t = $ this
      console.log t

  @_generic_list_selector: (f) ->
    f.each () ->
      t = $ this
      ls = null
      callback = (e) =>
        ls = new ListSelector(t)

      t.live 'focus', callback

  @clear_clearfield: () ->
    $('[data-placeholder]').each () ->
      t = $ this
      t.val('') if t.val() == t.attr 'data-placeholder'

  @_gmaps_location: (f) ->
    f.each (index, _f) ->
      _mp.location_autocomplete _f

  @_clear_field: (f) ->
    for _f in f
      _f = $ _f
      if _f.is 'textarea'
        layout.labelize_placeholder _f.parent()
      else
        _f.val _f.attr 'data-placeholder' unless _f.val()

        _f.clearField
          blurClass: "input_blured"
          activeClass: "input_active"

  @_clear_field_check: (f) ->
    if f.val() == ''
      f
        .removeClass('input_active')
        .addClass('input_blured')
    else
      f
        .removeClass('input_blured')
        .addClass('input_active')

  @_confirm : (a) ->
    a.live "click", (e) ->
      unless confirm a.attr "data-confirm"
        e.preventDefault()
        false

  @_cpf : (f) ->
    f.live "keyup", (e) ->
      v = $(e.target).val().replace(/[^0-9]/g, "")
      _v = ""
      i = 0
      while i < v.length
        if i is 3 or i is 6
          _v += "."
        else _v += "-"  if i is 9
        _v += v[i]
        i++
      if _v.length is 3 or _v.length is 7
        _v += "."
      else
        _v += "-"

      if _v.length is 11
        $(e.target).val _v

  @_cnpj : (f) ->
    f.live "keyup", (e) ->
      v = $(e.target).val().replace(/[^0-9]/g, "")
      _v = ""
      i = 0
      while i < v.length
        if i is 2 or i is 5
          _v += "."
        else if i is 8
          _v += "/"
        else _v += "-"  if i is 12
        _v += v[i]
        i++
      if _v.length is 2 or _v.length is 6
        _v += "."
      else if _v.length is 10
        _v += "/"
      else _v += "-"  if _v.length is 15
      $(e.target).val _v

  @_phone : (f) ->
    f.live "focusout", (e) ->
      v = $(e.target).val().replace(/[^0-9]/g, "")
      if v.length is 8
        v = v.slice(0, 4) + "-" + v.slice(4, 8)
      else if v.length is 10
        v = "(" + v.slice(0, 2) + ") " + v.slice(2, 6) + "-" + v.slice(6, 10)
      else if v.length > 10
        offset = v.length - 10
        v = "+" + v.slice(0, offset) + " (" + v.slice(offset, offset + 2) + ") " + v.slice(offset + 2, offset + 6) + "-" + v.slice(offset + 6, offset + 10)
        $(e.target).val v

  @_number : (f) ->
    f.live "keyup", (e) ->
      t = $ e.target
      t.val t.val().replace(/[^0-9]/g, "")

  @_currency : (f) ->
    f.live "keyup", (e) ->
      t = $ e.target
      v = parseInt(t.val().replace(/[^0-9]/g, "").replace(/^0+/g, "")).toString()

      if isNaN(v) or v.length == 0
        t.val '0.00'
      else if v.length == 1
        t.val '0.0'+v
      else if v.length == 2
        t.val '0.'+v
      else
        t.val v.slice(0, v.length - 2)+'.'+v.slice(v.length - 2, v.length)

  @_o_date : (f) ->
    modifiers = f.attr 'data-special-field-modifiers'
    args = {}

    if modifiers?
      if /past/.test modifiers
        args.maxDate = 0
      else if /future/.test modifiers
        args.minDate = 0

    f.overlay_datepicker args

  _adjust_caption = (caption, target) ->
    caption.addClass "caption"
    o = target.offset()
    caption.offset
      top: o.top + target.height() + caption.height() / 4
      left: o.left + (target.width() - caption.width() * 2) / 2

  @_select_others : (f) ->
    f.live "change", (e) ->
      t = $(e.target)
      if t.val() is "__outros__"
        t.after "<input type=\"text\" name=\"" + t.attr("name") + "\" />
                 <a class=\"action back_to_selection\"> voltar à seleção </a>"
      t.hide()
      _adjust_caption t.siblings(".back_to_selection"), t.siblings("input")

  @_required : (f) ->
    f.each ->
      $("label[for=" + $(this).attr("name") + "]").css "font-weight", "bold"

  @pre_process : ->
    $("a.back_to_selection").live "click", (e) ->
      t = $(e.target)
      s = t.siblings("select")
      i = t.siblings("input")
      t.remove()
      s.show().attr "name", i.attr("name")
      i.remove()

    $.datepicker.setDefaults
      dateFormat: "yy-mm-dd"
      changeMonth: true
      changeYear: true

  # Legacy
  @__date : (f) ->
    f.datepicker()

  @__datetime : (f) ->
    modifiers = f.attr 'data-special-field-modifiers'
    args = {}
    overlay = false

    if modifiers?
      if /overlay/.test modifiers
        overlay = true

      if /past/.test modifiers
        args.maxDate = 0
      else if /future/.test modifiers
        args.minDate = 0

    if overlay
      f.overlay_datetimepicker args
    else
      f.datetimepicker args

  @__time : (f) ->
    modifiers = f.attr 'data-special-field-modifiers'
    args = {}
    overlay = false

    if modifiers?
      if /overlay/.test modifiers
        overlay = true

    if overlay
      f.overlay_timepicker args
    else
      f.timepicker args
