class @TimePicker
  constructor: (@input, @args = {}) ->
    @container = @input.parent()
    initial_value = @input.val()

    if @container.hasClass 'time_select_parsed'
      return

    @container.addClass 'time_select_parsed'

    default_args = {
      minutes_step: 15
      max_hour: 23
    }

    for name, value of default_args
      @args[name] = @args[name] || value

    @change_dom()
    @set_time initial_value

  change_dom: () ->
    @input.after JSV.time.picker @args
    @input.hide()

    @select_hour = $ '.time_select_hour', @container
    @select_minute = $ '.time_select_minute', @container

    $('.time_select').live 'change', @select_changed

    @select_changed()

  set_time: (time) =>
    _time = break_time time

    if _time?
      @set_current_hours _time.hours
      @set_current_minutes _time.minutes
      @select_changed()

  update_input: () =>
    @update_selected_values()
    @input.val @select_hour.val()+":"+@select_minute.val()
    @args.time_changed @current_time if @args.time_changed

  select_changed: () =>
    @update_input()

  set_current_hours: (hour) ->
    @select_hour.val hour

  set_current_minutes: (minute) ->
    @select_minute.val minute
    @update_selected_values()

  update_selected_values: () ->
    @current_hour = parseInt @select_hour.val()
    @current_minute = parseInt @select_minute.val()

    @current_time = new Date(0, 0, 0, @current_hour, @current_minute)
