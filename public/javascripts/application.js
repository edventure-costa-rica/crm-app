// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function debounce(fn, timeout) {
  if (timeout === undefined) timeout = 150;
  var timer;

  return function() {
    var args = Array.prototype.slice.call(arguments);

    if (timer) return;
    timer = setTimeout(function() {
      timer = null;
      fn.apply(null, args);
    }, timeout);
  };
}

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

});
