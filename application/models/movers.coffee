class @Movers
  constructor: () ->
    $('[data-action-invite-to-we-move]').live 'click', (e) ->
      t = ensure $(e.target), '[data-action-invite-to-we-move]'
      $.post site_url('user/send_invite_email'), {email : t.attr 'data-action-invite-to-we-move'}
      layout.m "Your invitation has been sent", "confirm", () ->
        _nav.follow_route '__map__'

  init_search: (@_input, @_results, @_button) ->
    @input = $ @_input
    @results = $ @_results
    @button = $ @_button

    @button.click @search

  search: () =>
    Form.clear_clearfield()
    query = @input.val()

    if query == ''
      layout.m 'Why would you try an empty search?', 'warning'
    else
      layout.blockScreen 'Searching...'
      response = _nw.async_request 'user/quick_search', {query : query }
      layout.unblockScreen()
      @display_results response

  show_requests: () =>
    @block_results()
    requests = _user.friendship_requests()
    @display_results { users: requests }

  show_friends: () =>
    @block_results()
    friends = _user.friends()
    @display_results { users: friends }

  block_results: () =>
    layout.blockContainer @results

  display_results: (response) =>
    if response.users.length
      @results.html JSV.user.list response.users
    else
      @results.html JSV.user.empty_search response.type, response.query

    layout.global_adjustments()
