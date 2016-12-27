class PartialDate
  attr_reader :year, :month, :day, :hour, :min, :sec

  def initialize(year, month=-1, day=-1, hour=-1, min=-1, sec=-1)
    @year = year
    @month = month
    @day = day
    @hour = hour
    @min = min
    @sec = sec
  end

  def self.parse(date)
    date_part, time_part = date.split('%20')
    y, m, d = date_part.split('-')

    if m.nil?
      PartialDate.new(y.to_i)
    elsif d.nil?
      PartialDate.new(y.to_i, m.to_i)
    elsif time_part.nil?
      PartialDate.new(y.to_i, m.to_i, d.to_i)
    else
      h, min, s = time_part.split(':')
      if min.nil?
        PartialDate.new(y.to_i, m.to_i, d.to_i, h.to_i)
      elsif s.nil?
        PartialDate.new(y.to_i, m.to_i, d.to_i, h.to_i, min.to_i)
      else
        PartialDate.new(y.to_i, m.to_i, d.to_i, h.to_i, min.to_i, s.to_i)
      end
    end
  end
end
