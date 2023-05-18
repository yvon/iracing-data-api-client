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

  def copy(src)
    dest = File.join(@folder, File.basename(src))
    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.cp(src, dest)
  end
end
