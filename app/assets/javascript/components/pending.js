var Calendar = require('./calendar');
var Reservations = require('./reservations');
var Trips = require('./trips');
var Modal = require('react-bootstrap/lib/Modal');
var Button = require('react-bootstrap/lib/Button');
var ButtonGroup = require('react-bootstrap/lib/ButtonGroup');
var ButtonToolbar = require('react-bootstrap/lib/ButtonToolbar');
var React = require('react');
var ReactDOM = require('react-dom');
var _ = require('lodash');

var Page = React.createClass({
  displayName: 'Page',

  getInitialState() {
    return {editEvent: {}}
  },

  componentWillReceiveProps(props) {
    this.setState({
      defaultDate: props.defaultDate
    })
  },

  componentDidMount() {
    this.applyBootstrapStyles();
  },

  componentDidUpdate() {
    this.applyBootstrapStyles();
  },

  applyBootstrapStyles() {
    var $calendar = $(ReactDOM.findDOMNode(this.refs.calendarView));

    $calendar.find('.fc-button-group')
        .removeClass('fc-button-group')
        .addClass('btn-group');

    $calendar.find('.fc-button')
        .removeClass('fc-button')
        .removeClass('fc-state-default')
        .addClass('btn btn-default');
  },

  render() {
    var defaultDate = this.state.defaultDate || this.props.arrivalDate;
    var eventUrls = _.pick(this.props, ['tripEvents', 'reservationEvents']);

    var {showEdit, showCreate, editEvent, createDate} = this.state;
    var reservation = editEvent.model ? editEvent.model.reservation : null;

    // show arrival and departure buttons on the calendar
    var arrivalButton = {text: 'Arrival', click: this.handleArrivalClick};
    var departureButton = {text: 'Departure', click: this.handleDepartureClick};
    var buttons = {arrival: arrivalButton, departure: departureButton};
    var headerButtons = {left: 'title', right: 'prev arrival,departure next'};

    var eventChangeCallbacks = {
      eventDrop: this.changeEventStart,
      eventResize: this.changeEventDuration
    };

    var tooltipHandlers = {
      eventRender: this.renderEventElement,
      eventMouseover: this.handleEventMouseOver,
      eventMouseout: this.handleEventMouseOut,
      eventResizeStart: this.handleEventInteractionStart,
      eventResizeStop: this.handleEventInteractionStop
    };

    return (
        <div className="pending-page">
          <CalendarView
              {...eventUrls}
              {...eventChangeCallbacks}
              {...tooltipHandlers}
              ref="calendarView"
              defaultDate={defaultDate}
              customButtons={buttons}
              header={headerButtons}
              eventClick={this.handleEventClick}
              dayClick={this.handleDayClick} />

          <div className="event-modals">
            <EditModal action={editEvent.update_html}
                       kind={editEvent.kind}
                       reservation={reservation}
                       onHide={this.closeModal}
                       visible={showEdit} />

            <CreateModal trip={this.props.trip}
                         date={createDate}
                         action={this.props.createUrl}
                         onHide={this.closeModal}
                         visible={showCreate} />
          </div>
        </div>
    );
  },

  changeEventStart(event, delta, revert) {
    var day = event.model.reservation.day + delta.days();

    this.changeEvent(event, {day: day}, revert);
  },

  changeEventDuration(event, delta, revert) {
    var nights = event.model.reservation.nights + delta.days();

    this.changeEvent(event, {nights: nights}, revert);
  },

  changeEvent(event, data, revert) {
    if (! event.update_json) return revert();

    $.post(event.update_json, {_method: 'put', reservation: data})
        .then(function(res) { event.model = res })
        .fail(revert)
  },

  handleArrivalClick() {
    var trip = this.props.trip;
    this.refs.calendarView.call('gotoDate', trip.arrival);
  },

  handleDepartureClick() {
    var trip = this.props.trip;
    this.refs.calendarView.call('gotoDate', trip.departure);
  },

  handleDayClick(date) {
    this.setState({showCreate: true, createDate: date})
  },

  handleEventClick(event) {
    if (event.model.trip) return;

    this.setState({showEdit: true, editEvent: event});
  },

  closeModal() {
    this.setState({showEdit: false, showCreate: false})
  },

  handleEventInteractionStart(event) {
    event.disableTooltip = true;
  },

  handleEventInteractionStop(event) {
    event.disableTooltip = false;
  },

  handleEventMouseOver(event, jsEvent) {
    if (event.disableTooltip) return;
    let fcEvent = $(jsEvent.target).closest('.fc-event');

    if (fcEvent.length) {
      $(fcEvent).tooltip('show');
    }
  },

  handleEventMouseOut(event, jsEvent) {
    if (event.disableTooltip) return;
    let fcEvent = $(jsEvent.target).closest('.fc-event');

    if (fcEvent.length) {
      $(fcEvent).tooltip('hide');
    }
  },

  renderEventElement(event, $el) {
    var model = event.model,
        trip = model.trip,
        res = model.reservation,
        kind = event.type;
    var icon, tooltip = [];

    switch (kind) {
      case 'hotel':
        icon = 'bed';
        break;

      case 'tour':
        icon = 'sunglasses';
        break;

      case 'transport':
        icon = 'road';
        break;

      case 'arrival':
      case 'departure':
        icon = 'plane';
    }

    if (icon) {
      $el.find('.fc-content').prepend(
          `<i class="glyphicon glyphicon-${icon}"></i>`
      );
    }

    switch (kind) {
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
          $el.find('fc-content').append('<i class="glyphicon glyphicon-ok"/>')
        }
    }

    let tooltipText = tooltip.filter(Boolean).join('<br/>');

    return $el.tooltip({
      trigger: 'manual',
      container: 'body',
      title: tooltipText,
      html: true
    });

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
            ref="calendar"
            editable={true}
            eventDataTransform={this.setEventDisplayProperties}
            eventSources={this.state.eventSources}/>
    );
  },

  call(method, ...args) {
    return this.refs.calendar.call(method, ...args);
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

var EditLink = React.createClass({
  displayName: 'EditLink',

  getInitialState() {
    return {show: false}
  },

  render() {
    return (
        <div className="edit-reservation-link">

          <Button bsStyle="link"
                  bsSize="xsmall"
                  onClick={this.handleShowModal}>
            <i className="glyphicon glyphicon-pencil" />
            &nbsp; Edit
          </Button>

          <EditModal {...this.props}
              onHide={this.handleCloseModal}
              visible={this.state.show} />
        </div>
    )
  },

  handleShowModal() {
    this.setState({show: true})
  },

  handleCloseModal() {
    this.setState({show: false})
  }
});

var EditModal = React.createClass({
  displayName: 'EditModal',

  getInitialState() {
    return {visible: false}
  },

  componentWillReceiveProps(props) {
    this.setState({
      action: props.action,
      kind: props.kind,
      res: props.reservation,
      visible: props.visible
    })
  },

  render() {
    var visible = !! this.state.visible;

    if (! visible) {
      return <Modal show={false} />
    }

    var {action, kind, res} = this.state;
    var dateRange = this.formatRange(res.arrival, res.departure);

    return (
        <Modal bsSize="large" show={true} onHide={this.props.onHide}>
          <Modal.Header closeButton>
            <Modal.Title>
              Edit {kind} reservation
              &nbsp;
              <small>{dateRange}</small>
            </Modal.Title>
          </Modal.Header>

          <Modal.Body>
            <Reservations.Form action={action}
                               kind={kind}
                               reservation={{reservation: res}} />
          </Modal.Body>
        </Modal>
    )
  },

  formatRange(start, end) {
    var startDate = moment.utc(start).startOf('day');
    var endDate = moment.utc(end).startOf('day');
    var range = [this.formatDate(startDate)];

    if (! startDate.isSame(endDate)) {
      range.push(<span key="ndash"> &ndash; </span>);
      range.push(this.formatDate(endDate));
    }

    return range
  },

  formatDate(date) {
    return date.format('ddd D MMM, YYYY')
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
      defaults: props.defaults || {num_people: props.trip.total_people},
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
        <Modal bsSize="large" show={true} onHide={this.props.onHide}>
          <Modal.Header closeButton>
            <Modal.Title>
              Create Reservation
              &nbsp;
              <small>{this.formatDate(date)}</small>
            </Modal.Title>
          </Modal.Header>

          {body}
        </Modal>
    )
  },

  formatDate(date) {
    return moment.utc(date).format('ddd D MMM, YYYY')
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
});

var PasteButton = React.createClass({
  displayName: 'PasteButton',

  getInitialState() {
    return {show: false}
  },

  render() {
    let action = this.props.action;

    return (
        <div id="paste-button">
          <Button bsStyle="info" onClick={this.handleShowModal}>
            <i className="glyphicon glyphicon-paste" />
            &nbsp;
            Paste from Excel
          </Button>

          <Modal show={this.state.show}
                 onHide={this.handleCloseModal}>

            <Modal.Header closeButton>
              <Modal.Title>
                Paste from Excel
              </Modal.Title>
            </Modal.Header>
            
            <Modal.Body>
              <form action={action} method="post">
                <div className="form-group">
                  <label htmlFor="reservations-paste">
                    Copy and Paste from an Excel Spreadsheet:
                  </label>

                  <textarea rows={6}
                            className="form-control"
                            id="reservations-paste"
                            name="reservations[paste]" />
                </div>

                <p className="form-control-static">
                  <strong>Warning:</strong>
                  &nbsp;
                  Pasting will remove <em>all</em> existing reservations
                  for this trip.
                </p>

                <Button type="submit">
                  <i className="glyphicon glyphicon-paste" />
                  &nbsp;
                  Create Reservations
                </Button>
              </form>

            </Modal.Body>
          </Modal>
        </div>
    );
  },

  handleShowModal() {
    this.setState({show: true})
  },

  handleCloseModal() {
    this.setState({show: false})
  }

});

var PageButtons = React.createClass({
  displayName: 'PageButtons',

  render() {
    var updateUrl = this.props.tripUrl;
    var pasteUrl = this.props.pasteUrl;
    var trip = this.props.trip;

    return (
        <ButtonToolbar>
          <ButtonGroup>
            <Trips.QuickFormButton trip={trip}
                                   action={updateUrl} />
          </ButtonGroup>

          <ButtonGroup>
            <PasteButton action={pasteUrl} />
            {/* put other buttons here: transfer in/out, paste */}
          </ButtonGroup>

        </ButtonToolbar>
    )
  }
});

module.exports = {
  Page: Page,
  PageButtons: PageButtons,
  EditLink: EditLink
};
