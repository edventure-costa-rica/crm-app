var React = require('react');
var ReactDOM = require('react-dom');
var components = require('components');

var chrono = require('chrono-node');
var moment = require('moment');
var lib = require('../../lib');

var $rackPrice = $('.edit-rack-price'),
    $supplementalPrice = $('.edit-supplemental-price'),
    $priceModal = $('#edit-price-modal'),
    $priceMount = $priceModal.find('.react-mount');


$rackPrice.on('click', function() {
  var netPrice = $rackPrice.data('net-price'),
      rackPrice = Number($rackPrice.data('rack-price')),
      services = $rackPrice.data('services'),
      company = $rackPrice.data('company'),
      action = $rackPrice.data('action');

  ReactDOM.render(
      React.createElement(
          components.Reservations.RackPrice, {
            action: action,
            company: company,
            services: services,
            netPrice: netPrice,
            rackPrice: rackPrice
          }
      ),
      $priceMount.get(0),
      function() { $priceModal.modal('show') }
  )
});

$supplementalPrice.on('click', function() {
  var price = Number($supplementalPrice.data('price')),
      totalNet = $supplementalPrice.data('total-net'),
      totalRack = $supplementalPrice.data('total-rack'),
      action = $supplementalPrice.data('action');

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
