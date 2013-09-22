// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.M_Event = (function() {

    function M_Event() {
      this.create_ajax_submit = __bind(this.create_ajax_submit, this);

      this.edit_ajax_submit = __bind(this.edit_ajax_submit, this);

      this.get_current_event = __bind(this.get_current_event, this);

      this.set_current_event = __bind(this.set_current_event, this);

      this.markup = __bind(this.markup, this);

      this.hard_coded_fill_form = __bind(this.hard_coded_fill_form, this);

      this.preprocess_fill_form = __bind(this.preprocess_fill_form, this);

      this.get_close_events = __bind(this.get_close_events, this);

      this.search_ajax_result = __bind(this.search_ajax_result, this);

      this.show_search_results = __bind(this.show_search_results, this);

      var _this = this;
      this.debug = is_debug('model__event');
      $('[data-action-assign-event]').live('click', function(e) {
        var args, t;
        t = ensure($(e.target), '[data-action-assign-event]');
        args = JSV.parse_args(t.attr('data-action-assign-event'));
        if (args.action === 'join') {
          return _this.join(args);
        } else {
          return _this.decline(args);
        }
      });
      $('#view_event_more_options').live('click', function(e) {
        return new ListView({
          html: JSV.events.view_options(_this.get_current_event()),
          title: 'More Options',
          on_show: InterfaceBindings.events.view_event_more_options
        });
      });
    }

    M_Event.prototype.show_search_results = function(response) {
      return $('#search_form').fadeOut(function() {
        $('#search_result').html(JSV.events.list(response)).show();
        Scalator.parse_scallable_objects();
        return change_back_functionality(function() {
          return $('#search_result').fadeOut(function() {
            $('#search_form').show();
            return restore_back_functionality();
          });
        });
      });
    };

    M_Event.prototype.search_ajax_result = function() {
      var _this = this;
      return {
        success: function(response, status, xhr, form) {
          if (response.events.length) {
            return _this.show_search_results(response);
          } else {
            return layout.m('No event were found to match your query', 'warning');
          }
        }
      };
    };

    M_Event.prototype.get_close_events = function(callback) {
      return $.post(site_url('event/get_close_events'), _mp.get_user_coordinates(), callback);
    };

    M_Event.prototype.preprocess_fill_form = function() {
      var _e;
      _e = this.get_current_event();
      _e['where'] = _e['location'];
      if (_e['activities'][0] != null) {
        _e['#activity_display'] = _e['activities'][0].name;
      }
      _e['#age_display'] = _e.age_group;
      _e['#age_values'] = _e.age_group;
      _e['#char_display'] = _e.characteristic;
      _e['#char_values'] = _e.characteristic;
      return _e;
    };

    M_Event.prototype.hard_coded_fill_form = function() {
      var e, u;
      e = this.get_current_event();
      Activity.set_activity_picker_values(e.activities);
      return _user.set_invite_friend_picker_values((function() {
        var _i, _len, _ref, _results;
        _ref = e.users;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          u = _ref[_i];
          _results.push(u.id);
        }
        return _results;
      })());
    };

    M_Event.prototype.show_map_overlay = function() {
      return $('.map_overlay').fadeTo('slow', .4);
    };

    M_Event.prototype.join = function(args) {
      var response;
      layout.blockScreen('Joining event');
      response = _nw.async_request('event/join', {
        event_id: args.event_id
      });
      layout.unblockScreen();
      return layout.m('You\'ve joined this event!', 'success', function() {
        return _nav.refresh();
      });
    };

    M_Event.prototype.decline = function(args) {
      var response;
      if (args.mode === 'list_item') {
        _nw.async_request('event/decline', {
          event_id: args.event_id
        });
        return $('#event_list_item_' + args.event_id).fadeOut();
      } else if (args.mode === 'view') {
        layout.blockScreen('Declining event');
        response = _nw.async_request('event/decline', {
          event_id: args.event_id
        });
        layout.unblockScreen();
        return layout.m('You\'ve declined this event', 'success', function() {
          return _nav.refresh();
        });
      }
    };

    M_Event.prototype.cache_list = function(args) {
      return this.cached_list = args;
    };

    M_Event.prototype.get_by_user_status = function(user_status) {
      var response, _cl;
      if (user_status == null) {
        user_status = null;
      }
      if (this.cached_list != null) {
        _cl = this.cached_list;
        this.cached_list = null;
        return _cl;
      }
      layout.blockScreen('Getting event list...');
      response = _nw.async_request('event/get_by_user_status', {
        user_status: user_status
      });
      this.cache_list(response);
      layout.unblockScreen();
      return response;
    };

    M_Event.prototype.markup = function(event) {
      var f;
      f = {};
      f.photo = event.photo_url;
      if (is_array(event.activities) && event.activities.length > 0) {
        f.activity_icon = event.activities[0].icon_selected_url;
        f.activity_name = event.activities[0].name;
      } else {
        f.activity_icon = '';
        f.activity_name = '';
      }
      f.datetime = Modeler.datetime(event.datetime_initial) || '&nbsp;';
      f.age_group = format(Modeler.list(event.age_group, JSV.common.low_light(' and ')), JSV.common.low_light('for ')) || '&nbsp;';
      f.characteristic = format(Modeler.list(event.characteristic, JSV.common.low_light(' and '))) || '&nbsp;';
      if (parseInt(event.n_movers) <= 0) {
        f.n_movers = '~';
      } else {
        f.n_movers = event.n_movers;
      }
      f.going = event.user_count.going + JSV.common.low_light('of ' + f.n_movers);
      if (event.fee === '0.00') {
        f.fee = 'free';
      } else {
        f.fee = "$ " + event.fee;
      }
      f.gender_icons = Modeler.gender_show_selected(event.gender);
      return f;
    };

    M_Event.prototype.set_current_event = function(event) {
      return this.current_event = event;
    };

    M_Event.prototype.get_current_event = function(event) {
      return this.current_event || null;
    };

    M_Event.prototype.edit_ajax_submit = function() {
      var _this = this;
      return {
        success: function(response, status, xhr, form) {
          if (_this.debug) {
            console.log('response: ', response, status, xhr, form);
          }
          if (response.success) {
            return layout.m('Event successfully edited!', 'notice', function() {
              _event.set_current_event(response.event);
              return _nav.follow_route('events.view_local');
            });
          } else {
            if (response.errors != null) {
              return layout.m('Something went wrong!');
            }
          }
        }
      };
    };

    M_Event.prototype.create_ajax_submit = function() {
      var _this = this;
      return {
        beforeSerialize: function(values, form, options) {
          $('[name=datetime_initial]').val($('#start_date').val() + ' ' + $('#start_time').val());
          return $('[name=datetime_final]').val($('#finish_date').val() + ' ' + $('#finish_time').val());
        },
        success: function(response, status, xhr, form) {
          if (response.success) {
            return layout.m('New event successfully created!', 'notice', function() {
              _event.set_current_event(response.event);
              return _nav.follow_route('events.view_local');
            });
          } else {
            if (response.errors != null) {
              return layout.m('Something went wrong!');
            }
          }
        }
      };
    };

    return M_Event;

  })();

}).call(this);
