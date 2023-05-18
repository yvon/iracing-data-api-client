require 'fileutils'

class ContentGenerator
  def initialize(folder)
    @folder = folder
  end

  def generate(filename, content, mode: 'w')
    full_path = File.join(@folder, filename)

    FileUtils.mkdir_p(File.dirname(full_path))
    File.write(full_path, content, mode: mode)
  end
end
