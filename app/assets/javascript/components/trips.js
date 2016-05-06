var React = require('react');
var Forms = require('./forms');
var LinkedStateMixin = require('react-addons-linked-state-mixin');

var _ = require('lodash');
var moment = require('moment');
var chrono = require('chrono-node');

var QuickForm = React.createClass({
  mixins: [LinkedStateMixin],
  displayName: 'QuickForm',

  getInitialState: function (props) {
    props = props || this.props;

    var trip = props.trip,
        state = trip ? _.assign({}, trip.trip) : {},
        date;

    if (state.arrival) {
      date = moment.utc(chrono.parseDate(state.arrival));
      if (date.isValid()) state.arrival = date.format('YYYY-MM-DD h:mm A');
    }

    if (state.departure) {
      date = moment.utc(chrono.parseDate(state.departure));
      if (date.isValid()) state.departure = date.format('YYYY-MM-DD h:mm A');
    }

    return state;
  },

  componentWillReceiveProps: function(props) {
    this.setState(this.getInitialState(props));
  },

  render: function () {
    var cancelButton, method = 'post';
    var offset = new Date().getTimezoneOffset();

    if (this.state.id) method = 'put';

    if (this.props.onCancel) {
      cancelButton = (
          <button className="btn btn-default" onClick={this.props.onCancel}>
            <i className="glyphicon glyphicon-remove" />
            &nbsp; Cancel
          </button>
      );
    }

    return (
        <div className="row">
          <form action={this.props.action} method="post" className="form">
            <input type="hidden" name="_method" value={method} />
            <input type="hidden" name="trip[offset]" value={offset} />

            <div className="col-xs-6">
              <Forms.PaxField id="trip-total_people"
                              name="trip[total_people]"
                              title="Total People"
                              required={true}
                              value={this.linkState('total_people')} />
            </div>


            <div className="col-xs-6">
              <Forms.PaxField id="trip-num_children"
                              name="trip[num_children]"
                              title="Children"
                              value={this.linkState('num_children')} />
            </div>

            <div className="col-xs-6 col-sm-4">
              <Forms.DateTimeField id="trip-arrival"
                                   name="trip[arrival]"
                                   title="Arrival"
                                   required={true}
                                   value={this.linkState('arrival')}
              />
            </div>

            <div className="col-xs-6 col-sm-8">
              <Forms.TextField id="trip-arrival_flight"
                               name="trip[arrival_flight]"
                               title="Location / Flight"
                               value={this.linkState('arrival_flight')} />
            </div>

            <div className="col-xs-6 col-sm-4">
              <Forms.DateTimeField id="trip-departure"
                                   name="trip[departure]"
                                   title="Departure"
                                   required={true}
                                   value={this.linkState('departure')} />
            </div>


            <div className="col-xs-6 col-sm-8">
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

                {cancelButton}
              </div>
            </div>
          </form>
        </div>
    )
  }
});

var SupplementalPrice = React.createClass({
  displayName: 'SupplementalPrice',
  mixins: [LinkedStateMixin],

  getInitialState: function(props) {
    props = props || this.props;

    return _.assign({}, props);
  },

  componentWillReceiveProps: function(props) {
    this.setState(this.getInitialState(props));
  },

  render: function() {
    return (
        <form className="form" method="post" action={this.props.action}>
          <input type="hidden" name="_method" value="put"/>

          <div className="row">
            <div className="col-xs-4">
              <Forms.StaticField title="Total Net Price" value={this.state.totalNet} />
            </div>

            <div className="col-xs-4">
              <Forms.StaticField title="Total Rack Price" value={this.state.totalRack} />
            </div>

            <div className="col-xs-4">
              <Forms.PriceField title="Supplemental Rack Price"
                                id="trip-supplemental_price"
                                name="trip[supplemental_price]"
                                require={true}
                                value={this.linkState('price')} />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-12 text-right">
              <button type="submit" className="btn btn-primary">
                <i className="glyphicon glyphicon-ok" />
                &nbsp; Save
              </button>
            </div>
          </div>
        </form>
    );
  }
});

module.exports = {
  QuickForm: QuickForm,
  SupplementalPrice: SupplementalPrice
};

