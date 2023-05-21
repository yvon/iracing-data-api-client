require 'csv'

require_relative 'client'
require_relative 'chart_data_generator'
require_relative 'page_generator'
require_relative 'data_reader'
require_relative 'data_writer'

module IracingStats
  class App
    def initialize
      @client = Client.new
      @chart_data_generator ||= ChartDataGenerator.new
      @page_generator ||= PageGenerator.new
      @data_reader = DataReader.new
      @data_writer = DataWriter.new(@client)

      @client.authenticate(ENV.fetch('IRACING_EMAIL'), ENV.fetch('IRACING_PASSWORD'))
    end

    def generate_index_page(filename, seasons, assets)
      content = @page_generator.index_page(seasons, assets)
      File.write(filename, content)
    end

    def generate_season_page(filename, season, assets, car_classes)
      content = @page_generator.season_page(season, assets, car_classes)

      FileUtils.mkdir_p(File.dirname(filename))
      File.write(filename, content)
    end

    def generate_chart_content(file_format, result_files)
      files = Hash.new do |h, k|
        FileUtils.mkdir_p(File.dirname(k))
        h[k] = CSV.open(k, 'w')
      end

      result_files.each do |result_file|
        result = @data_reader.data(result_file)

        @chart_data_generator.generate(result) do |keys, data|
          files[file_format % keys] << data
        end
      end

      files.each { |_, file| file.close }
    end

    def fetch_and_store(filename)
      @data_writer.fetch_and_store(filename)
    end
  end
end
