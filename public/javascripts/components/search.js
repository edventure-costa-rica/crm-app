var _ = require('lodash');

var Search = React.createClass({
  getInitialState: function() {
    return {query: '', results: []}
  },

  handleQueryChange: function(ev) {
    var sanitized = String(ev.target.value).trim();
    this.setState({query: sanitized});

    this.performSearch();
  },

  performSearch: _.debounce(function performSearch() {
    $.ajax({
      url: this.props.url,
      data: {q: this.state.query},
      success: function(results) {
        if (this.isMounted()) {
          this.setState({results: results, query: this.state.query});
        }

      }.bind(this)
    })
  }),

  render: function() {
    return (
        <form action={this.props.url} className="navbar-form navbar-left">
          <div className="form-group">
            <label htmlFor="search-query" className="sr-only">Search</label>
            <input type="search" name="q"
                   value={this.state.query}
                   onChange={this.handleQueryChange}
                   id="search-query"
                   className="form-control"
                   autoComplete="off"
                   autoFocus={true}
                   placeholder="Search Clients" />

          </div>
          <SearchResults data={this.state.results} />
        </form>
    )
  }
});

var SearchResults = React.createClass({
  render: function () {
    return (
        <div id="search-results" className="list-group">
          {
              _.map(this.props.data, function (result) {
                return <SearchResult url={result.url}
                                     name={result.name}
                                     phone={result.phone}
                                     email={result.email}/>

              })
          }
        </div>
    )
  }
});

var SearchResult = React.createClass({
  render: function () {
    var email, phone, br = <br/>;

    if (this.props.email) {
      email = (
        <span>
          <i className="glyphicon glyphicon-envelope"/>
          &nbsp; {String(this.props.email).toLowerCase()}
        </span>
      )
    }

    if (this.props.phone) {
      phone = (
        <span>
          <i className="glyphicon glyphicon-phone"/>
          &nbsp; {this.props.phone}
        </span>
      )
    }

    return (
        <a href={this.props.url} className="list-group-item">
          <h4 className="list-group-item-heading">{this.props.name}</h4>
          <p className="list-group-item-text">
            {email} {email && phone ? br : ''} {phone}
          </p>
        </a>
    )
  }
});


module.exports = Search;
