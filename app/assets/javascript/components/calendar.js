var React = require('react');
var _ = require('lodash');
var chrono = require('chrono-node');

var Calendar = React.createClass({
  displayName: 'Calendar',

  componentDidMount:  function() { 
    var calendar = this.refs.calendar;
    var offset = new Date().getTimezoneOffset();

    var {view, date, events, dayClick, eventClick} = this.props;
    if (! Array.isArray(events)) events = [events];
    if (! view) view = 'month';

    $(calendar).fullCalendar({
      eventSources: events,
      defaultView: view,
      timezone: offset,
      defaultDate: date,
      header: {right: 'prev today next', center: '', left: 'title'},
      businessHours: {start: '06:00', end: '18:00'},
      eventLimit: 2,
      dayClick: dayClick,
      eventClick: eventClick
    })
  },

  componentWillUnmount: function() {
    var calendar = this.refs.calendar;

    $(calendar).fullCalendar('destroy');
  },

  render: function() {
    return (
      <div ref="calendar"></div>
    );
  }
});

module.exports = Calendar;
