@init = (mode) =>
  closure = () ->

  new Reloader() # It is ugly to put it here, but it must the first thing to be
  # instantiated since must be available on crashes
 
  Setup.core()
  Setup.models()
  Setup.layout()
  Setup.cache()

  $('#wrapper').html Views.hello_cohsa()

Setup.initialize_function init
