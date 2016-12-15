var {FullCalendar} = require('./calendar');
var Reservations = require('./reservations');
var Trips = require('./trips');
var Forms = require('./forms');
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
    return {editEvent: {}, createDefaults: {}}
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
    var eventKind = editEvent.type;

    // show arrival and departure buttons on the calendar
    var arrivalButton = {text: 'Arrival', click: this.handleArrivalClick};
    var departureButton = {text: 'Departure', click: this.handleDepartureClick};
    var buttons = {arrival: arrivalButton, departure: departureButton};
    var headerButtons = {left: 'title', right: 'prev arrival,departure next'};

    var {createDefaults} = this.state;

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
              aspectRatio={2}
              defaultDate={defaultDate}
              customButtons={buttons}
              header={headerButtons}
              eventClick={this.handleEventClick}
              dayClick={this.handleDayClick} />

          <div className="event-modals">
            <EditModal action={editEvent.update_html}
                       kind={eventKind}
                       confirmUrl={editEvent.confirm_url}
                       mailUrl={editEvent.mail_url}
                       reservation={reservation}
                       onHide={this.closeModal}
                       visible={showEdit} />

            <CreateModal trip={this.props.trip}
                         date={createDate}
                         kind={eventKind}
                         defaults={createDefaults}
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
    this.refs.calendarView.calendarMethod('gotoDate', trip.arrival);
  },

  handleDepartureClick() {
    var trip = this.props.trip;
    this.refs.calendarView.calendarMethod('gotoDate', trip.departure);
  },

  handleDayClick(date) {
    var {pickUps, dropOffs} = this.props;
    var defaults = {};

    if (pickUps) { defaults.pick_up = pickUps[date.toISOString()] }
    if (dropOffs) { defaults.drop_off = dropOffs[date.toISOString()] }

    this.setState({showCreate: true, createDate: date, createDefaults: defaults})
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
          tooltip.push('\u2713 Confirmed');
          $el.find('.fc-title').before(
              '<i class="glyphicon glyphicon-ok"></i> '
          )
        }

        else if (res.mailed_at) {
          const mailed = moment.utc(res.mailed_at).format('lll');
          tooltip.push('Emailed: ' + mailed);

          $el.find('.fc-title').before(
              '<i class="glyphicon glyphicon-envelope"></i> '
          );
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
        <FullCalendar {...this.props}
            ref="calendar"
            editable={true}
            eventDataTransform={this.setEventDisplayProperties}
            eventSources={this.state.eventSources}/>
    );
  },

  calendarMethod(method, ...args) {
    return this.refs.calendar.calendarMethod(method, ...args);
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

var EditButton = React.createClass({
  displayName: 'EditButton',

  getInitialState() {
    return {show: false}
  },

  render() {
    var style = this.props.bsStyle || 'link';
    var size = this.props.bsSize || 'small';

    return (
        <Button bsStyle={style}
                bsSize={size}
                onClick={this.handleShowModal}>
          <i className="glyphicon glyphicon-pencil"/>
          {' '} Edit

          <EditModal {...this.props}
              onHide={this.handleCloseModal}
              visible={this.state.show}/>
        </Button>
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

  componentWillMount() {
    return this.componentWillReceiveProps(this.props)
  },

  componentWillReceiveProps(props) {
    this.setState({
      action: props.action,
      kind: props.kind,
      res: props.reservation,
      visible: props.visible,
      confirmUrl: props.confirmUrl,
      mailUrl: props.mailUrl,
    })
  },

  render() {
    var visible = !! this.state.visible;

    if (! visible) {
      return (
          <div>
            {this.state.nextModal}
          </div>
      );
    }

    var {action, confirmUrl, mailUrl, kind, res} = this.state;
    var dateRange = this.formatRange(res.arrival, res.departure);

    // already mailed, dont show confirm button
    if (res.mailed_at || res.confirmed) confirmUrl = null;

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
                               reservation={{reservation: res}}>
              <ReservationButtons deleteUrl={action}
                                  confirmUrl={confirmUrl}
                                  mailUrl={mailUrl}
                                  showNextModal={this.showNextModal}
                                  kind={kind} />
            </Reservations.Form>
          </Modal.Body>
        </Modal>
    )
  },

  showNextModal(modal) {
    this.setState({
      visible: false,
      nextModal: modal
    });
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

  componentWillMount() {
    return this.componentWillReceiveProps(this.props);
  },

  componentWillReceiveProps(props) {
    this.setState({
      trip: props.trip,
      date: props.date,
      visible: props.visible,
      action: props.action,
      defaults: _.extend({num_people: props.trip.total_people}, props.defaults || {}),
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

var ConfirmButton = React.createClass({
  getInitialState() {
    return {}
  },

  render() {
    var size = this.props.bsSize;
    var style = this.props.bsStyle || 'success';
    var title = this.props.confirmAll ? 'Send Confirmations' : 'Send Confirmation';

    return (
        <Button bsStyle={style} bsSize={size}
                onClick={this.dispatch}
                disabled={!! this.state.loading}>
          <i className='glyphicon glyphicon-envelope' />
          {' ' + title}
        </Button>
    )
  },

  dispatch(ev) {
    if (this.props.confirmAll) {
      return this.postForm(ev);
    }

    else if (! this.props.showNextModal) {
      return
    }

    this.setState({loading: true});

    $.get(this.props.mailUrl).then((mail) => {
      this.props.showNextModal(
          <ConfirmationForm action={this.props.action}
                            mail={mail} />
      );

    }).fail((xhr) => {
      alert('Could not send confirmation: ' + xhr.responseJSON.error);

    }).always(() => {
      this.setState({loading: false});
    });
  },

  postForm(ev) {
    ev.preventDefault();

    let confirmation = this.props.confirmAll
        ? 'Send confirmation emails for all unconfirmed reservations?'
        : 'Send confirmation email for this reservation?';

    if (! confirm(confirmation)) return;

    $('<form method="post"/>')
        .attr('action', this.props.action)
        .submit();
  }
});

var ConfirmationForm = React.createClass({
  render() {
    const {rcpt, subject, body} = this.props.mail;

    return (
        <Modal bsSize="large" show={true}>
          <Modal.Header closeButton>
            <Modal.Title>
              Send Confirmation
              <small>{rcpt}</small>
            </Modal.Title>
          </Modal.Header>

          <form action={this.props.action}>
            <Forms.TextArea title="Body:"
                            value={body} />
          </form>
        </Modal>
    );
  }
});

var DeleteButton = React.createClass({
  render() {
    var style = this.props.bsStyle || 'danger';
    var size = this.props.bsSize;
    return (
        <ButtonGroup>
          <Button bsStyle={style} bsSize={size}
                  onClick={this.deleteReservation}>
            <i className="glyphicon glyphicon-trash" />
            {' '} Delete
          </Button>
        </ButtonGroup>
    );
  },

  deleteReservation(ev) {
    ev.preventDefault();

    if (! confirm('Really delete this reservation?')) return;

    $('<form method="post"/>')
        .attr('action', this.props.action)
        .append('<input name="_method" value="delete" />')
        .submit()
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
        <Button bsStyle="info" onClick={this.handleShowModal}>
          <i className="glyphicon glyphicon-paste"/>
          {' '} Paste from Excel


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
                            name="reservations[paste]"/>
                </div>

                <p className="form-control-static">
                  <strong>Warning:</strong>
                  &nbsp;
                  Pasting will remove <em>all</em> existing reservations
                  for this trip.
                </p>

                <Button type="submit">
                  <i className="glyphicon glyphicon-paste"/>
                  &nbsp;
                  Create Reservations
                </Button>
              </form>

            </Modal.Body>
          </Modal>
        </Button>
    );
  },

  handleShowModal() {
    this.setState({show: true})
  },

  handleCloseModal() {
    this.setState({show: false})
  }

});

var TransferButtons = React.createClass({
  displayName: 'TransferButtons',

  getInitialState() {
    return {show: false, defaults: {}, trip: this.props.trip.trip}
  },

  render() {
    return (
        <ButtonGroup>
          <Button {...this.props} onClick={() => this.handleShowModal('arrival')}>
            <i className="glyphicon glyphicon-transfer" />
            {' '} Transfer In
          </Button>

          <Button {...this.props} onClick={() => this.handleShowModal('departure')}>
            <i className="glyphicon glyphicon-transfer" />
            {' '} Out

            <CreateModal kind="transport"
                         trip={this.state.trip}
                         date={this.state.dateTime}
                         action={this.props.createUrl}
                         defaults={this.state.defaults}
                         onHide={this.handleHideModal}
                         visible={this.state.show} />
          </Button>
        </ButtonGroup>
    );
  },

  handleShowModal(which) {
    var trip = this.state.trip;
    var dateTime = moment.utc(trip[which]);
    let date = dateTime.toISOString().split('T').shift();
    var title = 'Transfer ' + (which === 'arrival' ? 'In' : 'Out');

    let transfers = ['pick_up', 'drop_off'];
    let flight = which === 'arrival' ? 'arrival_flight' : 'departure_flight';
    let location = which === 'arrival' ? this.props.dropOffs : this.props.pickUps;

    if (which === 'departure') transfers.reverse();

    var defaults = {
      num_people: trip.total_people,
      services: title,
      nights: 0
    };

    defaults[transfers.shift()] = [
      trip[flight],
      dateTime.format('h:mma')
    ].join(' ');

    defaults[transfers.shift()] = location[date];

    this.setState({show: true, defaults: defaults, dateTime: dateTime})
  },

  handleHideModal() {
    this.setState({show: false})
  }
});

var FtpButton = React.createClass({
  displayName: 'FtpButton',

  render: function() {
    return (
      <Button href={this.props.action}>
        <i className="glyphicon glyphicon-folder-open" />
        {' '}FTP Files
      </Button>
    );
  }
})

var PageButtons = React.createClass({
  displayName: 'PageButtons',

  render() {
    let {createUrl, pasteUrl, tripUrl, confirmUrl, ftpUrl, pickUps, dropOffs} = this.props;
    var trip = this.props.trip;

    return (
        <ButtonToolbar>
          <ButtonGroup>
            <Trips.QuickFormButton trip={trip}
                                   action={tripUrl} />
          </ButtonGroup>

          <TransferButtons trip={trip}
                           pickUps={pickUps}
                           dropOffs={dropOffs}
                           createUrl={createUrl} />

          <ButtonGroup>
            <ConfirmButton action={confirmUrl} confirmAll={true} />
            <PasteButton action={pasteUrl} />
            <FtpButton action={ftpUrl} />
          </ButtonGroup>

        </ButtonToolbar>
    )
  }
});

var ReservationButtons = React.createClass({
  render() {
    var style = this.props.bsStyle || 'default';
    var size = this.props.bsSize;
    var showNextModal = this.props.showNextModal;

    var {editUrl, deleteUrl, confirmUrl, mailUrl, reservation, kind} = this.props;

    var editButton, deleteButton, confirmButton;

    if (editUrl) {
      editButton = <EditButton action={editUrl}
                               kind={kind}
                               bsStyle={style}
                               bsSize={size}
                               reservation={reservation}/>
    }

    if (deleteUrl) {
      deleteButton = <DeleteButton action={deleteUrl}
                                   bsStyle={style}
                                   bsSize={size}/>
    }

    if (confirmUrl) {
      confirmButton = <ConfirmButton action={confirmUrl}
                                     mailUrl={mailUrl}
                                     showNextModal={showNextModal}
                                     bsStyle={style}
                                     bsSize={size}/>
    }

    return (
        <ButtonGroup>
          {editButton}
          {deleteButton}
          {confirmButton}
        </ButtonGroup>
    );
  }
});

module.exports = {
  Page: Page,
  PageButtons: PageButtons,
  ReservationButtons: ReservationButtons
};
