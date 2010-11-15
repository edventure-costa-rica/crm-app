# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>

class ProposalReport < OpenDocumentReport
  @template_filename = 'contrib/proposal-template.odt'

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TranslationHelper

  def initialize(trip)
    @trip = trip
    @client = @trip.client
    @reservations = @trip.reservations.to_a
    @people = @trip.people.to_a

    # list of countries visited
    @countries = @reservations.collect { |res| res.company.region.country }
    @countries = @countries.uniq.to_sentence

    @inclusive = @reservations.select { |res| res.company.all_inclusive }
    @inclauto = @reservations.select { |res| res.company.includes_transport }
    @incltour = @reservations.select { |res| res.company.includes_tour }

    # some helpers for specific reservation types
    @cars   = @reservations.select { |res| res.company.transport? }
    @hotels = @reservations.select { |res| res.company.hotel? }

    super()
  end

end
