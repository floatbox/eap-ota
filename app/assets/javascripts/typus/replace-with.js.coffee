$ ->
  $('*[data-replace-with]').each ->
    $(this).html('<img src="/img/offers/progress.gif">')
    $.ajax $(this).data('replace-with'),
      context: this
      success: (data) ->
        # $(this).hide()
        # $(this).slideDown()
        $(this).html(data)
    # $(this).data('replace-with', null)
