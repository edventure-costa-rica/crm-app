class SanitizedCollation
  attr_reader :connection
  attr_reader :name

  def initialize
    @name = 'SANITIZED'
    @connection = ActiveRecord::Base.connection.
        instance_variable_get(:@connection)
  end

  def define_collation(name=@name)
    @name = name
    connection.collation(name, self)
    self
  end

  def compare(a, b)
    atr = I18n.transliterate(a).downcase.gsub(/[^[:alpha:]]+/, '')
    btr = I18n.transliterate(b).downcase.gsub(/[^[:alpha:]]+/, '')

    atr <=> btr
  end

end
