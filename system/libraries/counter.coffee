class @Counter
  constructor: (f, message = 'Executing', n = 3, t = 1000) ->
    @timer_handle = setInterval @wrap(f, n, message), t

  wrap: (f, n, message) =>
    i = 0
    () =>
      if i == n
        f()
        clearTimeout @timer_handle

      else
        console.log message+' in '+(n-i)
        i += 1
