# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>

class ConfirmationReport < ProposalReport
  @template_filename = 'contrib/confirmation-template.odt'

  def initialize(trip)
    @due_date = trip.arrival_date - 6.weeks
    super
  end
end
