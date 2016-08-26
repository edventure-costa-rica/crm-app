class ExcelParser
  attr_reader :errors

  def initialize(data)
    @data = data
    @errors = []
    @collation = SanitizedCollation.new.define_collation
  end

  def error?
    errors.size > 0
  end

  def reservations(trip)
    @reservations ||= parse_entries(trip).map do |entry|
      trip.reservations.build(entry)
    end
  end

  private

=begin

DIA	LUGAR	HOTEL	MEALS	TIPO HABITACION	TARIFA HAB 1	TARIFA HAB 2
8	San Jose	Ed & Breakfast	Ontbijt	2 Tweepersoons kamers	100
9	San Jose	Ed & Breakfast	Ontbijt	2 Tweepersoonskamers	100
10	Tortuguero	Laguna Lodge	Ontbijt, lunch, diner	2 Tweepersoonskamers	299	299
11	Tortuguero	Laguna Lodge	Ontbijt, lunch, diner	2 Tweepersoonskamers	299	299
12	Manzanillo	Congo Bongo	-	Junglehuis met keuken	148	24
13	Manzanillo	Congo Bongo	-	Junglehuis met keuken	148	24
14	Manzanillo	Congo Bongo	-	Junglehuis met keuken	148	24
15	Bribri	Indianendorp	Ontbijt, lunch, diner	Lokale familie	250	250
16	Sarapiqui	Finca Sura	Ontbijt	2 Tweepersoonskamers	80	80
17	Sarapiqui	Finca Sura	Ontbijt	2 Tweepersoonskamers	80	80

 ...

=end

  def parse_entries(trip)
    @data.each_line.each_with_index.reduce([]) do |entries, line_info|
      line_no = line_info.pop
      line = line_info.pop

      next entries unless line =~ /^\d/

      begin
        columns = line.split(/\t/)
        company_name = columns[2]
        services = columns.values_at(3, 4).grep(/\w/).join(", ")
        price = columns.from(5).map(&:to_f).reduce(0, &:+)

        date = Date.parse(columns.first)
        raise "Cannot parse date #{columns.first}" unless date and date > trip.arrival.to_date

        day = (date - trip.arrival.to_date).to_i

        raise "Cannot find company named #{company_name}" unless
            (company = find_hotel(company_name))

        if not entries.empty? and company == entries.last[:company]
          entry = entries.last
          entry[:nights] += 1
          entry[:price] += price

        else
          entry = Hash.new
          entry[:day] = day
          entry[:company] = company
          entry[:price] = price
          entry[:nights] = 1
          entry[:services] = services
          entry[:num_people] = trip.total_people

          Rails.logger.info "*** entry: #{entry.inspect}"
          entries.push(entry)
        end

      rescue => ex
        errors.push "Error on line #{line_no}: #{ex}"
      end

      entries
    end
  end

  def find_hotel(name)
    name = name.gsub('%', '')
    wildcard = lambda { |x| ['%', x, '%'].join }
    condition = "name LIKE ? COLLATE #{@collation.name}"
    longest = name.split(/\s+/).max_by { |w| w.length }

    Company.first(conditions: [condition, wildcard.call(name)]) or
        Company.first(conditions: [condition, wildcard.call(longest)])
  end
end
