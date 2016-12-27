require 'json'
require 'date'
require 'set'

class Container
  def initialize
    @content = {}
  end

  def insert(date, value)
    date_time = DateTime.parse(date)
    @content[date_time.year] ||= {}
    @content[date_time.year][date_time.month] ||= {}
    @content[date_time.year][date_time.month][date_time.day] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min][date_time.sec] ||= []
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min][date_time.sec] << value
  end

  def count_in_structure(struct)
    if struct.is_a?(Hash)
      count = 0
      struct.each do |_, value|
        count += count_in_structure(value)
      end
      count
    else struct.is_a?(Array)
      struct.size
    end
  end

  def find_distinct(struct)
    set = Set.new
    if struct.is_a?(Hash)
      struct.each do |_, value|
        set = set | find_distinct(value)
      end
      set
    else # struct.is_a?(Array)
      Set.new(struct)
    end
  end

  def distinct_in_structure(struct)
    find_distinct(struct).size
  end

  def merge_hash(hash1, hash2)
    hash2.each do |k, count|
      hash1[k] ||= 0
      hash1[k] += count
    end
    hash1
  end

  def find_popular_in_structure(struct)
    if struct.is_a?(Hash)
      hash = {}
      struct.each do |_, value|
        merge_hash(hash, find_popular_in_structure(value))
      end
      hash
    else # struct.is_a?(Array)
      hash = {}
      struct.each do |value|
        hash[value] ||= 0
        hash[value] += 1
      end
      hash
    end
  end

  def count_distinct(year, month=-1, day=-1, hour=-1, min=-1, sec=-1)
    if month == -1
      distinct_in_structure(@content[year])
    elsif day == -1
      distinct_in_structure(@content[year][month])
    elsif hour == -1
      distinct_in_structure(@content[year][month][day])
    elsif min == -1
      distinct_in_structure(@content[year][month][hour])
    elsif sec == -1
      distinct_in_structure(@content[year][month][hour][min])
    else
      distinct_in_structure(@content[year][month][hour][min][sec])
    end
  end

  def count(year, month=-1, day=-1, hour=-1, min=-1, sec=-1)
    if month == -1
      count_in_structure(@content[year])
    elsif day == -1
      count_in_structure(@content[year][month])
    elsif hour == -1
      count_in_structure(@content[year][month][day])
    elsif min == -1
      count_in_structure(@content[year][month][hour])
    elsif sec == -1
      count_in_structure(@content[year][month][hour][min])
    else
      count_in_structure(@content[year][month][hour][min][sec])
    end
  end

  def find_popular_with_limit(limit, year, month=-1, day=-1, hour=-1, min=-1, sec=-1)
    populars = find_popular(year, month, day, hour, min, sec)
    populars.max_by(limit) do |key, item|
      item
    end
  end

  def find_popular(year, month=-1, day=-1, hour=-1, min=-1, sec=-1)
    if month == -1
      find_popular_in_structure(@content[year])
    elsif day == -1
      find_popular_in_structure(@content[year][month])
    elsif hour == -1
      find_popular_in_structure(@content[year][month][day])
    elsif min == -1
      find_popular_in_structure(@content[year][month][hour])
    elsif sec == -1
      find_popular_in_structure(@content[year][month][hour][min])
    else
      find_popular_in_structure(@content[year][month][hour][min][sec])
    end
  end
end

container = Container.new
open 'hn_logs.tsv' do |file|
  data = {}
  file.each do |line|
    date, query = line.split("\t")

    container.insert(date, query)
  end
  puts "filled container"

  # p container.count(2015)
  # p container.count_distinct(2015)
  # p container.count(2015, 8)
  # p container.count_distinct(2015, 8)
  # p container.count(2015, 8, 3)
  # p container.count_distinct(2015, 8, 3)
  p container.find_popular_with_limit(5, 2015)
end
