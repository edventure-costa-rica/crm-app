var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../../components');

var chrono = require('chrono-node');
var lib = require('../../lib');

var $rackPrice = $('.edit-rack-price'),
    $supplementalPrice = $('.edit-supplemental-price'),
    $priceModal = $('#edit-price-modal'),
    $priceMount = $priceModal.find('.react-mount');


$rackPrice.on('click', function() {
  var $this = $(this),
      netPrice = Number($this.data('net-price')),
      rackPrice = Number($this.data('rack-price')),
      services = $this.data('services'),
      company = $this.data('company'),
      notes = $this.data('notes'),
      action = $this.data('action');

  ReactDOM.render(
      React.createElement(
          components.Reservations.Prices, {
            action: action,
            company: company,
            services: services,
            netPrice: netPrice,
            rackPrice: rackPrice,
            notes: notes
          }
      ),
      $priceMount.get(0),
      function() { $priceModal.modal('show') }
  )
});

$supplementalPrice.on('click', function() {
  var $this = $(this),
      price = Number($this.data('price')),
      totalNet = $this.data('total-net'),
      totalRack = $this.data('total-rack'),
      action = $this.data('action');

  ReactDOM.render(
      React.createElement(
          components.Trips.SupplementalPrice, {
            action: action,
            totalNet: totalNet,
            totalRack: totalRack,
            price: price
          }
      ),
      $priceMount.get(0),
      function() { $priceModal.modal('show') }
  )
});

$priceModal.on('shown.bs.modal', function() {
  lib.selectFormInput(this);
});
