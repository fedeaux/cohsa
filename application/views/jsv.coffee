@Views = 
  hello_cohsa : () -> 
    _outstream = "
                   <div id=\"CohsaWrapper\">  
                     <h1 > You are now using Cohsa!  
                     </h1 >  
                     <p > Hope you like it  
                     </p >  
                   </div>"  
    return _outstream

  make_args : (a) ->
    escape JSON.stringify a
  parse_args : (a) ->
    JSON.parse unescape a
  set_args : (a) ->
    JSV.args = a
  set_parse_args : (a) ->
    _a = JSV.parse_args a
    JSV.set_args _a
    _a
  wrap : (map, template) ->
    if typeof map == 'string'
      map = {__placeholder__: map}
    html = template
    for placeholder, content of map
      html = html.replace placeholder, content
    html
  empty : () ->
