var Calendar = require('./calendar');
var Modal = require('react-bootstrap/lib/Modal');
var React = require('react');
var _ = require('lodash');

var Page = React.createClass({
  displayName: 'Page',

  getInitialState() {
    return {event: null}
  },

  render() {
    var arrival = this.props.arrivalDate;
    var eventUrls = _.pick(this.props, ['tripUrl', 'hotelsUrl', 'toursUrl', 'transportsUrl']);

    var {event, trip} = this.state;
    var reservation = event ? event.model.reservation : null;

    var {showEdit, showCreate} = this.state;

    return (
        <div className="pending-page">
          <CalendarView {...eventUrls}
              defaultDate={arrival}
              eventRender={this.addEventTooltip}
              eventClick={this.handleEventClick}
              dayClick={this.handleDayClick} />

          <div className="event-modals">
            <EditModal event={event}
                       reservation={reservation}
                       onClose={this.closeModal}
                       visible={showEdit} />

            <CreateModal trip={trip}
                         day={}
                         onClose={this.closeModal}
                         visible={showCreate} />
          </div>
        </div>
    );
  },

  handleDayClick(date) {
    this.setState({showCreate: true})
  },

  handleEventClick(event) {
    this.setState({showEdit: true, event: event});
  },

  addEventTooltip(event, $el) {
    var model = event.model,
        trip = model.trip,
        res = model.reservation;
    var tooltip = [];

    switch (event.type) {
      case 'arrival':
        tooltip.push(trip.arrival_flight);
        tooltip.push(time(trip.arrival));
        break;

      case 'departure':
        tooltip.push(trip.departure_flight);
        tooltip.push(time(trip.departure));
        break;

      default:
        tooltip.push(res.services);
        if (res.drop_off) {
          tooltip.push('Drop off: ' + res.drop_off);
        }
        if (res.pick_up) {
          tooltip.push('Pick up: ' + res.pick_up);
        }

        if (res.confirmed) {
          $el.find('fc-content').insert('<i class="glyphicon glyphicon-ok"/>')
        }
    }

    let tooltipText = tooltip.filter(Boolean).join('<br/>');

    return $el.tooltip({container: 'body', title: tooltipText, html: true});

    function time(date) {
      return moment.utc(date).format('h:mma');
    }
  }
});

var CalendarView = React.createClass({
  componentWillMount() {
    var {tripUrl, hotelsUrl, toursUrl, transportsUrl} = this.props;

    this.setState({
      eventSources: [
        {color: 'silver', url: tripUrl, className: 'trip-events', editable: false},
        {color: 'darkred', url: hotelsUrl},
        {color: 'darkgreen', url: toursUrl},
        {color: 'darkblue', url: transportsUrl}
      ]
    });
  },

  render() {
    return (
        <Calendar {...this.props}
            editable={true}
            eventSources={this.state.eventSources}/>
    );
  }
});

var EditModal = React.createClass({
  displayName: 'EditModal',

  getInitialState() {
    return {visible: false}
  },

  componentWillReceiveProps(props) {
    this.setState({
      event: props.event,
      reservation: props.reservation,
    })
  },

  render() {
    var res = this.state.reservation;
    var event = this.state.event;
    var visible = !! this.state.visible;

    return (
        <Modal show={visible}>
          <Modal.Header>
            <Modal.Title>
              Reservation
              <small>{res.reservation_id}</small>
            </Modal.Title>
          </Modal.Header>

          <Modal.Body>

          </Modal.Body>
        </Modal>
    )
  }
});

var CreateModal = React.createClass({
  displayName: 'CreateModal',

  getInitialState() {
    return {visible: false}
  },

  componentWillReceiveProps(props) {
    this.setState({
      event: props.event,
      reservation: props.reservation,
    })
  },

  render() {
    var res = this.state.reservation;
    var event = this.state.event;
    var visible = !! this.state.visible;

    return (
        <Modal show={visible}>
          <Modal.Header>
            <Modal.Title>
              Reservation
              <small>{res.reservation_id}</small>
            </Modal.Title>
          </Modal.Header>

          <Modal.Body>

          </Modal.Body>
        </Modal>
    )
  }
})

module.exports = {
  Page: Page
};
