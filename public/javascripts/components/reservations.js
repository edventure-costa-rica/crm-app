var _ = require('lodash');
var Forms = require('./forms');

var toOption = function(c) { return { value: c.company.id, title: c.company.name } },
    forKind = function(kind) { return function(c) { return c.company.kind === kind } },
    HOTELS = COMPANIES.filter(forKind('hotel')).map(toOption),
    TOURS = COMPANIES.filter(forKind('tour')).map(toOption),
    TRANSPORTS = COMPANIES.filter(forKind('transport')).map(toOption);

function reservationTransfer(res) {
  var dropOff = [
    new Date(res.departure).toDateString(),
    res.departure_time, res.dropoff_location
  ].filter(Boolean).join(' ');

  var pickUp = [
    new Date(res.arrival).toDateString(),
    res.arrival_time, res.pickup_location
  ].filter(Boolean).join(' ');

  return {drop_off: dropOff, pick_up: pickUp}
}

var Form = React.createClass({
  displayName: 'Form',
  mixins: [React.addons.LinkedStateMixin],

  getInitialState: function() {
    var res = this.props.reservation,
        defaults = this.props.defaults || {},
        pickUp, dropOff, transfer;

    if (res) {
      return _.assign(reservationTransfer(res), res);
    }
    else {
      return {
        num_people: defaults.num_people,
        arrival: defaults.arrival,
        arrival_time: defaults.arrival_time,
        dropoff_location: defaults.dropoff_location,
        departure: defaults.departure,
        departure_time: defaults.departure_time,
        pickup_location: defaults.pickup_location
      };
    }
  },

  setDefaultRackPrice: function(ev) {
    var value = Number(ev.target.value);

    if (! this.state.price && value) {
      this.setState({price: value})
    }
  },

  render: function() {
    var hiddenId, companies, kind;

    if (this.state.id) {
      hiddenId = (
        <input type="hidden" name="reservation[id]" value={this.state.id} />
      );
    }

    kind = this.props.kind[0].toUpperCase() + this.props.kind.substr(1);

    switch (this.props.kind) {
      case 'hotel':     companies = HOTELS; break;
      case 'tour':      companies = TOURS; break;
      case 'transport': companies = TRANSPORTS; kind = 'Operator'; break;
    }

    return (
      <div className="row">
        <form className="form" method="post" action={this.props.action}>
          {hiddenId}

          <div className="col-xs-12 col-sm-3">
            <Forms.PaxField id="reservation-pax" name="reservation[pax]"
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
            <Forms.TransferField id="reservation-pick_up" name="reservation[pick_up]"
                                 title="Pick Up"
                                 value={this.linkState('pickUp')}
                                 required={true} />
          </div>

          <div className="col-xs-6 col-sm-3">
            <Forms.TransferField id="reservation-drop_off" name="reservation[drop_off]"
                                 title="Drop Off"
                                 value={this.linkState('dropOff')}
                                 required={true} />
          </div>

          <div className="col-xs-12 text-right">
            <button className="btn btn-primary" type="submit">
              <i className="glyphicon glyphicon-ok"></i>
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
}
