class @Phonegap
  constructor: ->
    $.ajaxSetup({
      data: {phonegap: 'phonegap'}
    })

    FastClick.attach(document.body) if FastClick?

