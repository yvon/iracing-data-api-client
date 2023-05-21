require 'erb'

module IracingStats
  class PageGenerator
    LAYOUT_FILE = './templates/layout.html.erb'.freeze

    def initialize
      @layout = File.read(LAYOUT_FILE)
    end

    def index_page(seasons, assets)
      assigns = {
        seasons: seasons,
        assets: assets,
      }

      content('index.html.erb', assigns)
    end

    def season_page(season, assets, car_classes)
      season_id = season[:season_id]

      assigns = {
        season: season,
        week: season[:schedules].find { |e| e[:race_week_num] == season[:race_week] },
        car_classes: season[:car_class_ids].map { |id| car_classes.find { |e| e[:car_class_id] == id } },
        logo: assets[season[:series_id].to_s.to_sym][:logo],
        page_title: season[:season_name]
      }

      content('season.html.erb', assigns)
    end

    private

    def content(template_file, assigns = {})
      template = File.read("./templates/#{template_file}")
      content = ERB.new(template).result(binding)
      ERB.new(@layout).result(binding)
    end
  end
end
