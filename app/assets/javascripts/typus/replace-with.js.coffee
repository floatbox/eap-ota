$ ->
  $('*[data-replace-with]').each ->
    $.ajax $(this).data('replace-with'),
      context: this
      success: (data) ->
        $(this).hide()
        $(this).html(data)
        $(this).slideDown()
    # $(this).data('replace-with', null)
