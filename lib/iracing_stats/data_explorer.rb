module IracingStats
  module DataExplorer
    ENDPOINTS = {
      result: 'data/results/get?subsession_id=%d'
    }.freeze

    def self.select_result_endpoints(season_results)
      # We exclude unofficials and practice sessions
      results_list = season_results[:results_list].filter do |event|
        event[:event_type_name] == 'Race' && event[:official_session] == true
      end

      # Identify the result files
      results_list.map { |event| ENDPOINTS[:result] % event[:subsession_id] }
    end
  end
end
