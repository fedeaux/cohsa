// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Mouse = (function() {

    function Mouse() {
      this.is_up = __bind(this.is_up, this);

      this.is_down = __bind(this.is_down, this);

      var _this = this;
      this.position = 'up';
      $(document).on('mousedown', function(e) {
        return _this.position = 'down';
      });
      $(document).on('mousedown', function(e) {
        return _this.position = 'down';
      });
      $(document).on('mouseup', function(e) {
        return _this.position = 'up';
      });
    }

    Mouse.prototype.is_down = function() {
      return this.position === 'down';
    };

    Mouse.prototype.is_up = function() {
      return this.position === 'up';
    };

    return Mouse;

  })();

}).call(this);