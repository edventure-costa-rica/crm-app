var React = require('react');
var ReactDOM = require('react-dom');
var chrono = require('chrono-node');
var lib = require('../../lib');
var components = require('../../components');


var $pasteReservations = $('#paste-reservations'),
    $pasteModal = $('#paste-reservations-modal');

var $addReservation = $('#add-reservation');

var $bookTransferIn = $('#book-transfer-in'),
    $bookTransferOut = $('#book-transfer-out'),
    $transferTab = $addReservation.find('a[href="#transport"]');

var $quickTrip = $('#quick-trip'),
    $quickTripView = $('#trip-quick-details'),
    $showQuickTrip = $('#show-quick-trip-form');

var $editReservation = $('.edit-reservation'),
    $reservationModal = $('#edit-reservation-modal'),
    $reservationMount = $reservationModal.find('.react-mount');

var $calendar = $('#pending-calendar');
var $details = $('#pending-details');

var eventSources = [
  {url: $calendar.data('trip'), color: 'black'},
  {url: $calendar.data('hotels'), color: 'darkred'},
  {url: $calendar.data('tours'), color: 'darkgreen'},
  {url: $calendar.data('transports'), color: 'darkblue'}
];

var startDate = $calendar.data('arrival');

ReactDOM.render(
    React.createElement(components.Calendar, {
      events: eventSources,
      defaultDate: startDate,
      dayClick: dayClick,
      eventClick: eventClick,
      editable: true,
      selectable: true
    }),
    $calendar.get(0)
);

$addReservation.find('a[data-toggle="tab"]').on('show.bs.tab', function(ev) {
  var target = $(this).attr('href'),
      action = $addReservation.data('action-url'),
      mount = $(target).find('.react-mount').get(0),
      defaults = typeof window.DEFAULTS === 'undefined' ? {} : window.DEFAULTS;

  delete window.DEFAULTS;

  if (TRIP.total_people && ! defaults.num_people) {
    defaults.num_people = TRIP.total_people;
  }

  ReactDOM.render(
      React.createElement(
          components.Reservations.Form,
          {kind: target.replace('#',''), action: action, defaults: defaults}
      ),
      mount
  )

}).on('shown.bs.tab', function (ev) {
  var target = $(this).attr('href');
  lib.selectFormInput(target);
});


function dayClick(date) {
}

function eventClick(event) {
  console.log('event clicked', event)
}

$pasteReservations.on('click', function(ev) {
  ev.preventDefault();

  $pasteModal.modal('show');
});

$bookTransferIn.add($bookTransferOut).on('click', function (ev) {
  var defaults = {}, date;

  ev.preventDefault();

  if (TRIP) {
    defaults.num_people = TRIP.total_people;

    if (this.id === $bookTransferIn.attr('id')) {
      date = moment.utc(chrono.parseDate(TRIP.arrival));

      if (date.isValid())
        defaults.arrival_date_time = date.format('YYYY-MM-DD h:mm A');

      if (TRIP.arrival_flight)
        defaults.pickup_location = TRIP.arrival_flight;
    }
    else {
      date = moment.utc(chrono.parseDate(TRIP.departure));

      if (date.isValid())
        defaults.departure_date_time = date.format('YYYY-MM-DD h:mm A');

      if (TRIP.departure_flight)
        defaults.dropoff_location = TRIP.departure_flight;
    }
  }

  transferring = true;
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

$editReservation.on('click', function (ev) {
  ev.preventDefault();

  var $this = $(this),
      kind = $this.data('kind'),
      action = $this.data('action'),
      method = 'put',
      res = $this.data('reservation') || {};

  ReactDOM.render(
      React.createElement(
          components.Reservations.Form,
          {kind: kind, action: action, method: method, reservation: res}
      ),
      $reservationMount.get(0),
      function() { $reservationModal.modal('show') }
  );
});

$reservationModal.on('shown.bs.modal', function () {
  lib.selectFormInput($reservationMount.find('form'));
});

if (window.DEFAULTS) {
  if (DEFAULTS.id) {
    $('#edit-reservation-' + DEFAULTS.id).click();
  }
  else {
    $('a[href="#' + DEFAULTS.kind + '"]').tab('show');
  }
}

else if (window.KIND) {
  $('a[href="#' + KIND + '"]').tab('show');
}