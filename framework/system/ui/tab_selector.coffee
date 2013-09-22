class @TabSelector
  constructor: (args) ->
    @unselect_all $ args.menu
    $(args.menu).on 'click', '[data-tab-selector]', @click_menu_item

    unless args.selected?
      @select $(args.menu+' [data-tab-selector]:first')
    else
      @select $(args.menu+' [data-tab-selector='+args.selected+']')

  click_menu_item: (event) =>
    @select $ event.target

  unselect_all: (menu) =>
    $('[data-tab-selector]', menu).each () ->
      $($(this).attr 'data-tab-selector').hide()
      $(this).removeClass 'tab-selector-selected'

  select: (tab) ->
    @unselect_all tab.parent() #  Only works if every selector are at
                               # the same level! Fix

    $(tab.attr 'data-tab-selector').show()
    tab.addClass 'tab-selector-selected'