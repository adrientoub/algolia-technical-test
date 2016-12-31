class PartialDate
  attr_reader :date

  # stores a date Array, in the form [year, month, day, hour, min, sec]
  def initialize(date)
    @date = date
  end

  def self.parse(date)
    date_part, time_part = date.split('%20')
    y, m, d = date_part.split('-')

    date_arr = [y.to_i, m&.to_i, d&.to_i].compact
    unless m.nil? || d.nil? || time_part.nil?
      h, min, s = time_part.split(':')
      date_arr += [h&.to_i, min&.to_i, s&.to_i].compact
    end
    PartialDate.new(date_arr)
  end
end
