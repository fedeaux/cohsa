@Activity =
  init: () ->
    Activity.activities_list_view()
    Activity.activity_picker()

  name: 'Activity'

  url:
    update: 'activity/all'

  data:
    update: ->
      last_seen_obj : 0 #window._db.get('last_seen_obj.activity')

  set_icon_path: (activity_index) ->


  activities_list_view: () ->
    elem = $ '[data-activity-icon-list]'

    elem.live 'click', (e) ->
      t = ensure $(e.target), '[data-activity-icon-list]'
      activities = JSV.parse_args t.attr 'data-activity-icon-list'

      new ListView {
        html : ['<div>
                  <span class=activity-name">'+a.name+'</span></div>
                  <img class="activity-icon" src="'+base_url(a.icon_url)+'" />' for a in activities]
                .join().replace(/,/g, '')
      
        add_class : 'activity-list-view'
      }

  set_activity_picker_values: (activities, display =  '#activity_display', value = '#activity_value') ->
    $(display).val (a.name for a in activities).join(', ')
    $(value).val (a.id for a in activities).join ','

  activity_picker: () ->
    callback = (e) =>
      input = $ e.target

      #Avoid multiple selector and duplicate events glitches
      if ListSelector.show_if_exists input
        return

      Activity.update_local_info()

      mode = input.attr('data-activity-picker-mode') or 'single'

      args =
        add_class : 'list-selector-activities'
        container : '#wrapper'
        display: '#activity_display'
        value: '#activity_value'
        close_politics: 'fade'
        mode: mode

      selected = $(args.value).val().split(',')

      values = ({
        html_selected: '<span class=activity-name">'+a.name+'</span>
                        <img class="activity-icon" src="'+a.icon_selected_url+'" />'

        html_unselected: '<span class=activity-name">'+a.name+'</span>
                          <img class="activity-icon" src="'+a.icon_url+'" />'
        selected: a.id in selected
        value: a.id
        display: a.name
      } for a in Activity.all())

      ls = new ListSelector input, args, values

    $('.activity_picker').live 'focus', callback

  update_local_info: () ->
    layout.blockScreen 'Getting activities...'
    data = _nw.async_request 'activity/all'

    unless data.activities.length == 0
      max_date = (activity.updated_at for activity in data.activities).reduce (a,b) ->
        if a > b then a else b

    _db.set 'activities', data.activities
    _db.set 'last_seen_activity', max_date
    layout.unblockScreen()

  callback:
    update: (data) ->
      #get max date
      unless data.activities.length == 0
        max_date = ( activity.updated_at for activity in data.activities).reduce (a,b) ->
          if a > b then a else b

        _db.set('last_seen_obj.activity', max_date)

        for activity in data.activities
          # Try to save the image
          activity.icon_path = save_remote_file(
            activity.icon, (f) ->
          )

        _db.set 'activities', data.activities

  all: ->
    _db.get 'activities'
