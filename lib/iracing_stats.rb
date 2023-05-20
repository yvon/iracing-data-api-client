require_relative 'iracing_stats/app'

module IracingStats
  def self.app
    @app ||= App.new
  end
end
