var React = require('react');
var Forms = require('./forms');
var LinkedStateMixin = require('react-addons-linked-state-mixin');

var _ = require('lodash');
var moment = require('moment');
var chrono = require('chrono-node');

var QuickForm = React.createClass({
  mixins: [LinkedStateMixin],
  displayName: 'QuickForm',

  getInitialState: function () {
    var trip = this.props.trip,
        state = trip ? _.assign({}, trip.trip) : {},
        date;

    if (state.arrival) {
      date = moment(chrono.parseDate(state.arrival));
      if (date.isValid()) state.arrival = date.format('YYYY-MM-DD h:mm A');
    }

    if (state.departure) {
      date = moment(chrono.parseDate(state.departure));
      if (date.isValid()) state.departure = date.format('YYYY-MM-DD h:mm A');
    }

    return state;
  },

  render: function () {
    var method = 'put';

    return (
        <div className="row">
          <form action={this.props.action} method="post" className="form">
            <input type="hidden" name=".method" value={method} />

            <div className="col-xs-6 col-sm-3">
              <Forms.DateTimeField id="trip-arrival"
                                   name="trip[arrival]"
                                   title="Arrival"
                                   require={true}
                                   value={this.linkState('arrival')}
              />
            </div>

            <div className="col-xs-6 col-sm-3">
              <Forms.TextField id="trip-arrival_flight"
                               name="trip[arrival_flight]"
                               title="Location / Flight"
                               value={this.linkState('arrival_flight')} />
            </div>

            <div className="col-xs-6 col-sm-3">
              <Forms.DateTimeField id="trip-departure"
                                   name="trip[departure]"
                                   title="Departure"
                                   require={true}
                                   value={this.linkState('departure')} />
            </div>


            <div className="col-xs-6 col-sm-3">
              <Forms.TextField id="trip-departure_flight"
                               name="trip[departure_flight]"
                               title="Location / Flight"
                               value={this.linkState('departure_flight')} />
            </div>

            <div className="col-xs-12 text-right">
              <div className="btn-group">
                <button className="btn btn-primary" type="submit">
                  <i className="glyphicon glyphicon-ok" />
                  &nbsp; Save
                </button>

                <button className="btn btn-default" onClick={this.props.onCancel}>
                  <i className="glyphicon glyphicon-remove" />
                  &nbsp; Cancel
                </button>
              </div>
            </div>
          </form>
        </div>
    )
  }
});

module.exports = {QuickForm: QuickForm};

