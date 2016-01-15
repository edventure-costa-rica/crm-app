var _ = require('lodash');
var React = require('react');

var Search = React.createClass({
  getInitialState: function() {
    return {query: '', results: [], loading: false}
  },

  handleQueryChange: function(ev) {
    var sanitized = String(ev.target.value).trim();

    if (sanitized) {
      this.setState({query: sanitized, loading: true});
      this.performSearch();
    }

    else {
      this.setState(this.getInitialState());
    }
  },

  performSearch: _.debounce(function performSearch() {
    $.ajax({
      url: this.props.url,
      data: {q: this.state.query},
      success: function(results) {
        if (this.isMounted()) {
          this.setState({loading: false, results: results});
        }

      }.bind(this)
    })
  }),

  render: function() {
    console.log('Search', this.state);

    var content = (
        <SearchResults data={this.state.results}
                       loading={this.state.loading} />
    );

    return (
        <form action={this.props.url}
              onSubmit={function(e) { e.preventDefault() }}>

          <div className="form-group">
            <label htmlFor="search-query" className="sr-only">Search</label>
            <input type="search" name="q"
                   value={this.state.query}
                   onChange={this.handleQueryChange}
                   id="search-query"
                   className="form-control"
                   autoComplete="off"
                   placeholder="name, email, or phone" />

          </div>
          {this.state.query.length ? content : ''}
        </form>
    )
  }
});

var SearchResults = React.createClass({
  render: function () {
    if (this.props.loading) {
      return <SearchLoading />
    }

    else if (this.props.data.length) {
      var content = _.map(this.props.data, function (result, index) {
        return <SearchResult key={index}
                             url={result.url}
                             name={result.name}
                             phone={result.phone}
                             email={result.email} />

      });


      return (
          <table className="table table-striped">
            {content}
          </table>
      )
    }

    else {
      return <SearchNoResults />
    }
  }
});

var SearchResult = React.createClass({
  render: function () {
    var email, emailData, phone, phoneData

    if (this.props.email) {
      emailData = String(this.props.email)
          .toLowerCase()
          .trim()
          .replace(/^\W*|\W*$/, '');

      email = (
        <span>
          <i className="glyphicon glyphicon-envelope"/>
          &nbsp;
          <a href={"mailto:" + emailData}>
            {emailData}
          </a>
        </span>
      )
    }

    if (this.props.phone) {
      phoneData = String(this.props.phone).trim().replace(/\D/g, '');

      phone = (
        <span>
          <i className="glyphicon glyphicon-phone"/>
          &nbsp;
          <a href={"tel:" + phoneData}>
            {this.props.phone}
          </a>
        </span>
      )
    }

    return (
        <tr>
          <td>
            <i className="glyphicon glyphicon-user" />
            &nbsp;
            <a href={this.props.url}>
              {this.props.name}
            </a>
          </td>

          <td>
            {email}
          </td>

          <td>
            {phone}
          </td>
        </tr>
    )
  }
});

var SearchNoResults = React.createClass({
  render: function() {
    return (
        <div className="alert alert-danger">
          <strong>
            <i className="glyphicon glyphicon-remove" />
            &nbsp; No results
          </strong>

          &nbsp; Sorry, nothing was found matching your search criteria.
        </div>
    )
  }
});

var SearchLoading = React.createClass({
  render: function() {
    return (
        <div className="alert alert-info">
          <strong>
            <i className="glyphicon glyphicon-refresh spin"/>
            &nbsp; Loading...
          </strong>

          &nbsp; Please wait while we query the server.
        </div>
    )
  }
});


module.exports = Search;
