class @Facebook
  constructor: (@args) ->
    default_args =
      fbAsyncInit: @fbAsyncInit

    for name, value of default_args
      @args[name] = @args[name] ?= value

  FB: () ->
    return @_FB

  login: () =>
    facebook_login_url = (_nw.async_request 'user/get_facebook_login_url').facebook_login_url
    new Popup facebook_login_url,
      size:
        width: $('#wrapper').width()
        height: $('#wrapper').height()
  
      callbacks:
        on_load_stop: (json_facebook_user_data) ->

          try
            facebook_user_data = JSON.parse json_facebook_user_data
          catch error
            return false

          if is_object(facebook_user_data)
            alternative_login_info = {auth_response : facebook_user_data}
            _user.alternative_login alternative_login_info, 'facebook'
            return true

  on_login: (response) =>
    if response.authResponse
      @event 'after_login_success',
        auth_response: response.authResponse

    else
      @event 'after_login_failed', @fb_user_info

    @event 'after_login_complete'

  event: (name, args = {}) =>
    if @args.callbacks[name]?
      @args.callbacks[name] args
