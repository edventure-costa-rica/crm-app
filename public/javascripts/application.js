// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function () {
  $('#reservation_confirmed').on('change', function(ev, skipFocus) {
    if ($(this).is(':checked')) {
      var toggle = $('#toggle_confirm').show();
      if (! skipFocus) toggle.find('input').focus();
    }
    else {
      $('#toggle_confirm').hide()
    }
  }).triggerHandler('change', true);
});
