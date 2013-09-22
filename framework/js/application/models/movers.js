// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Movers = (function() {

    function Movers() {
      this.display_results = __bind(this.display_results, this);

      this.block_results = __bind(this.block_results, this);

      this.show_friends = __bind(this.show_friends, this);

      this.show_requests = __bind(this.show_requests, this);

      this.search = __bind(this.search, this);
      $('[data-action-invite-to-we-move]').live('click', function(e) {
        var t;
        t = ensure($(e.target), '[data-action-invite-to-we-move]');
        $.post(site_url('user/send_invite_email'), {
          email: t.attr('data-action-invite-to-we-move')
        });
        return layout.m("Your invitation has been sent", "confirm", function() {
          return _nav.follow_route('__map__');
        });
      });
    }

    Movers.prototype.init_search = function(_input, _results, _button) {
      this._input = _input;
      this._results = _results;
      this._button = _button;
      this.input = $(this._input);
      this.results = $(this._results);
      this.button = $(this._button);
      return this.button.click(this.search);
    };

    Movers.prototype.search = function() {
      var query, response;
      Form.clear_clearfield();
      query = this.input.val();
      if (query === '') {
        return layout.m('Why would you try an empty search?', 'warning');
      } else {
        layout.blockScreen('Searching...');
        response = _nw.async_request('user/quick_search', {
          query: query
        });
        layout.unblockScreen();
        return this.display_results(response);
      }
    };

    Movers.prototype.show_requests = function() {
      var requests;
      this.block_results();
      requests = _user.friendship_requests();
      return this.display_results({
        users: requests
      });
    };

    Movers.prototype.show_friends = function() {
      var friends;
      this.block_results();
      friends = _user.friends();
      return this.display_results({
        users: friends
      });
    };

    Movers.prototype.block_results = function() {
      return layout.blockContainer(this.results);
    };

    Movers.prototype.display_results = function(response) {
      if (response.users.length) {
        this.results.html(JSV.user.list(response.users));
      } else {
        this.results.html(JSV.user.empty_search(response.type, response.query));
      }
      return layout.global_adjustments();
    };

    return Movers;

  })();

}).call(this);
