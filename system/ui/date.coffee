class @DatePicker
  @days_per_month: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  constructor: (@input, @args = {}) ->
    @container = @input.parent()
    @my_id = unique_id()

    initial_value = @input.val()

    if @container.hasClass 'date_select_parsed'
      return

    @container.addClass 'date_select_parsed'

    base_date = @args.base_date or new Date
    millis_in_one_year = 3600000 * 24 * 365

    default_args = {
      base_date: base_date
      min_date: new Date(base_date.getTime() - (millis_in_one_year * 100)) #100 years before today
      max_date: new Date(base_date.getTime() + (millis_in_one_year * 10)) #3 years after today
    }

    for name, value of default_args
      @args[name] = @args[name] or value

    @change_dom()
    @set_date initial_value

  change_dom: () ->
    container_class = 'date_selector_container_'+@my_id
    @container.addClass container_class

    @input.after JSV.date.picker @args, @make_date_select_args()
    @input.hide()

    @select_year = $ '.date_select_year', @container
    @select_month = $ '.date_select_month', @container
    @select_day = $ '.date_select_day', @container

    @wrapper_year = $ '.date_selector_wrapper_years', @container
    @wrapper_month = $ '.date_selector_wrapper_months', @container
    @wrapper_day = $ '.date_selector_wrapper_days', @container

    $('.'+container_class+' .date_select').live 'change', @select_changed
    @select_changed()

  set_date: (date) =>
    _date = break_date date

    if _date?
      @set_current_year _date.year
      @set_current_month _date.month
      @set_current_day _date.day

  update_input: () =>
    @update_selected_values()
    @input.val $.datepicker.formatDate 'yy-mm-dd', @current_date
    @args.date_changed @current_date if @args.date_changed

  select_changed: (e) =>
    @check_consistence()
    @update_input()

  update_selected_values: () ->
    @current_year = parseInt(@select_year.val(), 10)
    @current_month = parseInt(@select_month.val(), 10)
    @current_day = parseInt(@select_day.val(), 10)

    @current_date = new Date(@current_year, @current_month - 1, @current_day)

  update_month_options: (range) ->
    @wrapper_month.html JSV.date.months @args, range
    @select_month = $ '.date_select_month', @wrapper_month

  update_day_options: (range) ->
    @wrapper_day.html JSV.date.days @args, range
    @select_day = $ '.date_select_day', @wrapper_day

  check_consistence: () ->
    @update_selected_values()
    # Year is always consistent, we must check month and day only if
    # the selected year is at one extreme

    if @current_year == @args.min_date.getFullYear()
      @check_month_consistency 'min'
    else if @current_year == @args.max_date.getFullYear()
      @check_month_consistency 'max'
    else
      @check_month_consistency()

  check_month_consistency: (year_at) ->
    min_month = @args.min_date.getMonth() + 1
    max_month = @args.max_date.getMonth() + 1

    if year_at == 'min'
      @update_month_options {min : min_month-1, max : 11}

      if @current_month <= min_month
        @set_current_month min_month
        @check_day_consistency 'min'
        return

    else if year_at == 'max'
      @update_month_options {min : 0, max : max_month-1}

      if @current_month >= max_month
        @set_current_month max_month
        @check_day_consistency 'max'
        return

    else
      @update_month_options {min : 0, max : 11}

    @set_current_month @current_month
    @check_day_consistency()

  max_month_day: () ->
    DatePicker.days_per_month[@current_month]

  check_day_consistency: (month_at) ->
    min_day = @args.min_date.getDate()

    max_day = @args.max_date.getDate()
    max_for_month = @max_month_day()
    actual_max_day = Math.min(max_day, max_for_month)

    if month_at == 'min'
      @update_day_options {min : min_day, max : max_for_month}

      if @current_day <= min_day
        @set_current_day min_day
        return

    else if month_at == 'max'
      @update_day_options {min : 1, max : actual_max_day}

      if @current_day >= actual_max_day
        @set_current_day actual_max_day
        return

    else
      @update_day_options {min : 1, max : max_for_month}

    @set_current_day @current_day

  set_current_year: (val) ->
    @select_year.val val
    @current_year = parseInt @select_year.val()

  set_current_month: (val) ->
    @select_month.val pad(val, 2)
    @current_month = parseInt @select_month.val()

  set_current_day: (val) ->
    @select_day.val pad(val, 2)
    @current_day = parseInt val

  make_date_select_args: () ->
    months : {min: 0, max:11}
    days : {min:1, max:31}
    years : {min: @args.min_date.getFullYear(), max: @args.max_date.getFullYear()}
