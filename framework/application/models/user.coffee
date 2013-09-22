class @User
  constructor: (@args) ->
    @debug = is_debug 'model__user'

    # Interface Bindings. Must be somewhere else.
    $('#user_logout').live 'click', () =>
      _user.logout (@args.logout_callback or null)
      _nav.show_map()

    $('[data-action-request_friendship]').live 'click', (e) =>
      t = ensure $(e.target), '[data-action-request_friendship]'
      @request_friendship t.attr 'data-action-request_friendship'

    $('[data-action-accept_friendship_request]').live 'click', (e) =>
      t = ensure $(e.target), '[data-action-accept_friendship_request]'
      @accept_friendship_request t.attr 'data-action-accept_friendship_request'

    $('[data-action-poke]').live 'click', (e) =>
      t = ensure $(e.target), '[data-action-poke]'
      @poke t.attr 'data-action-poke'

    @friend_picker()
    @invite_friend_picker()

  view_more_options: () =>
    new ListView({
      html : JSV.user.view_options(@get_current_user()),
      title : 'More Options',
      on_show: InterfaceBindings.user.view_user_more_options
    })

  set_current_user: (user) =>
    @current_user = user

  get_current_user: () =>
    @current_user or null

  set_friend_picker_values: (display =  '#friend_display', value = '#friend_value') ->
    friends = @friends()
    $(display).val (f.name for f in friends).join(',')
    $(value).val (f.id for f in friends).join(',')

  set_invite_friend_picker_values: (invited_ids, already_invited =  '#invited_friends') ->
    friends = @friends()
    invited_friends_ids = intersection (f.id for f in @friends()), invited_ids
    $(already_invited).val invited_friends_ids.join(',')

  set_title: () =>
    # HACK to facilitate location on development
    document.title = @user_info.name if @user_info?

  get_profile_picture: () =>
    base_url 'user/get_profile_picture'

  invite_friend_picker: () ->
    input = $ '.invite_friend_picker'
    callback = (e) =>
      #Avoid multiple selector and duplicate events glitches
      if $('.list-selector-invite-friends').length > 0
        $('.list-selector-invite-friends').parents('.list-selector-container').fadeIn()
        return

      friends = @friends()
      unless friends?
        layout.m 'You don\'t have any more friends to invite', 'notice'
        return

      args =
        add_class : 'list-selector-invite-friends'
        container : '#wrapper'
        display: '#friend_display'
        value: '#friend_value'
        close_politics: 'fade'
        sort: "disabled_last"
        on_create: () ->
          layout.adjust_image_size '.list-selector-invite-friends .size_adjustable'

      invited = $('#invited_friends').val().split(',')

      values = ({
        html_selected: '<span class="list-item-photo-wrapper">
                          <img class="user-photo size_adjustable" src="'+f.photo_url+'" />
                        </span>
                        <span class=user-name">'+f.name+'</span>'

        html_unselected: '<span class="list-item-photo-wrapper">
                            <img class="user-photo size_adjustable" src="'+f.photo_url+'" />
                          </span>
                          <span class=user-name">'+f.name+'</span>'

        disabled: f.id in invited
        value: f.id
        display: f.name
      } for f in friends)

      ls = new ListSelector input, args, values

    input.live 'focus', callback

  friend_picker: () ->
    input = $ '.friend_picker'
    callback = (e) =>
      #Avoid multiple selector and duplicate events glitches
      if $('.list-selector-friends').length > 0
        $('.list-selector-friends').parents('.list-selector-container').fadeIn()
        return

      friends = @friends()
      unless friends?
        layout.m 'You don\'t have any friend to invite', 'notice'
        return

      args =
        add_class : 'list-selector-friends'
        container : '#wrapper'
        display: '#friend_display'
        value: '#friend_value'
        close_politics: 'fade'
        on_create: () ->
          layout.adjust_image_size '.list-selector-friends .size_adjustable'

      values = ({
        html_selected: '<span class="list-item-photo-wrapper">
                          <img class="user-photo size_adjustable" src="'+f.photo_url+'" />
                        </span>
                        <span class=user-name">'+f.name+'</span>'

        html_unselected: '<span class="list-item-photo-wrapper">
                            <img class="user-photo size_adjustable" src="'+f.photo_url+'" />
                          </span>
                          <span class=user-name">'+f.name+'</span>'
        selected: false
        value: f.id
        display: f.name
      } for f in friends)

      ls = new ListSelector input, args, values

    input.live 'focus', callback

  friendship_requests: () =>
    @user_info.requests = _nw.async_request 'user/get_requesters'
    @user_info.requests

  friends: () =>
    @user_info.friends = _nw.async_request 'user/get_friends'
    @user_info.friends

  update_local_info: () =>
    layout.blockScreen 'Updating local data...'
    user_info = _nw.async_request 'user/update_session_data',
      {keep_logged_in : @user_info.keep_logged_in}

    if user_info? and @user_info?
      user_info.keep_logged_in = user_info.keep_logged_in or
        @user_info.keep_logged_in if @is_logged()

      @login user_info
    else
      layout.m 'Something went wrong! Please log in again.', 'error', () ->
        _nav.route_handler 'user.login'

    layout.unblockScreen()

  get_user_location_name: () =>
    user_info = @get_local_info()
    if user_info.location? and user_info.location.location?
      return user_info.location.location
    ''

  get_local_info: () =>
    @user_info

  check_remote_session: (args) =>
    @user_info = _db.get 'user_info'

    if @user_info? and @user_info.keep_logged_in == true
      layout.blockScreen 'Checking remote session'

      response = (_nw.async_request 'user/confirm_login', {
        keep_logged_in : @user_info.keep_logged_in,
        email: @user_info.email,
        password: _db.get 'life_of_pi'
      }) or {}

      layout.unblockScreen()

      response.checking_remote_session = true
      @login_ajax_submit().success response

      args.not_logged_callback() unless response.data? or not args.not_logged_callback?
    else
      args.not_logged_callback() if args.not_logged_callback?

    args.after_check_callback() if args.after_check_callback

  update_ajax_submit: () =>
    success: (response, status, xhr, form) =>
      if response?
        @login response.data.user
        layout.m 'Profile successfully updated!', 'notice', () ->
          _nav.route_handler 'menu.settings'

  login_ajax_submit: () =>
    success: (response, status = null, xhr = null, form = null) =>
      if response? and response.data? and response.data.user != false
        pwd = $ '#password'
        _db.set 'life_of_pi', pwd.val() if pwd.length > 0

        unless response.checking_remote_session
          @first_login response.data.user

        @set_title()
        _nav.show_map()

      else if response? and not response.checking_remote_session
        layout.m 'Wrong login or password', 'error'
      else
        _nav.follow_route 'user.login'

  register_ajax_submit: () =>
    success: (response, status, xhr, form) =>
      console.log 'response: ', response, status, xhr, form if @debug

      if response.success
        layout.m 'A confirmation e-mail has been sent to this e-mail address', 'notice', () ->
          _nav.route_handler 'user.login'
      else
        if response.errors?
          layout.m 'This e-mail has already been used'
        else
          layout.m 'There was an error on your signup'

  alternative_login: (alternative_login_info, alternative_login_name) =>
    unless @is_logged()
      layout.blockScreen 'Please wait'

      if(alternative_login_name == 'facebook')
        response = _nw.async_request 'user/facebook_login',
          facebook_id: alternative_login_info.auth_response.userID
          access_token: alternative_login_info.auth_response.accessToken

        @login response.data.user
        _nav.show_map()

      layout.unblockScreen()

  first_login: (user_info) =>
    @login user_info
    @args.login_callback() if is_function @args.login_callback

  login: (user_info) =>
    _db.set 'user_info', user_info
    @user_info = _db.get 'user_info'

  logout: (args) =>
    _db.unset 'user_info'
    delete @user_info
    @args.logout_callback() if is_function @args.logout_callback

  is_logged: =>
    @user_info?

  request_friendship: (friend_id) =>
    if friend_id == @user_info.id
      layout.m 'You are always moving with yourself!', 'notice'

    layout.blockScreen 'Requesting friendship'
    _nw.async_request 'user/request_friendship', {friend_id: friend_id}
    layout.unblockScreen()

    layout.m 'Friendship request successful!', 'success', () ->
      _nav.current_args = {id : friend_id}
      _nav.refresh()

  poke: (user_id) =>
    console.log user_id
    _nw.request 'user/poke', {user_id: user_id}

  accept_friendship_request: (friend_id) =>
    layout.blockScreen 'Accepting friendship'
    _nw.async_request 'user/accept_friendship_request', {friend_id: friend_id}
    layout.unblockScreen()

    layout.m 'You are now moving with this user!', 'success', () ->
      _nav.current_args = {id : friend_id}
      _nav.refresh()

  keep_logged: =>
    if @is_logged()
      unless @user_info.keep_logged_in
        @logout()
      else
        @check_remote_session()
