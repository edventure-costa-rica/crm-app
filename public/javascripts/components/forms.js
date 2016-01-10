var React = require('react');
var _ = require('lodash');
var moment = require('moment');
var chrono = require('chrono-node');
var DatePicker = require('react-date-picker');

var lib = require('../lib');

function onKeyDown(ev) {
  ev.persist();

  if (ev.key === 'Enter') {
    var $target = $(ev.target),
        $form = $target.closest('form'),
        $inputs = lib.formInputs($form),
        index = $inputs.index($target),
        hasModifier = ev.ctrlKey || ev.metaKey;

    // pressing enter within a textarea should act normally,
    // unless pressing a modifier key also
    if (! hasModifier && $target.prop('tagName') === 'TEXTAREA') {
      return;
    }

    ev.preventDefault();

    if (index === $inputs.length - 1 || hasModifier) {
      var submit = $form.find('[type=submit]');
      if (submit.length) submit.first().click();
      else $form.submit();
    }
    else {
      $inputs.eq(index + 1).focus();
    }
  }
}

var StaticField = React.createClass({
  displayName: 'StaticField',

  render: function() {
    return (
        <div className="form-group">
          <label className="control-label">{this.props.title}</label>
          <p className="form-control-static">{this.props.value}</p>
        </div>
    )
  }
});

var TextField = React.createClass({
  displayName: 'TextField',

  render: function() {
    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>

        <input type="text" className='form-control'
               onKeyDown={onKeyDown}
               required={Boolean(this.props.required)}
               defaultValue={this.props.defaultValue}
               valueLink={this.props.value}
               name={this.props.name}
               id={this.props.id} />
      </div>
    )
  }
});

var TextArea = React.createClass({
  displayName: 'TextArea',

  render: function() {
    return (
        <div className="form-group">
          <label htmlFor={this.props.id}>
            {this.props.title}
          </label>

          <textarea className='form-control'
                 onKeyDown={onKeyDown}
                 required={Boolean(this.props.required)}
                 defaultValue={this.props.defaultValue}
                 valueLink={this.props.value}
                 name={this.props.name}
                 id={this.props.id} />
        </div>
    )
  }
});

var NumberField = React.createClass({
  displayName: 'NumberField',

  render: function() {
    var range = _.pick(this.props, ['min', 'max', 'step']);

    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <input type="number" className='form-control'
               onKeyDown={onKeyDown}
               placeholder={this.props.title}
               required={Boolean(this.props.required)}
               defaultValue={this.props.defaultValue}
               valueLink={this.props.value} {...range}
               name={this.props.name}
               id={this.props.id} />
      </div>
    );
  }
});

var SelectField = React.createClass({
  displayName: 'SelectField',

  render: function() {
    var options = _(this.props.options).map(function (o) {
      if (typeof o !== 'object') {
        return {value: o, title: String(o)}
      }
      else if (Array.isArray(o)) {
        return {value: o[0], title: (o[1] || o[0])}
      }
      else {
        return o;
      }
    }).map(function (opt) {
      return (
        <option key={opt.value} value={opt.value}>{opt.title}</option>
      );
    }).value();

    if (this.props.prompt) {
      options.unshift(
        <option key="prompt">{this.props.prompt}</option>
      );
    }

    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <select className="form-control"
                onKeyDown={onKeyDown}
                valueLink={this.props.value}
                id={this.props.id} 
                name={this.props.name}>
          {options}
        </select>
      </div>
    )
  }
});

var PaxField = React.createClass({
  displayName: 'PaxField',
  statics: {
    ValidationRegExp: /^\d+(?:\/\d+){0,2}/,

    parsePax: function(value) {
      var parts = String(value).split('/').map(parseInt);

      return {
        total: (parts[0] || 0),
        children: (parts[1] || 0), 
        disabled: (parts[2] || 0)
      };
    },

    reformat: function(value) {
      var pax = this.parsePax(value);
      var output = String(pax.total);
      
      if (pax.children) {
        output += '/' + pax.children;
      }

      if (pax.disabled) {
        if (! pax.children) output += '/0';
        output += '/' + pax.disabled;
      }

      return output;
    },
  },

  render: function() {
    var events = _.pick(this.props, 'onBlur onFocus onChange'.split(' '));

    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <div className="input-group">
          <div className="input-group-addon">
            <i className="glyphicon glyphicon-user" />
          </div>

          <input type="text" className="form-control" {...events}
                 onKeyDown={onKeyDown}
                 placeholder="number of people"
                 required={Boolean(this.props.required)}
                 valueLink={this.props.value}
                 name={this.props.name}
                 id={this.props.id} />

        </div>
      </div>
    );
  }
});

var DateTimeField = React.createClass({
  displayName: 'DateTimeField',

  handleShowPicker: function(ev) {
    ev.preventDefault();

    var valid = this.validateValue(),
        date = moment(this.parseValue());

    this.setState({open: ! this.state.open, date: date, valid: valid});
  },

  handlePickDate: function(_, selected) {
    var prev = this.state.date;
    var dateTime = moment(selected)
        .hour(prev.hour())
        .minute(prev.minute())
        .second(prev.second());

    var format = this.props.noTime ? 'YYYY-MM-DD' : 'YYYY-MM-DD h:mm A';

    var formatted = dateTime.format('YYYY-MM-DD h:mm A');
    this.props.value.requestChange(formatted);

    this.setState({date: dateTime, valid: true});

    this.hidePicker();
  },

  hidePicker: function() {
    this.setState({open: false});
  },

  validateValue: function() {
    if (! this.props.value.value) return true;

    var dt = this.parseValue();
    return moment(dt).isValid();
  },

  parseValue: function() {
    var string = this.props.value.value;

    if (! string) return new Date();

    return chrono.parseDate(string);
  },

  getInitialState: function() {
    var value = this.parseValue(),
        valid = this.validateValue(),
        initialDate = valid ? moment(value) : moment().startOf('day');

    return {open: false, valid: valid, date: initialDate};
  },

  render: function() {
    var events = _.pick(this.props, 'onBlur onFocus onChange'.split(' '));
    var classes = 'form-group datetime-container';
    var picker;

    if (! this.state.valid) classes += ' has-error';

    if (this.state.open) {
      picker = React.createElement(DatePicker, {
        minDate: this.props.min,
        maxDate: this.props.max,
        date: this.state.date,
        onChange: this.handlePickDate,
        hideFooter: true
      });
    }

    return (
      <div className={classes}>
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <div className="input-group">

          <input type="datetime"
                 className="form-control" {...events}
                 placeholder="date and time"
                 onKeyDown={onKeyDown}
                 required={Boolean(this.props.required)}
                 valueLink={this.props.value}
                 name={this.props.name}
                 id={this.props.id} />

          <div className="datetime">
            {picker}
          </div>

          <div className="input-group-btn">
            <button className="btn btn-default" tabIndex="-1"
                    onClick={this.handleShowPicker}>
              <i className="glyphicon glyphicon-calendar" />
            </button>
          </div>
        </div>
      </div>
    );
  }
});

var PriceField = React.createClass({
  displayName: 'PriceField',

  render: function() {
    var range = _.pick(this.props, ['min', 'max', 'step']);
    range.min = range.min || 0;

    var events = _.pick(this.props, 'onBlur onFocus onChange'.split(' '));

    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <div className="input-group">
          <div className="input-group-addon">
            <i className="glyphicon glyphicon-usd" />
          </div>

          <input type="number" className="form-control" {...events}
                 onKeyDown={onKeyDown}
                 required={Boolean(this.props.required)}
                 defaultValue={this.props.defaultValue}
                 valueLink={this.props.value} {...range}
                 name={this.props.name}
                 id={this.props.id} />

        </div>
      </div>
    );
  }
});

module.exports = {
  PaxField: PaxField,
  PriceField: PriceField,
  DateTimeField: DateTimeField,
  TextField: TextField,
  TextArea: TextArea,
  NumberField: NumberField,
  SelectField: SelectField,
  StaticField: StaticField
}
