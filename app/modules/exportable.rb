module Exportable
  def self.included(mod)
    mod.extend ClassMethods
  end

  def export(style = :default)
    attributes = self.class.export_styles.fetch(style)

    attributes.map do |attr|
      if attr.is_a? Proc
        self.instance_exec(&attr)
      else
        self.send(attr)
      end
    end
  end

  module ClassMethods
    attr_reader :export_styles

    def export(style, attributes=[], &blk)
      @export_styles ||= Hash.new

      if style.is_a? Array
        attributes = style
        style = :default
      else
        style = style.to_sym
      end


      if block_given?
        export_styles[style] = blk.call
      else
        export_styles[style] = attributes
      end
    end

  end
end
