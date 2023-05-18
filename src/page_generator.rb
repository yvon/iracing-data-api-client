require 'erb'

class PageGenerator
  LAYOUT_FILE = './templates/layout.html.erb'.freeze

  def initialize(content_generator)
    @content_generator = content_generator
    @layout = File.read(LAYOUT_FILE)
  end

  def generate(template_file, filename, assigns = {})
    template = File.read("./templates/#{template_file}")
    content = ERB.new(template).result(binding)
    page = ERB.new(@layout).result(binding)

    @content_generator.generate(filename, page)
  end
end
