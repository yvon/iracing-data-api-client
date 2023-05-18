require 'rake'

Dir["./src/*.rb"].each { |file| require file }
Thread.abort_on_exception = true

desc 'Prepare the shared data'
task :prepare_shared_data, [:destination] do |t, args|
  raise ArgumentError, "You must provide a destination_folder" unless args.destination

  $client = Client.new
  $client.authenticate(ENV['IRACING_EMAIL'], ENV['IRACING_PASSWORD'])

  $content_generator = ContentGenerator.new(args.destination)
  $content_generator.copy('static/app.js')

  $seasons = $client.data('/data/series/seasons')
  $assets = $client.data("/data/series/assets")
end

desc 'Generate the index page'
task :generate_index, [:destination] => :prepare_shared_data do
  page_generator = PageGenerator.new($content_generator)
  page_generator.generate('index.html.erb', 'index.html', seasons: $seasons, assets: $assets)
end

desc 'Generate the season pages'
task :generate_seasons, [:destination] => :prepare_shared_data do
  page_generator = PageGenerator.new($content_generator)
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

    page_generator.generate('season.html.erb', "#{season_id}/index.html", assigns)
  end
end

desc 'Generate charts for all seasons'
task :generate_charts, [:destination] => :prepare_shared_data do
  # 6 concurrent threads to the rescue
  thread_pool = ThreadPool.new(6)

  chart_data_generator = ChartDataGenerator.new($content_generator)
  event_fetcher = EventFetcher.new($client)
  result_fetcher = ResultFetcher.new($client)

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
