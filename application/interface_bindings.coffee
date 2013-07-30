@InterfaceBindings = {
  menu:
    movers: () ->
      $('#movers_requests').click () ->
        _movers.show_requests()

      $('#movers_friends').click () ->
        _movers.show_friends()

    settings: () ->
      $('#we_move_about').click (e) ->
        new ListView
          html : JSV.settings.about()
          title : "About We Move"
          add_class : 'footer'

      $('#we_move_contact').click (e) ->
        new ListView
          html : JSV.settings.contact()
          title : "Contact"
          add_class : 'footer'

      $('#we_move_legal').click (e) ->
        new ListView
          html : JSV.settings.legal()
          title : "Terms and Conditions"
          add_class : 'footer'

  events:
    view_event_more_options: () ->

  user:
    view_user_more_options: () ->

    view: () ->
      $('#view_user_more_options').click (e) ->
        _user.view_more_options()

  user:
    login: () ->
      $('#login_with_facebook').live 'click', _facebook.login

}
