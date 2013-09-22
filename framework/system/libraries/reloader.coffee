class @Reloader
  constructor: ->
    $(document).keydown @key_down
    $(document).keyup @key_up
    @is_e_down = false

  key_down: (e) =>
    if e.keyCode == 69
      @is_e_down = true

    if e.keyCode == 82 and @is_e_down
      console.log 'Reloading...'
      Reloader.reload()

  @reload: () ->
    window.location.reload()

  key_up: (e) =>
    if e.keyCode == 69
      @is_e_down = false
