class @Popup
  constructor: (url, @args = {}) ->
    popup_options = [
      'toolbar=no'
      'location=no'
      'status=no'
      'menubar=no'
      'scrollbars=no'
      'resizable=no'
      'width='+@args.size.width
      'height='+@args.size.height
    ]

    @dialog_window = window.open url, '_blank', popup_options.join(',')

    @args.callbacks = @args.callbacks or {}
    # @dialog_window.addEventListener('loadstart', (event) ->
    #   #console.log 'Se liga que vai começaaaaaaaar '#+event.url
    # )

    @dialog_window.addEventListener 'loadstop', @global_load_stop

  global_load_stop: (event) =>
    @dialog_window.executeScript({code: "
      (function() {
        if(typeof jQuery != 'undefined') {
          response = {};
  
          $('#response_data input').each(function() {
            t = $(this);
            response[t.attr('name')] = t.val();
          });
  
          return JSON.stringify(response);
        }
      })()
    "}, @on_load_stop)

  on_load_stop: (data) =>
    if @args.callbacks.on_load_stop?
      if @args.callbacks.on_load_stop(data)
        @dialog_window.close()
        delete @dialog_window
