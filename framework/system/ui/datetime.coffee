class @DatetimePicker
  @days_per_month: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  constructor: (@input, @date_args = {}, @time_args = {}) ->
    @container = @input.parent()
    @my_id = unique_id()

    @initial_value = @input.val()

    if @container.hasClass 'datetime_select_parsed'
      return

    @container.addClass 'datetime_select_parsed'

    @create_inputs()

  create_inputs: () ->
    container_class = 'datetime_selector_container_'+@my_id
    @container.addClass container_class
    values = @initial_value.split ' '

    @set_current_time values[1]
    @set_current_date values[0]

    @time_input = $ '<input type="text"
                            value="'+values[1]+'"
                            id="datetime_time_picker_'+@my_id+'" />';

    @date_input = $ '<input type="text"
                            value="'+values[0]+'"
                            id="datetime_date_picker_'+@my_id+'" />';

    @input.after @time_input
    @input.after @date_input

    @time_args.time_changed = @time_changed
    @date_args.date_changed = @date_changed

    @time_picker = new TimePicker @time_input, @time_args
    @date_picker = new DatePicker @date_input, @date_args

    @input.hide()

  time_changed: (time) =>
    @set_current_time time.getHours()+':'+pad(time.getMinutes(), 2)+':'+pad(time.getSeconds(), 2)
    @update_input()

  date_changed: (date) =>
    @set_current_date $.datepicker.formatDate('yy-mm-dd', date)
    @update_input()

  update_input: () =>
    @input.val @get_current_datetime()

  set_current_time: (time) ->
    @current_time = time

  set_current_date: (date) ->
    @current_date = date

  get_current_datetime: () ->
    @get_current_date()+' '+@get_current_time()

  get_current_time: (time) ->
    @current_time

  get_current_date: (date) ->
    @current_date

  create_time_input: ->
    console.log ''
