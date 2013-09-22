class @Whatshot
  constructor: (@args = {}) ->
    default_args =
      url:
        user: site_url 'event/mixed_whatshot'
        public: site_url 'event/public_whatshot'
        mixed: site_url 'event/mixed_whatshot'

    for name, value of default_args
      @args[name] = @args[name] || value

    @events = []
    @called_public = false

  has_events: () ->
    @events.length > 0

  get_events: () ->
    return @events

  set_events: (events) ->
    if is_array events
      @events = events
    else
      @events = []

  get_url: () ->
    if _user.is_logged()
      if @called_public
        return @args.url.user
      else
        return @args.url.mixed

    @called_public = true
    @args.url.public

  get_args: () =>
    args = @args.services.get_user_coordinates()
    args

  new_events_arrived: (data) =>
    @set_events data.events
    @args.new_events_callback(@get_events()) if @args.new_events_callback

  whatshot: () =>
    url = @get_url()
    args = @get_args()
    $.post url, args, @new_events_arrived, 'json'