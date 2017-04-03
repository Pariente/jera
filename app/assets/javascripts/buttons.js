document.addEventListener("turbolinks:load", function() {
  // MASK
  $(".mask").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').addClass('hidden');
    $(this).parents('.content').find('.content-right-column').addClass('hidden');
    $(this).parents('.content').find('.content-masked').removeClass('hidden');
  });

  // UNMASK
  $(".unmask").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').removeClass('hidden');
    $(this).parents('.content').find('.content-right-column').removeClass('hidden');
    $(this).parents('.content-masked').addClass('hidden');
  });

  // HARVEST
  $(".harvest").unbind('click').bind('click', function(evt) {
    $(this).parents('.content').find('.content-left-column').addClass('hidden');
    $(this).parents('.content').find('.content-right-column').addClass('hidden');
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

  // SUBSCRIBE
  $(".subscribe-button").unbind('click').bind('click', function(evt) {
    $(this).find('.white-plus').addClass('hidden');
    $(this).find('.red-cross').removeClass('hidden');
    $(this).addClass('unsubscribe-button');
    $(this).removeClass('subscribe-button');
  });

  // UNSUBSCRIBE
  $(".unsubscribe-button").unbind('click').bind('click', function(evt) {
    $(this).find('.red-cross').addClass('hidden');
    $(this).find('.white-plus').removeClass('hidden');
    $(this).addClass('subscribe-button');
    $(this).removeClass('unsubscribe-button');
  });
});