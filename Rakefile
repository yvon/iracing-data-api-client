require 'rake'

Dir["./src/*.rb"].each { |file| require file }
Thread.abort_on_exception = true

task :destination, [:destination] do |t, args|
  $destination = args.destination || 'out'
end

desc 'Fetch and cache data from iRacing'
task :fetch_data do
  client = Client.new
  client.authenticate(ENV.fetch('IRACING_EMAIL'), ENV.fetch('IRACING_PASSWORD'))

  thread_pool = ThreadPool.new(6)
  data_fetcher = DataFetcher.new(client)

  DataExplorer.new(data_fetcher, thread_pool).explore
end

desc 'Generate HTML pages and chart data'
task :generate_static_content, [:destination] => :destination do
  data_reader = DataReader.new
  static_content_writer = StaticContentWriter.new($destination)

  DataExplorer.new(data_reader).explore do |type, data|
    case type
    when :index
      static_content_writer.write_index_page(**data)
    when :season
      static_content_writer.write_season_page(**data)
    when :chart_data
      static_content_writer.write_chart_data(**data)
    end
  end
end

desc 'Copy the assets'
task :copy_assets, [:destination] => :destination do |t, args|
  FileUtils.cp_r('./assets/.', $destination)
end

desc 'Fetch data, generate static content and copy assets'
task :generate, [:destination] => [:fetch_data, :generate_static_content, :copy_assets]

task :default, [:destination] => [:generate]
