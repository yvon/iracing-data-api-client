class DataExplorer
  def initialize(data_proxy, thread_pool = nil)
    @data_model = DataModel.new(data_proxy)
    @thread_pool = thread_pool
  end

  def explore
    assets = @data_model.assets
    car_classes = @data_model.car_classes
    seasons = @data_model.seasons

    yield(:index, seasons: seasons, assets: assets) if block_given?

    seasons.each do |season|
      yield(:season, season: season, assets: assets, car_classes: car_classes) if block_given?

      parallelize do
        events(season).each do |event|
          parallelize do
            result = @data_model.result(event)
            yield(:chart_data, season: season, event: event, result: result) if block_given?
          end
        end
      end
    end

    start
  end

  private

  def parallelize(&block)
    @thread_pool ? @thread_pool.perform(&block) : block.call
  end

  def start
    @thread_pool&.start
  end

  def events(season)
    result_list = @data_model.season_results(season)['results_list']

    result_list.filter do |event|
      event['event_type_name'] == 'Race' && event['official_session'] == true
    end
  end
end
