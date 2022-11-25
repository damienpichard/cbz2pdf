module C2P
  def self.executable?(cmd)
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      (ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']).each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if   File.executable?(exe) \
                    and !File.directory?(exe)
      end
    end
    nil
  end
end
