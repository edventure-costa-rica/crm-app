var React = require('react');
var _ = require('lodash');
var chrono = require('chrono-node');
var extend = require('util')._extend;

var FullCalendar = React.createClass({
  displayName: 'FullCalendar',

  calendarMethod(method, ...args) {
    return $(this.refs.calendar).fullCalendar(method, ...args)
  },

  componentDidMount() {
    var calendar = this.refs.calendar;
    var offset = new Date().getTimezoneOffset();

    var calendarOptions = extend({
      timezone: offset,
      header: {right: 'prev next', center: '', left: 'title'}

    }, this.props);

    $(calendar).fullCalendar(calendarOptions)
  },

  componentWillUnmount() {
    var calendar = this.refs.calendar;

    $(calendar).fullCalendar('destroy');
  },

  render() {
    return (
      <div ref="calendar"></div>
    );
  }
});


module.exports = {FullCalendar};

