class @M_Event
  constructor: ->
    @debug = is_debug 'model__event'

    $('[data-action-assign-event]').live 'click', (e) =>
      t = ensure $(e.target), '[data-action-assign-event]'
      args = JSV.parse_args t.attr 'data-action-assign-event'

      if args.action == 'join'
        @join args
      else
        @decline args

    $('#view_event_more_options').live 'click', (e) =>
      new ListView({
        html : JSV.events.view_options(@get_current_event()),
        title : 'More Options',
        on_show: InterfaceBindings.events.view_event_more_options
      })

  show_search_results: (response) =>
    $('#search_form').fadeOut () ->
      $('#search_result')
        .html(JSV.events.list response)
        .show()

      Scalator.parse_scallable_objects()

      change_back_functionality () ->
        $('#search_result').fadeOut () ->
          $('#search_form').show()
          restore_back_functionality()

  search_ajax_result: () =>
    success: (response, status, xhr, form) =>
      if response.events.length
        @show_search_results response
      else
        layout.m 'No event were found to match your query', 'warning'

  get_close_events: (callback) =>
    $.post site_url('event/get_close_events'), _mp.get_user_coordinates(), callback

  preprocess_fill_form: () =>
    _e = @get_current_event()
    _e['where'] = _e['location']
    _e['#activity_display'] = _e['activities'][0].name if _e['activities'][0]?

    _e['#age_display'] = _e.age_group
    _e['#age_values'] = _e.age_group

    _e['#char_display'] = _e.characteristic
    _e['#char_values'] = _e.characteristic

    _e

  hard_coded_fill_form: () =>
    e = @get_current_event()
    Activity.set_activity_picker_values e.activities
    _user.set_invite_friend_picker_values (u.id for u in e.users)

  show_map_overlay: () ->
    $('.map_overlay').fadeTo 'slow', .4

  join: (args) ->
    layout.blockScreen 'Joining event'
    response = _nw.async_request 'event/join', {event_id : args.event_id}
    layout.unblockScreen()

    layout.m 'You\'ve joined this event!', 'success', () ->
      _nav.refresh()

  decline: (args) ->
    if args.mode == 'list_item'
      _nw.async_request 'event/decline', {event_id : args.event_id}
      $('#event_list_item_'+args.event_id).fadeOut()
    else if args.mode == 'view'
      layout.blockScreen 'Declining event'
      response = _nw.async_request 'event/decline', {event_id : args.event_id}
      layout.unblockScreen()
      layout.m 'You\'ve declined this event', 'success', () ->
        _nav.refresh()

  cache_list: (args) ->
    @cached_list = args

  get_by_user_status: (user_status = null) ->
    if @cached_list?
      _cl = @cached_list
      @cached_list = null
      return _cl

    layout.blockScreen 'Getting event list...'
    response = _nw.async_request 'event/get_by_user_status', {user_status : user_status}
    @cache_list response

    layout.unblockScreen()
    return response

  markup: (event) =>
    f = {}

    f.photo = event.photo_url

    if is_array(event.activities) and event.activities.length > 0
      f.activity_icon = event.activities[0].icon_selected_url
      f.activity_name = event.activities[0].name
    else
      f.activity_icon = ''
      f.activity_name = ''

    f.datetime = Modeler.datetime(event.datetime_initial) or '&nbsp;'

    f.age_group = format(Modeler.list(event.age_group, JSV.common.low_light(' and ')), JSV.common.low_light('for '))  or '&nbsp;'
    f.characteristic = format(Modeler.list(event.characteristic, JSV.common.low_light(' and ')))  or '&nbsp;'

    if parseInt(event.n_movers) <= 0
      f.n_movers = '~'
    else
      f.n_movers = event.n_movers

    f.going = event.user_count.going + JSV.common.low_light('of '+f.n_movers)

    if event.fee == '0.00'
      f.fee = 'free'
    else
      f.fee = "$ "+event.fee

    f.gender_icons = Modeler.gender_show_selected event.gender

    f

  set_current_event: (event) =>
    @current_event = event

  get_current_event: (event) =>
    @current_event or null

  edit_ajax_submit: () =>
    success: (response, status, xhr, form) =>
      console.log 'response: ', response, status, xhr, form if @debug

      if response.success
        layout.m 'Event successfully edited!', 'notice', () ->
          _event.set_current_event response.event # ERROR
          _nav.follow_route 'events.view_local'
      else
        if response.errors?
          layout.m 'Something went wrong!'

  create_ajax_submit: () =>
    beforeSerialize: (values, form, options) =>
      $('[name=datetime_initial]').val $('#start_date').val()+' '+$('#start_time').val()
      $('[name=datetime_final]').val $('#finish_date').val()+' '+$('#finish_time').val()

    success: (response, status, xhr, form) =>
      if response.success
        layout.m 'New event successfully created!', 'notice', () ->
          _event.set_current_event response.event # ERROR
          _nav.follow_route 'events.view_local'
      else
        if response.errors?
          layout.m 'Something went wrong!'
