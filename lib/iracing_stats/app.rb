require 'csv'

require_relative 'client'
require_relative 'chart_data_generator'
require_relative 'page_generator'
require_relative 'data_reader'
require_relative 'data_writer'

module IracingStats
  class App
    SEASON_RESULTS_PATH = 'data/results/season_results?season_id=%d&race_week_num=%d'

    def initialize
      @client = Client.new
      @chart_data_generator ||= ChartDataGenerator.new
      @page_generator ||= PageGenerator.new
      @data_reader = DataReader.new
      @data_writer = DataWriter.new(@client)

      @client.authenticate(ENV.fetch('IRACING_EMAIL'), ENV.fetch('IRACING_PASSWORD'))
    end

    def seasons
      @seasons ||= @data_reader.data('data/series/seasons')
    end

    def assets
      @assets ||= @data_reader.data('data/series/assets')
    end

    def car_classes
      @car_classes ||= @data_reader.data('data/carclass/get')
    end

    def season_results(season_id, race_week)
      @data_reader.data(SEASON_RESULTS_PATH % [season_id, race_week])
    end

    def generate_index_page(filename)
      content = @page_generator.index_page(seasons, assets)
      File.write(filename, content)
    end

    def generate_season_page(filename, season)
      content = @page_generator.season_page(season, assets, car_classes)

      FileUtils.mkdir_p(File.dirname(filename))
      File.write(filename, content)
    end

    def generate_chart_content(folder, result_files)
      files = Hash.new do |h, k|
        FileUtils.mkdir_p(File.dirname(k))
        h[k] = CSV.open(k, 'w')
      end

      result_files.each do |result_file|
        result = @data_reader.data(result_file)

        @chart_data_generator.generate(result) do |car_class_id, session_type, data|
          filename = "#{folder}/#{car_class_id}/#{session_type}.csv"
          files[filename] << data
        end
      end

      files.each { |_, file| file.close }
    end

    def fetch_and_store(filename)
      @data_writer.fetch_and_store(filename)
    end
  end
end
