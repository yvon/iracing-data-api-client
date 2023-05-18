#!/usr/bin/env ruby

Dir["./src/*.rb"].each { |file| require file }

Thread.abort_on_exception = true

email = ENV['IRACING_EMAIL']
password = ENV['IRACING_PASSWORD']

client = Client.new
client.authenticate(email, password)

event_fetcher = EventFetcher.new(client)
result_fetcher = ResultFetcher.new(client)

content_generator = ContentGenerator.new
page_generator = PageGenerator.new(content_generator)
chart_data_generator = ChartDataGenerator.new(content_generator)

# Shared data
seasons = client.data('/data/series/seasons')
car_classes = client.data('/data/carclass/get')
assets = client.data("/data/series/assets")

# Generate charts first, this is the most likely to fail

##########
# Charts #
##########

# 6 concurrent threads to the rescue
thread_pool = ThreadPool.new(6)

seasons.each do |season|
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

###########
# Seasons #
###########

seasons.each do |season|
  season_id = season['season_id']

  assigns = {
    season: season,
    week: season['schedules'].find { |e| e['race_week_num'] == season['race_week'] },
    car_classes: season['car_class_ids'].map { |id| car_classes.find { |e| e['car_class_id'] == id } },
    logo: assets[season['series_id'].to_s]['logo'],
    page_title: season['season_name']
  }

  page_generator.generate('season.html.erb', "#{season_id}/index.html", assigns)
end

#########
# Index #
#########

page_generator.generate('index.html.erb', 'index.html', seasons: seasons, assets: assets)
