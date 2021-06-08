#!/usr/bin/env ruby




module C2P
  class Archive
    attr_accessor :path
    attr_accessor :name
    attr_accessor :folder
    attr_accessor :basename
    attr_accessor :extension
    attr_accessor :destination


    @allowed_extensions


    def initialize(file_path)
      @allowed_extensions = [ ".cbz", ".cbr" ]

      if File.exist?(file_path)
        if @allowed_extensions.include?(File.extname(file_path))
          self.path        = File.expand_path(file_path)
          self.name        = File.basename(self.path)
          self.folder      = File.dirname(self.path)
          self.basename    = File.basename(self.name, ".*")
          self.extension   = File.extname(file_path)
          self.destination = File.expand_path("#{self.folder}/#{self.basename}")
        else
          STDERR.puts "That archive format is not supported."
          abort
        end
      else
        STDERR.puts "The file does not exists."
        abort
      end
    end
  end
end
