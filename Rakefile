require 'rake'

require './lib/iracing_stats'
require './lib/iracing_stats/data_explorer'

SEASONS = 'data/series/seasons'
ASSETS = 'data/series/assets'
CAR_CLASSES = 'data/carclass/get'
SEASON_RESULTS = 'data/results/season_results?season_id=%<season_id>d&race_week_num=%<race_week>d'

CHARTS_FOLDER_FORMAT = '_site/seasons/%<season_id>d/charts'
CSV_FILE_FORMAT = '_site/seasons/%<season_id>s/charts/%<car_class_id>d/%<session_type>s.csv'

PAGES_PREREQUISITES = FileList['templates/*', 'lib/**', '_site', SEASONS, ASSETS, CAR_CLASSES]

def parse_data(file)
  Rake::Task[file].invoke
  JSON.parse(File.read(file), symbolize_names: true)
end

def seasons
  parse_data(SEASONS)
end

directory '_site'

rule %r{^data/} do |t|
  IracingStats.app.fetch_and_store(t.name)
end

file '_site/index.html' => PAGES_PREREQUISITES do |t|
  puts t.name
  IracingStats.app.generate_index_page(t.name, seasons, parse_data(ASSETS))
end

file '_site/seasons' => PAGES_PREREQUISITES do |t|
  assets = parse_data(ASSETS)
  car_classes = parse_data(CAR_CLASSES)

  seasons.each do |season|
    html_file = "_site/seasons/#{season[:season_id]}/index.html"
    IracingStats.app.generate_season_page(html_file, season, assets, car_classes)
  end

  touch t.name
end

desc 'Remove cached files that are regularly updated'
task :remove_dynamic_data do
  files = Rake::FileList['data/series/seasons', 'data/results/season_results*'].existing
  FileUtils.rm files, force: true
  puts "#{files.size} files deleted"
end

multitask :async_charts

task :prepare_charts do
  seasons.each do |season|
    folder = CHARTS_FOLDER_FORMAT % season
    season_results_file = SEASON_RESULTS % season

    # Not re-generated unless the data has been updated
    file folder => season_results_file
    task async_charts: folder

    file folder do
      data = parse_data(season_results_file)
      result_paths = IracingStats::DataExplorer.select_result_endpoints(data)
      result_paths.each { |e| Rake::Task[e].invoke }

      IracingStats.app.generate_chart_content(CSV_FILE_FORMAT, result_paths)
      FileUtils.mkdir_p(folder) && touch(folder)
    end
  end
end

desc 'Generate charts data files'
task charts: [:prepare_charts, :async_charts]

desc 'Generate the index page'
task index: '_site/index.html'

desc 'Generate season pages'
task season_pages: '_site/seasons'

desc 'Generate all HTML content'
task pages: [:index, :season_pages]

desc 'Copy the assets'
task assets: :_site do
  cp Dir['assets/*'], '_site'
end

desc 'Generate the whole website'
task build: [:pages, :charts, :assets]
task default: :build

desc 'Fetch latest data and re-build the website'
task update: [:remove_dynamic_data, :build]

task :compile_css do
  sh 'tailwindcss -o assets/app.css --minify'
end

desc 'Build and compile the CSS'
task dev: [:compile_css, :build]

desc 'Delete data files older than 7 days'
task :clean do
  sh 'find data -type f -mtime +7 -delete'
end
