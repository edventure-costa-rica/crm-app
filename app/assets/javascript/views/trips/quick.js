var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../../components');


var $tripBtn = $('#quick-trip-btn');

if ($tripBtn.length) {
  var data = $tripBtn.data();

  ReactDOM.render(
      React.createElement(components.Trips.QuickFormButton, data /*{
        trip: $tripBtn.data('trip'),
        action: $tripBtn.data('action'),
      }*/),

      $tripBtn.get(0)
  );
}
