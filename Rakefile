require 'rake'
require './lib/iracing_stats'

SEASONS = 'data/series/seasons'
ASSETS = 'data/series/assets'
CAR_CLASSES = 'data/carclass/get'
SEASON_RESULTS = 'data/results/season_results?season_id=%d&race_week_num=%d'
RESULT = 'data/results/get?subsession_id=%d'

TEMPLATES = FileList['templates/*']

directory 'out'

rule %r{^data/} do |t|
  IracingStats.app.fetch_and_store(t.name)
end

rule %r{^out/} => :out do |t|
  puts "Generating #{t.name}"
end

rule %r{^out/seasons/.+/index\.html$} => [:out, SEASONS, ASSETS, CAR_CLASSES, *TEMPLATES] do |t|
  puts "Generating #{t.name}"
end

file 'out/index.html' => [:out, SEASONS, ASSETS, *TEMPLATES] do |t|
  puts "Generating #{t.name}"
  IracingStats.app.generate_index_page(t.name)
end

task default: 'out/index.html'

task assets: :out do
  cp Dir['assets/*'], 'out'
end

task default: :assets

multitask :season_results
multitask results: :season_results
multitask chart_data: :results

task default: SEASONS do
  IracingStats.app.seasons.each do |season|
    season_id = season['season_id']
    race_week = season['race_week']
    car_class_ids = season['car_class_ids']

    csv_folder = "out/seasons/#{season_id}/charts"

    # Mark CSV folder as dependencies so it will be generated
    Rake::Task[:chart_data].enhance([csv_folder])

    # Generate the season page
    Rake::Task["out/seasons/#{season_id}/index.html"]
      .enhance { |t| IracingStats.app.generate_season_page(t.name, season) }
      .invoke

    # The block is executed after the season results are downloaded.
    Rake::Task[:season_results].enhance([SEASON_RESULTS % [season_id, race_week]]) do
      season_results = IracingStats.app.season_results(season_id, race_week)

      # We don't want to process practice sessions
      results_list = season_results['results_list'].filter do |event|
        event['event_type_name'] == 'Race' && event['official_session'] == true
      end

      # Identify the result files
      result_files = results_list.map { |event| RESULT % event['subsession_id'] }

      # Mark the result files as dependencies so they will be downloaded
      Rake::Task[:results].enhance(result_files)

      # Mark the result files are required to generate the CSV files
      # It also implies that the CSV fill will be regenerated if the result files change
      Rake::Task[csv_folder].enhance(result_files) do
        IracingStats.app.generate_chart_content(csv_folder, result_files)
        FileUtils.touch(csv_folder)
      end
    end
  end

  Rake::Task[:season_results].invoke
  Rake::Task[:results].invoke
  Rake::Task[:chart_data].invoke
end

