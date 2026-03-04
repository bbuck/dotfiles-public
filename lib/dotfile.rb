require "erb"
require "fileutils"

class Dotfile
  attr_reader :path

  class << self
    def exists?(path)
      File.exist?(path) || File.symlink?(path) || File.directory?(path)
    end

    def remove(path)
      FileUtils.remove_entry_secure(path)
    end
  end

  def initialize(path)
    @path = path
  end

  def exists?
    self.class.exists?(path)
  end

  def identical?(with:)
    File.identical?(with, path)
  end

  def template?
    path.extname == ".erb"
  end

  def copy?
    # NOTE: You can only copy ERB templates
    path.extname == ".copy" || template?
  end

  def link?
    path.extname == ".symlink"
  end

  def copy(to:)
    FileUtils.cp(path, to)
  end

  def write(to:)
    File.open(to, 'w') do |f|
      f.write(rendered)
    end
  end

  def symlink(as:)
    FileUtils.ln_s(path, as)
  end

  def rendered
    context = ERBContext.new({
      os: os_details,
      Config: Config,
    })
    ERB.new(File.read(path)).result(context.get_binding)
  end

  def destination_name
    @destination_name ||= path.basename.sub('.erb', '').sub('.copy', '').sub('.symlink', '')
  end

  def execute(destination)
    target = destination.join(destination_name)
    if template?
      write(to: target)
      :wrote
    elsif copy?
      copy(to: target)
      :copied
    elsif link?
      symlink(as: target)
      :linked
    else
      raise StandardError, "unknown dotifle #{path}"
    end
  end
end
