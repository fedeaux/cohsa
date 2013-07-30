class Server
  constructor: ->
    @ajax =
      async: false
      dataType: "json"
      success: (data) ->
        self.response = data

    @requests = []

    $(document).on 'click', '.submit-form', @post

  ajax_submit_args: (_form) =>
    _trigger = _form.attr 'data-trigger'
    trigger = _trigger? and eval _trigger+'()'
    trigger ?= {}

    ajax_submit =
      beforeSerialize: (values, form, options) =>
        Form.clear_clearfield()
        v = Validator.ajax_perform_validations(_form)
  
        if v
          layout.blockScreen()
        else
          Form._clear_field $ '[data-placeholder]'

        trigger.beforeSerialize(values, form, options) if trigger.beforeSerialize?

        return v

      success: (response, status, xhr, form) =>
        layout.unblockScreen()
        trigger.success(response, status, xhr, form) if trigger.success?

      error: (jqXHR, textStatus, errorThrown) =>
        console.log jqXHR.responseText
        console.log textStatus
        console.log errorThrown
  
        layout.unblockScreen()
        layout.defaultError()

      dataType: 'json'

      data: {phonegap : 'phonegap'}

  post_get_form: () =>
    $ '.main_form'

  post: () =>
    form = @post_get_form()
    form.ajaxSubmit @ajax_submit_args form

  set_synchronous_request_response: (data) =>
    @synchronous_request_response = data

  synchronous_request: (url, data = null) =>
    url = meaningfy_url url

    settings =
      dataType : 'json'
      type : 'post'
      data : data
      success : @set_synchronous_request_response
      async : false

    $.ajax url, settings

    console.log 'NW: Synchronous Request Response', @synchronous_request_response if @debug
    @async_request_response
