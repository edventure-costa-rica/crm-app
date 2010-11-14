# (C) Copyright 2010 Josh Leder (slushie) <josh@ha.cr>
require 'serenity'

class OpenDocumentReport < Serenity::Template
  def initialize(template, output = nil)
    
    if output.nil?
      # create a temporary file to use as output
      @output_tmp = Tempfile.new File.basename(template, '.odt')
      @output_tmp.close
      @output = @output_tmp.path
    else
      @output = File.expand_path(output)
    end

    super(template, @output)
  end

  # as a string, use the output filename
  def to_s
    @output
  end

  # this will render and return the output .odt as a string
  def to_odt
    self.process binding
    IO.read @output
  end
end
