class EventFetcher
  def initialize(client)
    @client = client
  end

  def official_races(season)
    results = @client.data(data_path(season))

    results['results_list'].each do |event|
      next unless event['event_type_name'] == 'Race'
      next unless event['official_session'] == true

      yield event
    end
  end

  private

  def data_path(season)
    season_id = season['season_id']
    race_week = season['race_week']
    "/data/results/season_results?season_id=#{season_id}&race_week_num=#{race_week}"
  end
end
