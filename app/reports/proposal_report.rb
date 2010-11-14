# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>

class ProposalReport < OpenDocumentReport
  class << self; attr_reader :template_filename; end
  @template_filename = 'contrib/proposal-template.odt'

  def initialize(trip)
    @trip = trip
    @client = @trip.client
    @reservations = @trip.reservations.to_a

    # list of countries visited
    @countries = @reservations.collect { |res| res.company.region.country }
    @countries.uniq!

    super(ProposalReport.template_filename)
  end

end
