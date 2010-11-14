# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>
require 'serenity'

class OpenDocumentReport < Serenity::Template
  class << self; attr_reader :template_filename; end
  @template_filename = nil

  def initialize(template = self.class.template_filename, output = nil)
    if output.nil?
      # create a temporary file to use as output
      File.mkpath 'tmp/reports'
      @output_tmp = Tempfile.new File.basename(template, '.odt'), 'tmp/reports'
      @output_tmp.close
      @output = @output_tmp.path
    else
      @output = File.expand_path(output)
    end

    super(template, @output)
  end

  def render
    self.process binding
  end

  # as a string, use the output filename
  def to_s
    @output
  end

  # this will render and return the output .odt as a string
  def to_odt
    render
    IO.read @output
  end
end
