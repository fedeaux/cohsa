class @Mouse
  constructor: () ->
    @position = 'up'

    $(document).on 'mousedown', (e) =>
      @position = 'down'

    $(document).on 'mousedown', (e) =>
      @position = 'down'

    $(document).on 'mouseup', (e) =>
      @position = 'up'

  is_down: () =>
    @position == 'down'

  is_up: () =>
    @position == 'up'