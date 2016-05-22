var Calendar = require('./calendar');
var Reservations = require('./reservations');
var Modal = require('react-bootstrap/lib/Modal');
var React = require('react');
var _ = require('lodash');

var Page = React.createClass({
  displayName: 'Page',

  getInitialState() {
    return {trip: this.props.trip}
  },

  render() {
    var arrival = this.props.arrivalDate;
    var eventUrls = _.pick(this.props, ['tripEvents', 'reservationEvents']);

    var {editEvent, trip} = this.state;
    var reservation = editEvent ? editEvent.model.reservation : null;

    var {showEdit, showCreate, createDate} = this.state;

    // TODO arrival and departure buttons on the calendar

    return (
        <div className="pending-page">
          <CalendarView {...eventUrls}
              defaultDate={arrival}
              eventRender={this.addEventTooltip}
              eventClick={this.handleEventClick}
              dayClick={this.handleDayClick} />

          <div className="event-modals">
            <EditModal event={editEvent}
                       reservation={reservation}
                       onHide={this.closeModal}
                       visible={showEdit} />

            <CreateModal trip={trip}
                         date={createDate}
                         action={this.props.createUrl}
                         onHide={this.closeModal}
                         visible={showCreate} />
          </div>
        </div>
    );
  },

  handleDayClick(date) {
    console.log('clicked date', date);
    this.setState({showCreate: true, createDate: date})
  },

  handleEventClick(event) {
    this.setState({showEdit: true, editEvent: event});
  },

  closeModal() {
    console.log('closing modals')
    this.setState({showEdit: false, showCreate: false})
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
    var {tripEvents, reservationEvents} = this.props;

    this.setState({
      eventSources: [
        {url: tripEvents, className: 'trip-events', editable: false},
        {url: reservationEvents}
      ]
    });
  },

  render() {
    return (
        <Calendar {...this.props}
            editable={true}
            eventDataTransform={this.setEventDisplayProperties}
            eventSources={this.state.eventSources}/>
    );
  },

  setEventDisplayProperties(event) {
    switch (event.type) {
      case 'arrival':
      case 'departure':
        event.color = 'Silver';
        break;

      case 'hotel':
        event.color = 'DarkRed';
        break;

      case 'tour':
        event.color = 'DarkGreen';
        break;

      case 'transport':
        event.color = 'DarkBlue';
        break;

      default:
        event.color = 'Yellow';
    }

    return event;
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
      visible: props.visible
    })
  },

  render() {
    var visible = !! this.state.visible;

    if (! visible) {
      return <Modal show={false} />
    }

    var action = event.update_url;
    var kind = event.type;
    var resId = res.reservation_id;
    var res = this.state.reservation;
    var event = this.state.event;

    return (
        <Modal show={true} onHide={this.props.onHide}>
          <Modal.Header>
            <Modal.Title>
              Edit Reservation
              <small>{resId}</small>
            </Modal.Title>
          </Modal.Header>

          <Modal.Body>
            <Reservations.Form action={action}
                               kind={kind}
                               reservation={res} />
          </Modal.Body>
        </Modal>
    )
  }
});

var CreateModal = React.createClass({
  displayName: 'CreateModal',

  getInitialState() {
    return {visible: false, defaults: {}, kind: null}
  },

  componentWillReceiveProps(props) {
    this.setState({
      trip: props.trip,
      date: props.date,
      visible: props.visible,
      action: props.action,
      defaults: props.defaults || {},
      kind: props.kind
    })
  },

  render() {
    var visible = !! this.state.visible;

    if (! visible) {
      return <Modal show={false} />
    }

    var trip = this.state.trip;
    var date = moment.utc(this.state.date).startOf('day');
    var arrival = moment.utc(trip.arrival).startOf('day');
    var departure = moment.utc(trip.departure).startOf('day');
    var day = date.diff(arrival, 'days');

    var body;

    if (date.isBefore(arrival) || date.isAfter(departure)) {
      body = this.dateOutsideTrip();
    }

    else {
      body = (
          <Modal.Body>
            <Reservations.Create day={day}
                                 kind={this.state.kind}
                                 defaults={this.state.defaults}
                                 action={this.state.action} />
          </Modal.Body>
      )
    }

    return (
        <Modal show={true} onHide={this.props.onHide}>
          <Modal.Header>
            <Modal.Title>
              Create Reservation&nbsp;
              <small>{trip.registration_id}</small>
            </Modal.Title>
          </Modal.Header>

          {body}
        </Modal>
    )
  },

  dateOutsideTrip() {
    return (
        <Modal.Body>
          <h2>Error</h2>
          <p>Sorry, you can't add a reservation outside of
            the trip dates.</p>
        </Modal.Body>
    )
  }
})

module.exports = {
  Page: Page
};
