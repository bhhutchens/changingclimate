$(document).ready(function() {

  $('.tweet_form').on('submit', function(event){

    event.preventDefault();

    $.ajax({
      url: '/ajax/tweet',
      dataType: 'json',
      data: { tweet: $(event.target.tweet).val() },
      type: 'post'
    })
    .done(function(data){
      $(event.target).parent().parent().slideUp(1500, 'swing');
    });

  });

  $('#search_form').on('submit', function(event){
    var $button = $(event.target).children().last()
    $button.attr('value', 'Searching...')
    $button.attr('disabled', 'true')
  });

});
