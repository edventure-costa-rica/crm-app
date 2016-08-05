var React = require('react');
var _ = require('lodash');
var chrono = require('chrono-node');
var extend = require('util')._extend;

var FullCalendar = React.createClass({
  displayName: 'FullCalendar',

  calendarMethod(method, ...args) {
    return $(this.refs.calendar).fullCalendar(method, ...args)
  },

  onCalendarViewRender(view, el) {
    var {pageLoadDate, startParam} = this.props
    if (! startParam) startParam = 'start';

    if (pageLoadDate && ! this.loading) {
      let url = [location.protocol, '//', location.host, location.pathname].join('');
      let start = startParam + '=' + encodeURIComponent(view.intervalStart.format('YYYY-MM-DD'));
      let query = location.search.slice(1).replace(/start=[0-9-]+/, '');
      if (query && query[0] !== '&') query = '&' + query;

      location.href = url + '?' + start + query;
    }
  },

  componentDidMount() {
    var calendar = this.refs.calendar;
    var offset = new Date().getTimezoneOffset();

    this.loading = true;

    var calendarOptions = extend({
      timezone: offset,
      header: {right: 'prev next', center: '', left: 'title'},
      viewRender: this.onCalendarViewRender,

    }, this.props);

    $(calendar).fullCalendar(calendarOptions)

    this.loading = false;
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

