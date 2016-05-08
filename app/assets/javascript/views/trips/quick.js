var React = require('react');
var ReactDOM = require('react-dom');
var components = require('../../components');


var $quickTrip = $('#quick-trip');

if ($quickTrip.data('active')) {
  ReactDOM.render(
      React.createElement(components.Trips.QuickForm, {
        trip: $quickTrip.data('trip'),
        action: $quickTrip.data('action')
      }),

      $quickTrip.get(0)
  );
}
