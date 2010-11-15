# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>

class ConfirmationReport < ProposalReport
  @template_filename = 'contrib/proposal-template.odt'

  def initialize(trip)
    super
  end
end
