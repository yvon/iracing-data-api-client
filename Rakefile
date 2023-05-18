require 'rake'

Dir["./src/*.rb"].each { |file| require file }
Thread.abort_on_exception = true

task :authenticate do
  $client = Client.new
  $client.authenticate(ENV.fetch('IRACING_EMAIL'), ENV.fetch('IRACING_PASSWORD'))
end

task :seasons => :authenticate do
  $seasons = $client.data('/data/series/seasons')
end

task :assets => :authenticate do
  $assets = $client.data("/data/series/assets")
end

task :destination, [:destination] do |t, args|
  $destination = args.destination || 'out'
end

task :content_generator, [:destination] => :destination do |t, args|
  $content_generator = ContentGenerator.new($destination)
end

task :page_generator, [:destination] => [:seasons, :assets, :content_generator] do
  $page_generator = PageGenerator.new($content_generator)
end

desc 'Generate the index page'
task :generate_index, [:destination] => :page_generator do
  $page_generator.generate('index.html.erb', 'index.html', seasons: $seasons, assets: $assets)
end

desc 'Generate the season pages'
task :generate_seasons, [:destination] => :page_generator do
  car_classes = $client.data('/data/carclass/get')

  $seasons.each do |season|
    season_id = season['season_id']

    assigns = {
      season: season,
      week: season['schedules'].find { |e| e['race_week_num'] == season['race_week'] },
      car_classes: season['car_class_ids'].map { |id| car_classes.find { |e| e['car_class_id'] == id } },
      logo: $assets[season['series_id'].to_s]['logo'],
      page_title: season['season_name']
    }

    $page_generator.generate('season.html.erb', "#{season_id}/index.html", assigns)
  end
end

desc 'Generate all html pages'
task :generate_pages, [:destination] => [:generate_index, :generate_seasons]

desc 'Generate charts for all seasons'
task :generate_charts, [:destination] => [:seasons, :content_generator] do
  chart_data_generator = ChartDataGenerator.new($content_generator)
  event_fetcher = EventFetcher.new($client)
  result_fetcher = ResultFetcher.new($client)

  # 6 concurrent threads to the rescue
  thread_pool = ThreadPool.new(6)

  $seasons.each do |season|
    thread_pool.perform do
      event_fetcher.official_races(season) do |event|
        subsession_id = event['subsession_id']

        thread_pool.perform do
          data = result_fetcher.fetch(subsession_id)
          chart_data_generator.generate(season, event, data)
        end
      end
    end
  end

  thread_pool.start
end

desc 'Copy the assets'
task :copy_assets, [:destination] => :destination do |t, args|
  FileUtils.cp_r('./assets/.', $destination)
end

desc 'Generate all content'
task :generate, [:destination] => [:generate_pages, :generate_charts, :copy_assets]

task :default => :generate
