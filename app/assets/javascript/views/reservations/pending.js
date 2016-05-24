var React = require('react');
var ReactDOM = require('react-dom');
var chrono = require('chrono-node');
var lib = require('../../lib');
var Pending = require('../../components').Pending;

var $data = $('#pending-data');
var $buttons = $('#pending-buttons');
var $calendar = $('#pending-calendar');
var $editButtons = $('#pending-table').find('.edit-reservation');

if ($calendar.length) {
  ReactDOM.render(
      React.createElement(Pending.Page, {
        trip: $data.data('trip').trip,
        arrivalDate: $data.data('arrival'),
        departureDate: $data.data('departure'),
        createUrl: $data.data('create-trip-url'),

        tripEvents: $calendar.data('trip-events'),
        reservationEvents: $calendar.data('reservation-events')
      }),
      $calendar.get(0)
  );
}

if ($buttons.length) {
  let tripUrl = $data.data('update-trip-url');
  let pasteUrl = $data.data('paste-reservations-url');
  let createUrl = $data.data('create-reservation-url');
  let trip = $data.data('trip');

  ReactDOM.render(
      <Pending.PageButtons trip={trip}
                           createUrl={createUrl}
                           pasteUrl={pasteUrl}
                           tripUrl={tripUrl} />,
      $buttons.get(0)
  )
}

$editButtons.each(function() {
  let $button = $(this);
  let action = $button.data('action'),
      kind = $button.data('kind'),
      res = $button.data('reservation').reservation;

  ReactDOM.render(
      <Pending.EditLink action={action}
                        kind={kind}
                        reservation={res} />,
      this
  )
});

//
// $bookTransferIn.add($bookTransferOut).on('click', function (ev) {
//   var defaults = {}, date;
//
//   ev.preventDefault();
//
//   if (TRIP) {
//     defaults.num_people = TRIP.total_people;
//
//     if (this.id === $bookTransferIn.attr('id')) {
//       date = moment.utc(chrono.parseDate(TRIP.arrival));
//
//       if (date.isValid())
//         defaults.arrival_date_time = date.format('YYYY-MM-DD h:mm A');
//
//       if (TRIP.arrival_flight)
//         defaults.pickup_location = TRIP.arrival_flight;
//     }
//     else {
//       date = moment.utc(chrono.parseDate(TRIP.departure));
//
//       if (date.isValid())
//         defaults.departure_date_time = date.format('YYYY-MM-DD h:mm A');
//
//       if (TRIP.departure_flight)
//         defaults.dropoff_location = TRIP.departure_flight;
//     }
//   }
//
//   transferring = true;
//   ReactDOM.render(
//       React.createElement(components.Reservations.Form, {
//         kind: 'transport',
//         action: $addReservation.data('action-url'),
//         defaults: defaults
//       }),
//
//       $addReservation.find('#transport .react-mount').get(0),
//       function() { $transferTab.tab('show') }
//   );
// });
