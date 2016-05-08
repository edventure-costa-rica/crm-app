// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  require('./views/search');
  require('./views/trips/index');
  require('./views/trips/quick');
  require('./views/reservations/pending');
  require('./views/reservations/confirmed');
  require('./views/reservations/unconfirmed');
  require('./views/reservations/unpaid');
  require('./views/calendar/entries');
});

$(function () {
  var lib = require('./lib');

  function toggleWithCheckbox(target, source, focus) {
    if ($(source).is(':checked')) {
      var $target = $(target).show();
      if (focus) $target.find('input').focus();
    }
    else {
      $(target).hide();
    }
  }

  $('#reservation_confirmed').on('change', function(ev, skipFocus) {
    toggleWithCheckbox('#toggle_confirm', this, !skipFocus)
  }).triggerHandler('change', true);

  $('#reservation_paid').on('change', function(ev, skipFocus) {
    toggleWithCheckbox('#toggle_paid', this, !skipFocus)
  }).triggerHandler('change', true);

  setTimeout(function() {
    $('#flash-notice').fadeOut();
  }, 5000);
});

