var React = require('react');
var ReactDOM = require('react-dom');

var components = require('../../components');
var lib = require('../../lib');

var $reservation = $('.calendar-reservation'),
    $reservationModal = $('#calendar-modal'),
    $reservationMount = $reservationModal.find('.react-mount');

$reservation.on('click', function (ev) {
  ev.preventDefault();

  var $this = $(this),
      company = $this.data('company'),
      tripUrl = $this.data('trip-url'),
      tripId = $this.data('trip-id'),
      res = $this.data('reservation').reservation;

  ReactDOM.render(
      React.createElement(
          components.Reservations.View, {
            reservation: res,
            company: company,
            tripUrl: tripUrl,
            tripId: tripId
          }
      ),
      $reservationMount.get(0),
      function() { $reservationModal.modal('show') }
  );
});
