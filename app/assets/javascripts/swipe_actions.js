document.addEventListener("turbolinks:load", function() {
  $('.seed').unbind().each(function(){
    $(this).draggable({
      containment: $(this).parent().parent(),
      revert : function(event, ui) {
        $(this).data("uiDraggable").originalPosition = {
            top : 0,
            left : 0
        };
        return !event;
      }
    });
  });
  $( ".earth" ).droppable({
    drop: function( event, ui ) {
      var id = $(this).data("source");
      var colour = ui.draggable.data("colour");

      // Subscribing
      $.post("/sources/" + id + "/subscribe", { colour: colour, _method: 'get' });

      // Modifyind the tree-footer
      $(this).parents('.tree').find('.add-to-garden').addClass('hidden');
      $(this).parents('.tree').find('.move-tree').removeClass('hidden');
      $(this).parents('.tree').find('.delete-tree').removeClass('hidden');

      // Removing the seeds and the text
      $(this).parent().find('.seed').each(function(){
        $(this).fadeOut();
      });
      $(this).parents('.add-to-garden-body').find('.add-to-garden-title').text('');
      $(this).parent().find('.plant-seed-arrow').fadeOut();

      // Changing the screen to match the new subscription
      $(this).parents('.add-to-garden-body').animate({ 'height': '250px' }, 1000, function() {
        $(this).find('.weed').css('display', 'block');
        $(this).find('.weed').fadeTo('slow', 1, function() {});
        if (colour == "red") {
          $(this).find('.add-to-garden-title').text('Ajouté au jardin 🍓 Fraises');
        } else if (colour == "blue") {
          $(this).find('.add-to-garden-title').text('Ajouté au jardin 🍇 Baies');
        } else if (colour == "yellow") {
          $(this).find('.add-to-garden-title').text('Ajouté au jardin 🍋 Citrus');
        }
        hideScreen($(this));
      });
    }
  });

  function hideScreen(earth) {
    hide = window.setTimeout(function(){
      earth.parents('.add-to-garden-screen').fadeOut('slow', function() {
        $(this).addClass('hidden')
      });
      $('body').css('overflow', 'initial');
    }, 2500)
  }
});