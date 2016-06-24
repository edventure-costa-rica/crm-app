var _ = require('lodash');
var Forms = require('./forms');
var React = require('react');
var Nav = require('react-bootstrap/lib/Nav');
var NavItem = require('react-bootstrap/lib/NavItem');

var LinkedStateMixin = require('react-addons-linked-state-mixin');

if (typeof window.COMPANIES === 'undefined') window.COMPANIES = [];

var toOption = function(c) { return { value: c.company.id, title: c.company.name } },
    forKind = function(kind) { return function(c) { return c.company.kind === kind } },
    HOTELS = COMPANIES.filter(forKind('hotel')).map(toOption),
    TOURS = COMPANIES.filter(forKind('tour')).map(toOption),
    TRANSPORTS = COMPANIES.filter(forKind('transport')).map(toOption);

var Create = React.createClass({
  displayName: 'Create',

  getInitialState() {
    return {kind: null}
  },

  componentWillMount() {
    return this.componentWillReceiveProps(this.props)
  },

  componentWillReceiveProps(props) {
    this.setState({
      kind: props.kind
    })
  },

  render() {
    var action = this.props.action;
    var day = this.props.day;
    var defaults = this.props.defaults;
    var kind = this.state.kind;
    var form;

    if (kind) {
      form = (
          <Form action={action}
                kind={kind}
                day={day}
                defaults={defaults} />
      )
    }

    return (
        <div className="create-reservation-component">
          <Nav bsStyle="pills" activeKey={kind} onSelect={this.selectTab}>
            <NavItem eventKey="hotel">
              <i className="glyphicon glyphicon-bed" />
              &nbsp;
              Hotel
            </NavItem>

            <NavItem eventKey="transport">
              <i className="glyphicon glyphicon-road"/>
              &nbsp;
              Transport
            </NavItem>

            <NavItem eventKey="tour">
              <i className="glyphicon glyphicon-sunglasses"/>
              &nbsp;
              Tour
            </NavItem>
          </Nav>

          {form}
        </div>
    )
  },

  selectTab(key) {
    this.setState({kind: key})
  }
});

var Form = React.createClass({
  displayName: 'Form',
  mixins: [LinkedStateMixin],

  getInitialState: function() {
    return {nights: 0};
  },

  componentWillMount() {
    return this.componentWillReceiveProps(this.props)
  },

  componentWillReceiveProps: function(props) {
    var res = props.reservation,
        defaults = res ? res.reservation : props.defaults || {};

    this.setState(_.assign({nights: 1}, defaults));
  },

  setDefaultRackPrice: function(ev) {
    var value = Number(ev.target.value);

    if (! this.state.price && value) {
      this.setState({price: value})
    }
  },

  render: function() {
    var hiddenId, hiddenDay, method = this.props.method,
        companies, kind, nights,
        minRackPrice = Number(this.state.price),
        locationClass = 'col-xs-6';

    if (this.state.id) {
      hiddenId = (
        <input type="hidden" name="reservation[id]" value={this.state.id} />
      );
    }

    if (this.props.day) {
      hiddenDay = (
        <input type="hidden" name="reservation[day]" value={this.props.day} />
      );
    }

    if (! method) method = this.state.id ? 'put' : 'post';

    kind = this.props.kind[0].toUpperCase() + this.props.kind.substr(1);

    switch (this.props.kind) {
      case 'hotel':     companies = HOTELS; break;
      case 'tour':      companies = TOURS; break;
      case 'transport': companies = TRANSPORTS; kind = 'Operator'; break;
    }

    if (this.props.kind === 'hotel') {
      locationClass = 'col-xs-5';
      nights = (
          <div className="col-xs-2">
            <Forms.NumberField id="reservation-nights"
                               name="reservation[nights]"
                               title="Nights"
                               value={this.linkState('nights')}
                               required={true} min={1} step={1} />
          </div>
      );
    }

    return (
      <div className="row">
        <form className="form" method="post" action={this.props.action}>
          <input type="hidden" name="_method" value={method} />
          {hiddenId}
          {hiddenDay}

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

          <div className="col-xs-6">
            <Forms.PriceField id="reservation-net_price" name="reservation[net_price]"
                              title="Net Price"
                              onBlur={this.setDefaultRackPrice}
                              value={this.linkState('net_price')}
                              required={false} min={0} step={0.01} />
          </div>

          <div className="col-xs-6">
            <Forms.PriceField id="reservation-price" name="reservation[price]"
                              title="Rack Price"
                              value={this.linkState('price')}
                              required={false} min={minRackPrice} step={0.01} />
          </div>

          {nights}

          <div className={locationClass}>
            <Forms.TextField id="reservation-pickup" name="reservation[pick_up]"
                             title="Pick Up Time and Location"
                             value={this.linkState('pick_up')} />
          </div>

          <div className={locationClass}>
            <Forms.TextField id="reservation-dropoff" name="reservation[drop_off]"
                             title="Drop Off Time and Location"
                             value={this.linkState('drop_off')} />
          </div>

          <div className="col-xs-12">
            <div className="btn-toolbar">
              <div className="btn-group">
                <button className="btn btn-primary" type="submit">
                  <i className="glyphicon glyphicon-ok" />
                  &nbsp; Save
                </button>
              </div>

              {this.props.children}
            </div>
          </div>
        </form>
      </div>
    );
  }
});

var Prices = React.createClass({
  displayName: 'Prices',
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
        <form className="form" action={this.props.action} method="post">
          <input type="hidden" name="_method" value="put" />

          <div className="row">
            <div className="col-xs-12 col-sm-6">
              <Forms.StaticField title="Company" value={this.state.company} />
            </div>

            <div className="col-xs-12 col-sm-6">
              <Forms.StaticField title="Services" value={this.state.services} />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-6">
              <Forms.PriceField value={this.linkState('netPrice')}
                                id="reservation-net_price"
                                name="reservation[net_price]"
                                required={false}
                                title="Net Price" />
            </div>

            <div className="col-xs-6">
              <Forms.PriceField value={this.linkState('rackPrice')}
                                id="reservation-price"
                                name="reservation[price]"
                                required={false}
                                title="Rack Price" />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-12">
              <Forms.TextArea value={this.linkState('notes')}
                              id="reservation-notes"
                              name="reservation[notes]"
                              title="Private Notes" />
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


var Confirmation = React.createClass({
  displayName: 'Confirmation',
  mixins: [LinkedStateMixin],

  getInitialState: function (props) {
    props = props || this.props;

    return _.assign({}, props);
  },

  componentWillReceiveProps: function (props) {
    this.setState(this.getInitialState(props));
  },

  render: function() {
    return (
        <form className="form" action={this.props.action} method="post">
          <input type="hidden" name="_method" value="put" />
          <input type="hidden" name="reservation[confirmed]" value="true"/>

          <div className="row">
            <div className="col-xs-6">
              <Forms.StaticField title="Company" value={this.state.company} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Services" value={this.state.services} />
            </div>

            <div className="col-xs-12">
              <Forms.PriceField title="Net Price"
                                value={this.linkState('netPrice')}
                                id="reservation-net_price"
                                name="reservation[net_price]" />
            </div>

            <div className="col-xs-12">
              <Forms.TextField title="Confirmation Number"
                               value={this.linkState('confirmation')}
                               name="reservation[confirmation_no]"
                               id="reservation-confirmation_no" />
            </div>


            <div className="col-xs-12">
              <Forms.TextArea title="Private Notes"
                              value={this.linkState('notes')}
                              name="reservation[notes]"
                              id="reservation-notes" />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-12 text-right">
              <button type="submit" className="btn btn-primary">
                <i className="glyphicon glyphicon-ok-circle" />
                &nbsp; Confirm
              </button>
            </div>
          </div>
        </form>
    );
  }
});


var Payment = React.createClass({
  displayName: 'Payment',
  mixins: [LinkedStateMixin],

  getInitialState: function (props) {
    props = props || this.props;

    return _.assign({}, props);
  },

  componentWillReceiveProps: function (props) {
    this.setState(this.getInitialState(props));
  },

  render: function() {
    var today = moment();

    return (
        <form className="form" action={this.props.action} method="post">
          <input type="hidden" name="_method" value="put" />
          <input type="hidden" name="reservation[paid]" value="true"/>

          <div className="row">
            <div className="col-xs-8 col-md-12">
              <Forms.StaticField title="Company" value={this.state.company} />
            </div>

            <div className="col-xs-4 col-md-6">
              <Forms.StaticField title="Net Price" value={this.state.netPrice} />
            </div>

            <div className="col-xs-12 col-md-6">
              <Forms.DateTimeField title="Date of Payment"
                                   value={this.linkState('paidDate')}
                                   name="reservation[paid_date]"
                                   max={today} noTime={true}
                                   id="reservation-paid_date" />
            </div>

            <div className="col-xs-12">
              <Forms.TextArea title="Private Notes"
                              value={this.linkState('notes')}
                              name="reservation[notes]"
                              id="reservation-notes" />
            </div>
          </div>

          <div className="row">
            <div className="col-xs-12 text-right">
              <button type="submit" className="btn btn-primary">
                <i className="glyphicon glyphicon-usd" />
                &nbsp; Mark as Paid
              </button>
            </div>
          </div>
        </form>
    );
  }
});


var View = React.createClass({
  displayName: 'View',
  mixins: [LinkedStateMixin],

  getInitialState: function (props) {
    props = props || this.props;

    return _.assign({}, props);
  },

  componentWillReceiveProps: function (props) {
    this.setState(this.getInitialState(props));
  },

  render: function() {
    var res = this.state.reservation,
        company = this.state.company;

    var dateFormat = 'dddd, MMMM D, YYYY';

    var arrivalDate = moment(res.arrival).format(dateFormat),
        departureDate = moment(res.departure).format(dateFormat);
    
    var arrival = [arrivalDate, res.arrival_time].filter(Boolean).join(' - '),
        departure = [departureDate, res.departure_time].filter(Boolean).join(' - ');

    var netPrice = res.net_price ? '$' + Number(res.net_price) : '',
        rackPrice = res.price ? '$' + Number(res.price) : '';

    return (
          <div className="row">
            <div className="col-xs-4">
              <Forms.StaticField title="Pax" value={res.num_people} />
            </div>

            <div className="col-xs-8">
              <Forms.StaticField title="Services" value={res.services} />
            </div>

            <div className="col-xs-12">
              <Forms.StaticField title="Company" value={company} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Arrival" value={arrival} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Pick Up" value={res.pickup_location} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Departure" value={departure} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Drop Off" value={res.dropoff_location} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Net Price" value={netPrice} />
            </div>

            <div className="col-xs-6">
              <Forms.StaticField title="Rack Price" value={rackPrice} />
            </div>

            <div className="col-xs-12">
              <Forms.StaticField title="Private Notes" value={res.notes} />
            </div>

            <div className="col-xs-12 text-right">
              <a href={this.state.tripUrl} className="btn btn-primary">
                <i className="glyphicon glyphicon-tag" />
                &nbsp; Trip {this.state.tripId}
              </a>
            </div>
          </div>
    );
  }
});

module.exports = {
  Form: Form,
  Create: Create,
  Prices: Prices,
  Confirmation: Confirmation,
  Payment: Payment,
  View: View
};
