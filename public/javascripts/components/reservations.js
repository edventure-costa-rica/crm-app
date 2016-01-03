var _ = require('lodash');
var Forms = require('./forms');
var React = require('react');

var LinkedStateMixin = require('react-addons-linked-state-mixin');

if (typeof window.COMPANIES === 'undefined') window.COMPANIES = [];

var toOption = function(c) { return { value: c.company.id, title: c.company.name } },
    forKind = function(kind) { return function(c) { return c.company.kind === kind } },
    HOTELS = COMPANIES.filter(forKind('hotel')).map(toOption),
    TOURS = COMPANIES.filter(forKind('tour')).map(toOption),
    TRANSPORTS = COMPANIES.filter(forKind('transport')).map(toOption);

var Form = React.createClass({
  displayName: 'Form',
  mixins: [LinkedStateMixin],

  getInitialState: function(props) {
    props = props || this.props;

    var res = props.reservation,
        defaults = res ? res.reservation : props.defaults || {},
        departure, arrival;

    departure = _.compact([defaults.departure, defaults.departure_time]).join(' ');
    arrival = _.compact([defaults.arrival, defaults.arrival_time]).join(' ');

    return _.assign({
      arrival_date_time: arrival,
      departure_date_time: departure,
      dropoff_location: defaults.dropoff_location,
      pickup_location: defaults.pickup_location
    }, defaults);
  },

  componentWillReceiveProps: function(props) {
    this.setState(this.getInitialState(props));
  },

  setDefaultRackPrice: function(ev) {
    var value = Number(ev.target.value);

    if (! this.state.price && value) {
      this.setState({price: value})
    }
  },

  render: function() {
    var hiddenId, method = this.props.method,
        companies, kind;

    if (this.state.id) {
      hiddenId = (
        <input type="hidden" name="reservation[id]" value={this.state.id} />
      );
    }

    if (! method) method = this.state.id ? 'post' : 'put'

    kind = this.props.kind[0].toUpperCase() + this.props.kind.substr(1);

    switch (this.props.kind) {
      case 'hotel':     companies = HOTELS; break;
      case 'tour':      companies = TOURS; break;
      case 'transport': companies = TRANSPORTS; kind = 'Operator'; break;
    }

    return (
      <div className="row">
        <form className="form" method="post" action={this.props.action}>
          <input type="hidden" name="_method" value={method} />
          {hiddenId}

          <div className="col-xs-12 col-sm-3">
            <Forms.PaxField id="reservation-num_people" name="reservation[num_people]"
                            title="Pax" required={true}
                            value={this.linkState('num_people')} />
          </div>

          <div className="col-xs-12 col-sm-6">
            <Forms.TextField id="reservation-services" name="reservation[services]"
                             title="Services" value={this.linkState('services')} />
          </div>

          <div className="col-xs-12 col-sm-3">
            <Forms.SelectField id="reservation-company_id" name="reservation[company_id]"
                              title={kind} prompt="Select a Company" required={true}
                              value={this.linkState('company_id')} options={companies} />
          </div>

          <div className="col-xs-6 col-sm-3">
            <Forms.PriceField id="reservation-net_price" name="reservation[net_price]"
                              title="Net Price"
                              onBlur={this.setDefaultRackPrice}
                              value={this.linkState('net_price')}
                              required={true} min={0} step={0.01} />
          </div>

          <div className="col-xs-6 col-sm-3">
            <Forms.PriceField id="reservation-price" name="reservation[price]"
                              title="Rack Price"
                              value={this.linkState('price')}
                              required={true} min={0} step={0.01} />
          </div>

          <div className="col-xs-6 col-sm-3">
            <Forms.DateTimeField id="reservation-arrival_date_time" name="reservation[arrival_date_time]"
                                 title="Arrival"
                                 value={this.linkState('arrival_date_time')}
                                 required={true} />
          </div>

          <div className="col-xs-6 col-sm-3">
            <Forms.DateTimeField id="reservation-departure_date_time" name="reservation[departure_date_time]"
                                 title="Departure"
                                 value={this.linkState('departure_date_time')}
                                 required={true} />
          </div>

          <div className="col-xs-6">
            <Forms.TextField id="reservation-pickup" name="reservation[pickup_location]"
                             title="Pick Up Location"
                             value={this.linkState('pickup_location')} />
          </div>

          <div className="col-xs-6">
            <Forms.TextField id="reservation-dropoff" name="reservation[dropoff_location]"
                             title="Drop Off Location"
                             value={this.linkState('dropoff_location')} />
          </div>

          <div className="col-xs-12 text-right">
            <button className="btn btn-primary" type="submit">
              <i className="glyphicon glyphicon-ok" />
              &nbsp; Save
            </button>
          </div>
        </form>
      </div>
    );
  }
});

module.exports = {
  Form: Form
};
