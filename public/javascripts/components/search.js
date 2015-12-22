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

  hideSearch: function() {
    this.setState({query: ''})
  },

  render: function() {
    console.log('Search', this.state);

    var content = (
        <SearchResults data={this.state.results}
                       loading={this.state.loading} />
    );

    return (
        <form action={this.props.url}
              onSubmit={function(e) { e.preventDefault() }}
              className="navbar-form navbar-left">
          <div className="form-group">
            <label htmlFor="search-query" className="sr-only">Search</label>
            <input type="search" name="q"
                   value={this.state.query}
                   onChange={this.handleQueryChange}
                   onBlur={this.hideSearch}
                   id="search-query"
                   className="form-control"
                   autoComplete="off"
                   placeholder="Search Clients" />

          </div>
          {this.state.query.length ? content : '' }
        </form>
    )
  }
});

var SearchResults = React.createClass({
  render: function () {
    var content;
    console.log('SearchResults', this.props);

    if (this.props.loading) {
      content = <SearchLoading />
    }

    else if (this.props.data.length) {
      content = _.map(this.props.data, function (result) {
        return <SearchResult url={result.url}
                             name={result.name}
                             phone={result.phone}
                             email={result.email}/>

      })
    }

    else {
      content = <SearchNoResults />
    }

    return (
        <div id="search-results" className="list-group">
          {content}
        </div>
    )
  }
});

var SearchResult = React.createClass({
  render: function () {
    var email, phone, br = <br/>;
    console.log('SearchResult', this.props);

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

var SearchNoResults = React.createClass({
  render: function() {
    console.log('SearchNoResults');
    return (
        <div className="list-group-item">
          <h4 className="list-group-item-heading">
            <i className="glyphicon glyphicon-ban-circle"/>
            &nbsp; No Results
          </h4>
          <p className="list-group-item-text">
            Try changing your search criteria
          </p>
        </div>
    )
  }
});

var SearchLoading = React.createClass({
  render: function() {
    console.log('SearchLoading');
    return (
        <div className="list-group-item">
          <h4 className="list-group-item-heading">
            <i className="glyphicon glyphicon-refresh spin"/>
            &nbsp; Loading...
          </h4>

          <p className="list-group-item-text">
            Please wait
          </p>
        </div>
    )
  }
});


module.exports = Search;
