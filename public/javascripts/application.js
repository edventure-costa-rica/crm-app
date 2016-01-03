// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  require('./views/search');
  require('./views/reservations/pending');
});


$(function () {

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

  // always select the first empty text field
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(ev) {
    var target = $(ev.target).attr('href');
    var firstInput = $(target).find('input[type="text"], textarea')
        .filter(function() { return this.value === '' })
        .first().focus();

    if (firstInput.length === 0) {
      $(target).find('input[type="text"], textarea')
          .first().select();
    }
  });

});

