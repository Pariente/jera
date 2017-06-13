function recommendation_textarea(element) {
  element.style.height = "80px";
  element.style.height = (element.scrollHeight)+"px";
  if (element.value.length >= 10 && $(element).parent().find('.recommend-to-friend').hasClass('not-active')) {
    $(element).parent().find('.recommend-to-friend').removeClass('not-active');
  } else if (element.value.length <= 10 && !$(element).parent().find('.recommend-to-friend').hasClass('not-active')) {
    $(element).parent().find('.recommend-to-friend').addClass('not-active');
  }
}

function message_textarea(element) {
  element.style.height = "25px";
  element.style.height = (element.scrollHeight)+"px";
  if (element.value.length >= 10 && $(element).parent().find('.recommend-to-friend').hasClass('not-active')) {
    $(element).parent().find('.recommend-to-friend').removeClass('not-active');
  } else if (element.value.length <= 10 && !$(element).parent().find('.recommend-to-friend').hasClass('not-active')) {
    $(element).parent().find('.recommend-to-friend').addClass('not-active');
  }
}

document.addEventListener("turbolinks:load", function() {

  // WHEN CLICKING OUTSIDE OF NAV, SHRINK SEARCHBAR AND BOTTOM NAVBAR
  $('body').click(function(event) { 
    if ($(event.target).closest('.nav').length) { return; }
    $('.search-navbar').removeClass('expanded');
    $('.bottom-navbar').removeClass('expanded');        
    $('.nav-first-row').removeClass('shrinked');        
  });

  // TOGGLE BOTTOM NAVBAR
  $(".profile-button").unbind('click').bind('click', function(evt) {
    $('.bottom-navbar').toggleClass('expanded');
  });

  // TOGGLE SEARCH IN NAVBAR
  $(".magnifier-button").unbind('click').bind('click', function(evt) {
    $('.nav-first-row').toggleClass('shrinked');
    $('.search-navbar').toggleClass('expanded');
  });

  // MASK
  $(".mask").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').addClass('hidden');
    $(this).parents('.content').find('.content-right-column').addClass('hidden');
    $(this).parents('.content').find('.recommendation-header').addClass('hidden');
    $(this).parents('.content').find('.content-masked').removeClass('hidden');
  });

  // UNMASK
  $(".unmask").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').removeClass('hidden');
    $(this).parents('.content').find('.content-right-column').removeClass('hidden');
    $(this).parents('.content').find('.recommendation-header').removeClass('hidden');
    $(this).parents('.content-masked').addClass('hidden');
  });

  // HARVEST
  $(".harvest").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').addClass('hidden');
    $(this).parents('.content').find('.content-right-column').addClass('hidden');
    $(this).parents('.content').find('.recommendation-header').addClass('hidden');
    $(this).parents('.content').find('.content-harvested').removeClass('hidden');
    $('.harvest-count').html(parseInt($('.harvest-count').html(), 10)+1)
    if (parseInt($('.harvest-count').html(), 10) == 1) {
      $('.added-to-harvest').fadeTo('slow', 1, function() {});
    }
  });

  // CANCEL HARVEST
  $(".cancel-harvest").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').removeClass('hidden');
    $(this).parents('.content').find('.content-right-column').removeClass('hidden');
    $(this).parents('.content').find('.recommendation-header').removeClass('hidden');
    $(this).parents('.content').find('.content-harvested').addClass('hidden');
    $('.harvest-count').html(parseInt($('.harvest-count').html(), 10)-1)
    if (parseInt($('.harvest-count').html(), 10) == 0) {
      $('.added-to-harvest').fadeTo('slow', 0, function() {});
    }
  });

  // UNHARVEST
  $(".unharvest").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').addClass('hidden');
  });

  // READ
  $(".content-read").unbind('click').bind('click', function() {
    var id = $(this).data("entry");
    $.post("/entries/" + id + "/read", { _method: 'get' });
    if ( $(this).find('.read-sign').hasClass('hidden') ) {
      $(this).find('.read-sign').removeClass('hidden');
      $(this).find('img').addClass('low-opacity');
      $(this).siblings('.fruit-footer').find('.unread').removeClass('hidden');
      $(this).siblings('.fruit-footer').find('.read').addClass('hidden');
    }
  });

  $(".read").unbind('click').bind('click', function() {
    $(this).parents('.content-box').find('.read-sign').removeClass('hidden');
    $(this).parents('.content-box').find('img').addClass('low-opacity');
    $(this).siblings('.unread').removeClass('hidden');
    $(this).addClass('hidden');
  });

  // UNREAD
  $(".unread").unbind('click').bind('click', function() {
    $(this).parents('.content-box').find('.read-sign').addClass('hidden');
    $(this).parents('.content-box').find('img').removeClass('low-opacity');
    $(this).siblings('.read').removeClass('hidden');
    $(this).addClass('hidden');
  });

  // ADD TO GARDEN
  $(".add-to-garden").unbind('click').bind('click', function(evt) {
    evt.preventDefault();
    $(this).parents('.tree').find('.add-to-garden-screen').removeClass('hidden');
    $('body').css('overflow', 'hidden');
  });

  // CANCEL ADD TO GARDEN
  $(".cancel-add-to-garden").unbind('click').bind('click', function(evt) {
    evt.preventDefault();
    $(this).parents('.add-to-garden-screen').fadeOut('slow', function() {
      $(this).addClass('hidden')
    });
    $('body').css('overflow', 'initial');
  });

  // UNSUBSCRIBE
  $(".delete-tree").unbind('click').bind('click', function(evt) {
    $(this).parents('.tree').find('.add-to-garden').removeClass('hidden');
    $(this).parents('.tree').find('.move-tree').addClass('hidden');
    $(this).parents('.tree').find('.delete-tree').addClass('hidden');
  });

  // MOVE TO OTHER GARDEN
  $(".unsubscribe-button").unbind('click').bind('click', function(evt) {
    
  });

  // FILTER COLOUR
  $(".filtered-colour").unbind('click').bind('click', function(evt) {
    $(this).addClass('hidden');
    $(this).parent().find('.choose-colour').removeClass('hidden');
  });
  $(".hide-colour-selector").unbind('click').bind('click', function(evt) {
    $(this).parent().addClass('hidden');
    $(this).parents('.garden-colours').find('.filtered-colour').removeClass('hidden');
  });

  // SEND FRIEND REQUEST
  $(".send-friend-request").unbind('click').bind('click', function(evt) {
    $(this).addClass('hidden');
    $(this).parent().find('.pending').removeClass('hidden');
  });

  // ACCEPT FRIENDSHIP
  $(".accept-friend-request").unbind('click').bind('click', function(evt) {
    $(this).parents('.friend-request').addClass('hidden');
  });

  // REFUSE FRIENDSHIP
  $(".refuse-friend-request").unbind('click').bind('click', function(evt) {
    $(this).parents('.friend-request').addClass('hidden');
  });

  // RECOMMEND
  $(".recommend-to-friend").unbind('click').bind('click', function(evt) {
    evt.preventDefault();
    var entry_id = $(this).data('entry-id');
    var receiver_id = $(this).data('receiver-id');
    var message = $(this).parents('.friend-div').find('textarea').val();
    // $.post("/entries/" + entry_id + "/recommend_to_friend/" + receiver_id + ".json", { _method: 'get', message: message });
    $.ajax({
        url: "/entries/" + entry_id + "/recommend_to_friend/" + receiver_id + ".json",
        type: "GET",
        data: {message: message},
        success: function(resp){ }
    });
    $(this).addClass('hidden');
    $(this).parents('.friend-div').find('textarea').addClass('hidden');
    $(this).parent().find('.green').removeClass('hidden');
  });

  // WRITE RESPONSE
  $(".message-response-button").unbind('click').bind('click', function(evt) {
    evt.preventDefault();
    var rec_id = $(this).data('rec-id');
    var text = $(this).parents('.write-response').find('textarea').val();
    $.ajax({
        url: "/recommendation/" + rec_id + "/respond.json",
        type: "POST",
        data: {text: text},
        success: function(resp){ }
    });
    $(this).parents('.fruit-footer').find('.messages').find('.hidden').clone().appendTo('.messages');
    $(this).parents('.fruit-footer').find('.messages').find('.hidden').first().find('.message-text').text(text);
    $(this).parents('.fruit-footer').find('.messages').find('.hidden').first().removeClass('hidden');
    $(this).parents('.write-response').find('textarea').val('');
  });
});