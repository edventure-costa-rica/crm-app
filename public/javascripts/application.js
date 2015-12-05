// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function debounce(fn, timeout) {
  if (timeout === undefined) timeout = 150;
  var timer;

  return function() {
    var args = Array.prototype.slice.call(arguments);

    if (timer) return;
    timer = setTimeout(function() {
      timer = null;
      fn.apply(null, args);
    }, timeout);
  };
}

$(function () {

  function toggleWithCheckbox(target, source, focus) {
    if ($(source).is(':checked')) {
      var $target = $(target).show();
      if (focus) $target.find('input').focus();
    }
    else {
      $(target).hide();
    }
  }

  $('#reservation_confirmed').on('change', function(ev, skipFocus) {
    toggleWithCheckbox('#toggle_confirm', this, !skipFocus)
  }).triggerHandler('change', true);

  $('#reservation_paid').on('change', function(ev, skipFocus) {
    toggleWithCheckbox('#toggle_paid', this, !skipFocus)
  }).triggerHandler('change', true);

  // workflow#client
  var $clientResults = $('#client-results');
  function showClientResults() {
    if ($clientResults.find('tr').length == 1) {
      $clientResults.stop(true, true).fadeOut()
    }
    else {
      $clientResults.stop(true, true).fadeIn()
    }
  }

  var $workflowClientQuery = $('#workflow_client').find('#q');

  function searchClients() {
    var query = $workflowClientQuery.val().replace(/^\s+|\s+$/g, ''),
        url = $workflowClientQuery.data('search-url');

    $.get(url, {q: query}, function(results) {
      $clientResults.find('tr:first').siblings().remove();
      showClientResults();

      results.forEach(function (client) {
        var tr = $('<tr/>');
        tr.append($('<td/>').text(client.contact));
        tr.append($('<td/>').text(client.family));
        tr.append($('<td/>').text(client.email));
        tr.append($('<td/>').append(
            $('<a>').addClass('btn btn-xs btn-default')
                .attr('href', '/workflow/' + client.id)
                .html('<i class="glyphicon glyphicon-arrow-right"></i>' +
                    '<span class="hidden-xs">Next</span>')
        ));
        $clientResults.append(tr);
      });

      showClientResults();
    });
  }

  showClientResults();
  $workflowClientQuery.on('input', debounce(searchClients));

});
