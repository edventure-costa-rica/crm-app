function switchTab(ev) {
  var button = ev ? ev.findElement('a') : this;
  var tab = $(button.id.sub(/^tab-button-/, 'tab-'));

  // select the button
  $$('.tab-button').invoke('removeClassName', 'tab-button-selected');
  button.addClassName('tab-button-selected');

  // show the tab
  $$('.tab').invoke('hide');
  tab.show();
}

document.observe('dom:loaded', function() {
  $$('.tab-button').invoke('observe', 'click', switchTab).
                    invoke('show');

  var first = $$('.tab-button')[0];
  if (first) switchTab.apply(first, null);
});