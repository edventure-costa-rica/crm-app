// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var React = require('react');
var ReactDOM = require('react-dom');
var components = require('components');

var chrono = require('chrono-node');
var moment = require('moment');

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

  var $addReservation = $('#add-reservation');

  $addReservation.find('a[data-toggle="tab"]').on('show.bs.tab', function(ev) {
    var target = $(this).attr('href'),
        action = $addReservation.data('action-url'),
        mount = $(target).find('.react-mount').get(0);

    ReactDOM.render(
        React.createElement(
            components.Reservations.Form,
            {kind: target.replace('#',''), action: action}
        ),
        mount
    )
  });

  var $bookTransferIn = $('#book-transfer-in'),
      $bookTransferOut = $('#book-transfer-out'),
      $transferTab = $addReservation.find('a[href="#transport"]');

  $bookTransferIn.add($bookTransferOut).on('click', function (ev) {
    var defaults = {}, date;

    ev.preventDefault();

    if (TRIP) {
      defaults.num_people = TRIP.total_people;

      if (this.id === $bookTransferIn.attr('id')) {
        date = moment(chrono.parseDate(TRIP.arrival));

        if (date.isValid())
          defaults.arrival_date_time = date.format('YYYY-MM-DD h:mm A');

        if (TRIP.arrival_flight)
          defaults.pickup_location = TRIP.arrival_flight;
      }
      else {
        date = moment(chrono.parseDate(TRIP.departure));

        if (date.isValid())
          defaults.departure_date_time = date.format('YYYY-MM-DD h:mm A');

        if (TRIP.departure_flight)
          defaults.dropoff_location = TRIP.departure_flight;
      }
    }

    ReactDOM.render(
        React.createElement(components.Reservations.Form, {
          kind: 'transport',
          action: $addReservation.data('action-url'),
          defaults: defaults
        }),

        $addReservation.find('#transport .react-mount').get(0),
        function() { $transferTab.tab('show') }
    );
  });

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
