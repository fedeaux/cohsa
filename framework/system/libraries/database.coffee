class @Database
  constructor: ->
    @debug = is_debug 'database'

  filterQuery: ->

  processQuery: ->
    item = localStorage.getItem(@q)
    if item?
      return JSON.parse item
    null

  set: (key, val = null) =>
    console.log "DB: setItem ", key, val if @debug
    localStorage.setItem key, JSON.stringify(val)

  get: (q) =>
    @q = q
    console.log "DB: getItem ", @q if @debug
    @filterQuery()
    @processQuery()

  unset: (key) =>
    localStorage.removeItem key