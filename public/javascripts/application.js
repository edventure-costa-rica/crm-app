// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var React = require('react');
var ReactDOM = require('react-dom');
var components = require('components');

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

  var $mountSearch = $('#mount-search'),
      searchUrl = $mountSearch.data('url');

  ReactDOM.render(
      React.createElement(components.Search, {url: searchUrl}),
      $mountSearch.get(0)
  );

  var $newReservations = $('#new-reservations');
  if ($newReservations.length) {
    ReactDOM.render(
        React.createElement(components.Reservations.Form,
            {kind: 'hotel', action: $newReservations.data('action-url')}),
        $newReservations.find('#new-res-hotel').get(0)
    );
    ReactDOM.render(
        React.createElement(components.Reservations.Form,
            {kind: 'tour', action: $newReservations.data('action-url')}),
        $newReservations.find('#new-res-tour').get(0)
    );
    ReactDOM.render(
        React.createElement(components.Reservations.Form,
            {kind: 'transport', action: $newReservations.data('action-url')}),
        $newReservations.find('#new-res-transport').get(0)
    );
  }

  var $quickTrip = $('#quick-trip'),
      $quickTripView = $('#trip-quick-details'),
      $showQuickTrip = $('#show-quick-trip-form');

  $showQuickTrip.on('click', function(ev) {
    ev.preventDefault();

    $quickTrip.hide();
    $quickTripView.slideUp(function() {
      ReactDOM.render(
          React.createElement(components.Trips.QuickForm, {
            trip: $quickTrip.data('trip'),
            action: $quickTrip.data('action'),
            onCancel: onCancel
          }),
          $quickTrip.get(0),
          function () { $quickTrip.slideDown() }
      )
    });

    function onCancel(ev) {
      ev.preventDefault();

      $quickTrip.slideUp(function () {
        $quickTripView.slideDown()
      });
    }
  });
});
