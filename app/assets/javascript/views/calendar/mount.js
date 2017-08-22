var React = require('react');
var ReactDOM = require('react-dom');
var {FullCalendar} = require('../../components').Calendar;

var $calendarMount = $('#calendar-mount');

if ($calendarMount.length) {
  ReactDOM.render(
      React.createElement(FullCalendar, {
        eventSources: $calendarMount.data('events'),
        defaultDate: $calendarMount.data('date'),
        pageLoadDate: $calendarMount.data('page-load-date'),
        eventClick: (r) => { if (r.click_url) window.location = r.click_url }
      }),
      $calendarMount.get(0)
  );
}

