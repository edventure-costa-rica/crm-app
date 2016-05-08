var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../../components');

var chrono = require('chrono-node');
var lib = require('../../lib');

var $payRes = $('.pay-reservation'),
    $payModal = $('#pay-reservation-modal'),
    $payMount = $payModal.find('.react-mount');


$payRes.on('click', function() {
  var $this = $(this),
      paidDate = $this.data('paid-date'),
      netPrice = $this.data('net-price'),
      notes = $this.data('notes'),
      company = $this.data('company'),
      action = $this.data('action');

  ReactDOM.render(
      React.createElement(
          components.Reservations.Payment, {
            action: action,
            company: company,
            paidDate: paidDate,
            netPrice: netPrice,
            notes: notes
          }
      ),
      $payMount.get(0),
      function() { $payModal.modal('show') }
  )
});

$payModal.on('shown.bs.modal', function() {
  lib.selectFormInput(this);
});
