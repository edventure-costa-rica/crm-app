var Calendar = require('./calendar');
var React = require('react');

var Page = React.createClass({
  displayName: 'Page',

  render() {
    return (
        <div className="pending-page">
          <CalendarView dayClick={this.handleDayClick} />
        </div>
    );
  },

  handleDayClick(date) {

  }
});

var CalendarView = React.createClass({
  componentWillMount() {
    var {tripUrl, hotelsUrl, toursUrl, transportsUrl} = this.props;

    this.setState({eventSources: [
      {color: 'silver', url: tripUrl},
      {color: 'darkred', url: hotelsUrl},
      {color: 'darkgreen', url: toursUrl},
      {color: 'darkblue', url: transportsUrl}
    ]});
  },

  render() {
    return (
        <Calendar {...this.props} eventSources={this.state.eventSources} />
    );
  }
});

module.exports = {
  Page: Page
};