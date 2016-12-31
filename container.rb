require 'date'
require 'set'

class Container
  def initialize
    @content = {}
  end

  # parses an input tsv file containing date\tquery
  def parse_file(filename)
    start = Time.now
    open filename do |file|
      data = {}
      i = 0
      file.each do |line|
        date, query = line.chomp.split("\t")

        insert(date, query)
        i += 1
      end
      puts "Successfully read #{i} lines."
    end
    puts "Done in #{Time.now - start} seconds."
  end

  private

  # inserts a value in the prefix tree
  # date: String describing a date of the form 'YYYY-MM-DD HH-mm-ss'
  # value: any query you want to insert into the tree
  def insert(date, value)
    date_time = DateTime.parse(date)
    # Create necessary fields if they do not exist
    @content[date_time.year] ||= {}
    @content[date_time.year][date_time.month] ||= {}
    @content[date_time.year][date_time.month][date_time.day] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min] ||= {}
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min][date_time.sec] ||= []
    @content[date_time.year][date_time.month][date_time.day][date_time.hour][date_time.min][date_time.sec] << value
  end

  def find_distinct(struct, set)
    if struct.is_a?(Hash)
      struct.each do |_, value|
        find_distinct(value, set)
      end
    else # struct.is_a?(Array)
      set.merge(struct)
    end
  end

  def distinct_in_structure(struct)
    return 0 if struct.nil?
    set = Set.new
    find_distinct(struct, set)
    set.size
  end

  # adds all values of hash2 into hash1 and returns hash1
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

  public

  # count the distinct queries for a specific timeframe
  # should be given in the correct order:
  #   year, month, day, hour, min, sec
  def count_distinct(*date)
    distinct_in_structure(@content.dig(*date))
  end

  # finds all the 'limit' most popular queries
  def find_popular_with_limit(limit, *date)
    populars = find_popular(*date)
    populars.max_by(limit) do |_, item|
      item
    end
  end

  # finds all queries done at a specific time and their count
  def find_popular(*date)
    find_popular_in_structure(@content.dig(*date))
  end
end
