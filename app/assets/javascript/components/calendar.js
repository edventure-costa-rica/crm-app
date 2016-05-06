var React = require('react');
var _ = require('lodash');
var moment = require('moment');
var chrono = require('chrono-node');
var $ = require('jquery');

var Calendar = React.createClass({
  displayName: 'Calendar',

  componentDidMount:  function() { 
    var calendar = this.refs.calendar;

    $(calendar).fullCalendar({
      events: this.props.events
    })
  },

  componentWillUnmount: function() {
    var calendar = this.refs.calendar;

    $(calendar).fullCalendar('destroy');
  },

  render: function() {
    return (
      <div ref="calendar" />
    );
  }
})

module.exports = Calendar
