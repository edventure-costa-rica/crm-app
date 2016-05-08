var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../components');
var lib = require('../lib');

var $searchClients = $('#search-clients'),
    $searchModal = $('#search-modal'),
    $searchMount = $searchModal.find('.react-mount'),
    searchUrl = $searchClients.attr('href');

$searchClients.on('click', function(ev) {
  ev.preventDefault();

  ReactDOM.render(
      React.createElement(components.Search, {url: searchUrl}),
      $searchMount.get(0),
      function() { $searchModal.modal('show') }
  );
});

$searchModal.on('shown.bs.modal', function() {
  lib.selectFormInput($searchModal);
});
