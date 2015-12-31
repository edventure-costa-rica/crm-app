var React = require('react');
var _ = require('lodash');
var moment = require('moment');
var DateTime = require('react-datetime');

var TextField = React.createClass({
  displayName: 'TextField',

  render: function() {
    return (
      <div className="form-group">
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>

        <input type="text" className='form-control'
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
        disabled: (parsts[2] || 0)
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
                 placeholder="pax/children/disabled"
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

  showPicker: function(ev) {
    ev.preventDefault();

    this.refs.picker.openCalendar();
  },

  pickDate: function(dt) {
    if (typeof dt === 'string') {
      this.setState({valid: false})
    }
    else {
      this.props.value.requestChange(dt.format('YYYY-MM-DD h:mm A'))
    }
  },

  getInitialState: function() {
    return {valid: true};
  },

  render: function() {
    var events = _.pick(this.props, 'onBlur onFocus onChange'.split(' '));

    var picker = React.createElement(DateTime, {
      input: false,
      defaultValue: this.props.value.value,
      onChange: this.pickDate,
      open: false,
      dateFormat: 'YYYY-MM-DD',
      timeFormat: 'h:mm A',
      ref: 'picker'
    });

    var classes = 'form-group datetime-container';
    if (! this.state.valid) classes += ' has-error';

    return (
      <div className={classes}>
        <label htmlFor={this.props.id}>
          {this.props.title}
        </label>
        
        <div className="input-group">

          <input type="text" className="form-control" {...events}
                 placeholder="date and time"
                 required={Boolean(this.props.required)}
                 valueLink={this.props.value}
                 name={this.props.name}
                 id={this.props.id} />

          <div className="datetime">
            {picker}
          </div>

          <div className="input-group-btn">
            <button className="btn btn-default" tabIndex="-1"
                    onClick={this.showPicker}>
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
  NumberField: NumberField,
  SelectField: SelectField
}
