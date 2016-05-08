var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../../components');

var chrono = require('chrono-node');
var moment = require('moment');
var lib = require('../../lib');

var $confirmRes = $('.confirm-reservation'),
    $confirmModal = $('#confirm-reservation-modal'),
    $confirmMount = $confirmModal.find('.react-mount');


$confirmRes.on('click', function() {
  var $this = $(this),
      confirmation = $this.data('confirmation'),
      notes = $this.data('notes'),
      services = $this.data('services'),
      company = $this.data('company'),
      action = $this.data('action');

  ReactDOM.render(
      React.createElement(
          components.Reservations.Confirmation, {
            action: action,
            company: company,
            services: services,
            confirmation: confirmation,
            notes: notes
          }
      ),
      $confirmMount.get(0),
      function() { $confirmModal.modal('show') }
  )
});

$confirmModal.on('shown.bs.modal', function() {
  lib.selectFormInput(this);
});
