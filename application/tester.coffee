@debug_modules_info =
  database : 0
  framework : 0
  layout : 0
  model__user : 0
  menu : 0
  navigation : 0
  network : 0
  replacer : 0
  router : 0
  security : 0
  transitioner : 0
  validator : 0

global_debug = false

@is_debug = (module) ->
  if debug_modules_info[module]?
    return debug_modules_info[module] == 1 or global_debug
  else
    return global_debug

@h = (msg = 'hear') ->
  #console.log msg
