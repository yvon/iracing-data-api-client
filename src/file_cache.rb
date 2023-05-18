require 'json'
require 'fileutils'

class FileCache
  def initialize(folder, parser: JSON, extension: 'json')
    @folder = folder
    @parser = parser
    @extension = extension

    FileUtils.mkdir_p(folder)
  end

  def fetch(name, &block)
    filename = File.join(@folder, "#{name}.#{@extension}")

    if File.exist?(filename)
      @parser.parse(File.read(filename))
    else
      result = block.call
      File.write(filename, @parser.unparse(result))
      result
    end
  end
end
