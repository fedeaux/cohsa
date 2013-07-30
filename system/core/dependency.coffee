@Dependency = {
  dependencies: {}

  registered_dependencies: {}

  up: (dependency) ->
    @dependencies[dependency] = true

    for elem in @registered_dependencies[dependency]
      @call_if_it_is_time elem

  down: (dependency) ->
    delete @dependencies[dependency]

  call_if_it_is_time: (elem) ->
    for dependency in elem.dependency_list
      return unless @dependencies[dependency]

    elem.callback()
    elem.callback = () ->
      console.log 'callback already called'

  register_dependency: (callback, dependency_list) ->
    elem =
      callback: callback
      dependency_list: dependency_list

    for dependency in dependency_list
      @registered_dependencies[dependency] ?= []
      @registered_dependencies[dependency].push elem

    @call_if_it_is_time elem
}