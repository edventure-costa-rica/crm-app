var React = require('react');
var ReactDOM = require('react-dom');
var {Calendar} = require('../../components');

var $calendarMount = $('#calendar-mount');

if ($calendarMount.length) {
  ReactDOM.render(
      <Calendar eventSources={[ $calendarMount.data('events') ]} />,
      $calendarMount.get(0)
  );
}


function changeDate() {
  
}
