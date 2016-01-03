var React = require('react');
var ReactDOM = require('react-dom');
var components = require('components');

var $mountSearch = $('#mount-search'),
    searchUrl = $mountSearch.data('url');

ReactDOM.render(
    React.createElement(components.Search, {url: searchUrl}),
    $mountSearch.get(0)
);
