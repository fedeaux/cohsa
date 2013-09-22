// Generated by CoffeeScript 1.4.0
(function() {
  var _this = this;

  this.Modeler = {
    image: function(img) {
      if (img == null) {
        return '';
      }
      h(img.charAt(img.length - 1));
      if (img.charAt(img.length - 1) === '/') {
        return img + 'default.png';
      }
      return img;
    },
    date: function(date) {
      if (!(date === '0000-00-00' || !(date != null))) {
        return $.datepicker.formatDate('MM dd, yy', new Date(date));
      }
      return '';
    },
    datetime: function(datetime) {
      var date, t, time;
      if (is_string(datetime)) {
        t = datetime.split(' ');
        time = Modeler.time(t[1]);
        date = Modeler.date(t[0]);
        if (date == null) {
          if (time == null) {
            return '';
          }
          return time;
        }
        if (time == null) {
          return date;
        }
        return date + ' at ' + time;
      }
      return '';
    },
    time: function(time) {
      var suffix, t1, t2;
      t1 = parseInt(time.slice(0, 2));
      t2 = time.slice(3, 5);
      if (t1 > 12) {
        t1 -= 12;
        suffix = 'pm';
      } else {
        suffix = 'am';
      }
      return t1 + ':' + t2 + suffix;
    },
    currency: function(currency) {
      return currency;
    },
    privacy: function(privacy) {
      return capitalize(privacy);
    },
    gender_string: function(g) {
      if (g === 'f') {
        return 'Female';
      } else if (g === 'm') {
        return 'Male';
      } else if (g === 'b') {
        return 'Both';
      }
      return '';
    },
    gender_show_selected: function(g) {
      var female, male, path;
      path = 'img/gender/';
      if (g === 'm') {
        male = 'male-selected.png';
        female = 'female-unselected.png';
      } else if (g === 'f') {
        male = 'male-unselected.png';
        female = 'female-selected.png';
      } else if (g === 'b') {
        male = 'male-selected.png';
        female = 'female-selected.png';
      }
      return JSV.common.img(path + male, 'gender-icon-male') + JSV.common.img(path + female, 'gender-icon-female');
    },
    gender: function(g) {
      var path;
      path = 'img/gender/';
      if (g === 'm') {
        return JSV.common.img(path + 'male-selected.png', 'gender-icon-male');
      } else if (g === 'f') {
        return JSV.common.img(path + 'female-selected.png', 'gender-icon-female');
      }
      return '';
    },
    string: function(g) {
      if (is_string(g)) {
        return g;
      }
      return '';
    },
    list: function(l, _and) {
      if (_and == null) {
        _and = ' and ';
      }
      if (!(l === "" || !(l != null))) {
        return replace_last(l, ',', _and).replace(',', ', ').replace(/\s+/, ' ');
      }
      return null;
    }
  };

}).call(this);
