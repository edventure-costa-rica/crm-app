var React = require('react');
var _ = require('lodash');
var moment = require('moment');
var chrono = require('chrono-node');

var Calendar = React.createClass({
  displayName: 'Calendar',

  componentDidMount:  function() { 
    var calendar = this.refs.calendar;
    var offset = new Date().getTimezoneOffset();

    $(calendar).fullCalendar({
      events: this.props.events + '?offset=' + offset
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
