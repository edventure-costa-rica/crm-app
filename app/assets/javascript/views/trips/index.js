var React = require('react');
var ReactDOM = require('react-dom');

var components = require('../../components');
var lib = require('../../lib');


var $editTrip = $('.edit-trip'),
    $tripModal = $('#edit-trip-modal'),
    $tripMount = $tripModal.find('.react-mount');

$editTrip.on('click', function (ev) {
  ev.preventDefault();

  var $this = $(this),
      action = $this.data('action'),
      trip = $this.data('trip') || {};

  ReactDOM.render(
      React.createElement(
          components.Trips.QuickForm,
          {action: action, trip: trip}
      ),
      $tripMount.get(0),
      function() { $tripModal.modal('show') }
  );
});

$tripModal.on('shown.bs.modal', function () {
  lib.selectFormInput($tripMount.find('form'));
});
