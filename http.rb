require_relative 'container'
require_relative 'partial_date'

class Http
  def initialize
    @container = Container.new
    @container.parse_file('hn_logs.tsv')
  end

  def parse_query_string(query_string)
    params = {}
    query_string.split('&').each do |param|
      k, v = param.split('=')
      params[k] = v
    end
    params
  end

  def to_json(hash)
    ['200', { 'Content-Type' => 'application/json' }, [JSON.dump(hash)]]
  end

  def count_query(date_string)
    date = PartialDate.parse(date_string)

    to_json count: @container.count_distinct(date.year, date.month, date.day, date.hour, date.min, date.sec)
  end

  def popular_query(date_string, query_string)
    date = PartialDate.parse(date_string)
    params = parse_query_string(query_string)

    popular = nil
    if params['size'].nil?
      popular = @container.find_popular(date.year, date.month, date.day, date.hour, date.min, date.sec)
    else
      popular = @container.find_popular_with_limit(params['size'].to_i, date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    to_json({ queries: popular.map do |popular|
      { query: popular[0], count: popular[1] }
    end })
  end

  def router(path, query_string)
    case path
    when /\/1\/queries\/count\/(.+)/
      count_query($1)
    when /\/1\/queries\/popular\/(.+)/
      popular_query($1, query_string)
    else
      not_found
    end
  end

  def not_found
    ['404', { 'Content-Type' => 'text/html' }, ['Not found']]
  end

  def call(env)
    p env['PATH_INFO']
    p env['QUERY_STRING']
    if env['REQUEST_METHOD'] != 'GET'
      return not_found
    end

    router(env['PATH_INFO'], env['QUERY_STRING'])
    # ['200', { 'Content-Type' => 'text/html' }, ['get rackd']]
  end
end
