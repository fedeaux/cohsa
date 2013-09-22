class @Validator
  @debug = is_debug 'validator'
  @block = false

  @default_messages =
    required: "This is a required field"
    regex: "Wrong format"
    equal_to: "Passwords mismatch"
    existent: "Existent"

  @v =
    required: (f) =>
      if @v._required(f.val())
        @message f, "required"
        true

    regex: (f, v) =>
      if @v._regex(f.val(), v)
        @message f, "regex"
        true

    equal_to: (f, v) =>
      console.log f, v if @debug
      if @v._equal_to(f.val(), v)
        @message f, "equal_to"
        return true

    ajax: (e) =>
      t = $(e.target)
      t.siblings(".validation-ajax-message").remove()
      t.attr "data-validation-message", null
      $.post site_url($(this).attr("data-validation-ajax-url")),
        name: $(this).attr("name")
        value: $(this).attr("value")
      , ((data) =>
        unless data.message_slug is ""
          @message t, data.message_slug, "validation-ajax-message"
          t.attr "data-validation-ajax-error", ""
        else
          t.removeAttr "data-validation-ajax-error"
      ), "json"

    _required: (v) =>
      v is ""

    _regex: (v, rg) =>
      _rg = new RegExp(rg, "ig")
      not _rg.test(v)

    _equal_to: (v, s) =>
      v isnt $("[name=\"" + s + "\"]").val()

  @message: (f, slug, add = '') =>
    unless f.attr("data-validation-message")?
      f.attr "data-validation-message", slug

      msg = f.attr("data-validation-" + slug + "-message") or @default_messages[slug]

      _msg = $ "<span class=\"validation-error-message " + add + "\">" + msg + "</span>"
      layout.positionOnTopRight _msg, f

  @validate: (f) =>
    _required = f.attr("data-validation-required")
    _regex = f.attr("data-validation-regex")
    _equal_to = f.attr("data-validation-equal-to")
    block = false
    block = @v.required(f) or block  if _required?
    block = @v.regex(f, _regex) or block  if _regex?
    block = @v.equal_to(f, _equal_to) or block  if _equal_to?
    block

  @init: =>
    $(document).on("keyup", "[data-validation-ajax-type=\"single\"]", @v.ajax)
      .on "blur", "[data-validation-ajax-type=\"single\"]", @v.ajax

    $(document).on "submit", "form", @perform_validations

  @perform_validations: (e) =>
    form = $(e.target)
    $("[data-validation-ajax-type=\"single\"]", form).blur()
    $(".validation-error-message", form).remove()
    $("[data-validation-message]", form).attr "data-validation-message", null

    @block = false
    $("[data-validation-validate]", form).each =>
      @block = @validate($(this)) or @block

    # Ajax-verified errors 
    @block = $("[data-validation-ajax-error]").length > 0 or @block

    if @block
      e.preventDefault()
      false

  @ajax_perform_validations: (form, options = null) =>
    console.log 'VL: ', form, options if @debug
    
    $("[data-validation-ajax-type=\"single\"]", form).blur()
    $(".validation-error-message", form).remove()
    $("[data-validation-message]", form).attr "data-validation-message", null
    
    @block = false
    for f in $("[data-validation-validate]", form)
      console.log 'VL: validate field ', $ f if @debug
      @block = @validate($ f) or @block

    console.log 'VL: ajax: ', $("[data-validation-ajax-error]").length, 'block', @block if @debug

    # Ajax-verified errors
    not ($("[data-validation-ajax-error]").length > 0 or @block)
