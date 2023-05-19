class DataModel
  def initialize(data_proxy)
    @data_proxy = data_proxy
  end

  def assets
    data("/data/series/assets")
  end
  
  def seasons
    data('/data/series/seasons')
  end

  def car_classes
    data('/data/carclass/get')
  end

  def season_results(season)
    season_id = season['season_id']
    race_week = season['race_week']

    data('/data/results/season_results', season_id: season_id, race_week_num: race_week)
  end

  def result(event)
    subsession_id = event['subsession_id']
    data('/data/results/get', subsession_id: subsession_id)
  end

  private

  def url(path, params = {})
    query_string = URI.encode_www_form(params)
    path = "#{path}?#{query_string}" unless query_string.empty?
    path
  end

  def data(path, params = {})
    @data_proxy.data(url(path, params))
  end
end
