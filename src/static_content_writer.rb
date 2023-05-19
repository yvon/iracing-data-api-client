class StaticContentWriter
  def initialize(output_folder)
    @output_folder = output_folder
    @page_generator = PageGenerator.new
    @chart_data_generator = ChartDataGenerator.new
    @mutex = Mutex.new
  end

  def write_index_page(seasons:, assets:)
    content = @page_generator.index_page(seasons, assets)
    write('index.html', content)
  end

  def write_season_page(season:, assets:, car_classes:)
    content = @page_generator.season_page(season, assets, car_classes)
    write("#{season['season_id']}/index.html", content)
  end

  def write_chart_data(season:, event:, result:)
    @chart_data_generator.generate(season, event, result) do |filename, content|
      write(filename, content, mode: 'a')
    end
  end

  def write(filename, content, mode: 'w')
    full_path = File.join(@output_folder, filename)

    @mutex.synchronize do
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content, mode: mode)
    end
  end
end
