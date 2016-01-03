var lib = {
  formInputs: function formInputs(form) {
    var $form = $(form);

    var types = [':button',':reset',':submit',':disabled','[type="hidden"]'],
        selector = types.map(function(s) { return ':not(' + s + ')' }).join('');

    return $form.find(':input' + selector);
  },

  guessInput: function guessInput(inputs) {
    var $inputs = $(inputs)
        .filter(function() { return this.value === '' });

    if ($inputs.length === 0) {
      $inputs = $inputs.end();
    }

    return $inputs.first();
  },

  selectInput: function selectInput(input) {
    var $input = $(input);

    if ($input.val() === '') {
      $input.focus();
    }
    else {
      $input.select();
    }
  },

  selectFormInput: function selectFormInput(form) {
    var inputs = lib.formInputs(form),
        first = lib.guessInput(inputs);

    lib.selectInput(first);
  }
};


module.exports = lib;
