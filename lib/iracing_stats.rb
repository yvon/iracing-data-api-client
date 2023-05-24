require_relative 'iracing_stats/app'

module IracingStats
  @mutex = Mutex.new

  def self.app
    @mutex.synchronize do
      @app ||= App.new
    end
  end
end
