var React = require('react');
var ReactDOM = require('react-dom');
var {Calendar} = require('../../components');

var $calendarMount = $('#calendar-mount');

if ($calendarMount.length) {
  ReactDOM.render(
      React.createElement(Calendar, {
        eventSources: $calendarMount.data('events')
      }),
      $calendarMount.get(0)
  );
}

