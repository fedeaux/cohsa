class @AndroidBehaviour
  constructor: () ->
    document.addEventListener("backbutton", _nav.back, false);

    $('[data-android-go]').live 'keyup', (e) ->
      t = ensure $(e.target), '[data-android-go]'

      if e.which == 13
        $(t.attr 'data-android-go').click()

      e.preventDefault()
      return false

    # win = (winParam) ->
    #   console.log 'I\'ve been called!!!!!!!!!' 
    #   console.log JSON.stringify winParam

    # lose = (loseParam) ->
    #   alert 'lose!'

    # if cordova?
    #   cordova.exec win, lose, "Echo", "echo", ["alface"]
