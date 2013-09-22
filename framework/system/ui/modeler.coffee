@Modeler =
  # DEPRECATED, anyway, wtf is this?
  image : (img) ->
    return '' unless img?
    h img.charAt img.length-1
    return img+'default.png' if img.charAt(img.length-1) == '/'
    img

  date : (date) ->
    unless date == '0000-00-00' or ! date?
      return $.datepicker.formatDate 'MM dd, yy', new Date(date)
    ''

  datetime : (datetime) =>
    if is_string datetime
      t = datetime.split ' '
      time = Modeler.time(t[1])
      date = Modeler.date(t[0])

      unless date?
        unless time?
          return ''
        return time

      unless time?
        return date

      return date+' at '+time
    return ''

  time : (time) ->
    t1 = parseInt(time.slice 0, 2)
    t2 = time.slice 3, 5

    if t1 > 12
      t1 -= 12
      suffix = 'pm'
    else
      suffix = 'am'

    return t1+':'+t2+suffix

  currency : (currency) ->
    return currency

  privacy : (privacy) ->
    return capitalize privacy

  gender_string : (g) ->
    if g == 'f'
      return 'Female'
    else if g == 'm'
      return 'Male'
    else if g == 'b'
      return 'Both'
    return ''

  gender_show_selected : (g) ->
    path = 'img/gender/' #Should be somewhere else
    if g == 'm'
      male = 'male-selected.png'
      female = 'female-unselected.png'
    else if g == 'f'
      male = 'male-unselected.png'
      female = 'female-selected.png'
    else if g == 'b'
      male = 'male-selected.png'
      female = 'female-selected.png'

    JSV.common.img(path+male, 'gender-icon-male')+JSV.common.img(path+female, 'gender-icon-female')

  gender : (g) ->
    path = 'img/gender/' #Should be somewhere else
    if g == 'm'
      return JSV.common.img(path+'male-selected.png', 'gender-icon-male')
    else if g == 'f'
      return JSV.common.img(path+'female-selected.png', 'gender-icon-female')
    return ''

  string : (g) ->
    return g if is_string g
    ''

  list : (l, _and = ' and ') ->
    unless l == "" or ! l?
      return replace_last(l, ',', _and)
        .replace(',', ', ')
        .replace(/\s+/, ' ')
    return null
