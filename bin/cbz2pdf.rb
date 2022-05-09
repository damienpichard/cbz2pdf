#!/usr/bin/env ruby




require 'optparse'
require 'fileutils'

require 'combine_pdf'
require 'ffi-libarchive'
require 'tty-progressbar'

require_relative "archive.rb"




class Cbz2Pdf
  attr_accessor :keep
  attr_accessor :manga
  attr_accessor :verbose

  attr_accessor :archive

  attr_accessor :total_files


  @image_extension_allowed


  def initialize
    self.keep        = false
    self.manga       = false
    self.verbose     = false
    self.total_files = 0

    @image_allowed_extensions = [ ".jpg", ".jpeg", ".png" ]
  end


  def parse
    OptionParser.new do |parser|
      parser.on("-f", "--file FILE_PATH", "File to convert") do |file_path|
        self.archive = C2P::Archive.new(file_path)
      end

      parser.on("-m", "--manga", "Rearange pages in correct order for mangas (works for double-page views)") do |manga|
        self.manga = manga
      end

      parser.on("-k", "--keep", "Keep extracted files and original archive") do |keep|
        self.keep = keep
      end

      parser.on("-v", "--verbose", "Make operations more talkative") do |verbose|
        self.verbose = verbose
      end

      parser.on("-h", "--help", "Prints this help") do
        puts parser
        exit
      end
    end.parse!
  end


  def exclude?(file)
    if File.directory?(file)
      return true
    elsif file.match?(/^\..*/) # dotfiles
      return true
    else
      return false
    end
  end


  def count()
    Dir.foreach(self.archive.destination) do |file|
      next if self.exclude?(file)

      self.total_files += 1
    end
  end


  def extract()
    reader   = Archive::Reader.open_filename(self.archive.path)
    progress = TTY::ProgressBar.new("extracting [:bar]", total: nil)

    if self.archive.extractable?
      FileUtils.mkdir_p(self.archive.destination)

      reader.each_entry do |entry|
        progress.advance if self.verbose

        reader.extract(entry, Archive::EXTRACT_PERM, destination: self.archive.destination)
      end

      reader.close
    end

    progress.finish if self.verbose
  end


  def fix_folder()
    if Dir.children(self.archive.destination).count == 1
      extracted_subdir  = Dir.children(self.archive.destination).first
      wrong_destination = "#{self.archive.destination}/#{extracted_subdir}"

      Dir.new(wrong_destination).each_child do |file|
        FileUtils.mv("#{wrong_destination}/#{file}", "#{self.archive.destination}/#{file}")
      end

      FileUtils.remove_dir(wrong_destination)
    end
  end


  def rearange()
    if self.manga
      progress     = TTY::ProgressBar.new("rearanging [:bar :percent]", total: self.total_files)
      current_file = 1

      Dir.foreach(self.archive.destination).sort.each do |file|
        next if self.exclude?(file)

        old_path = File.expand_path("#{self.archive.destination}/#{file}")
        filename = ""

        progress.advance if self.verbose

        if current_file.even?
          filename = "%05d#{File.extname(file)}" % [current_file + 1]
        elsif current_file == 1
            filename = "%05d#{File.extname(file)}" % [current_file]
        else # current_file.odd?
            filename = "%05d#{File.extname(file)}" % [current_file - 1]
        end

        new_path      = File.expand_path("#{self.archive.destination}/#{filename}")
        current_file += 1

        FileUtils.mv(old_path, new_path)
      end
    end
  end


  def convert()
    progress = TTY::ProgressBar.new("converting [:bar :percent]", total: self.total_files)

    Dir.foreach(self.archive.destination).sort.each do |file|
      next if self.exclude?(file)

      if @image_allowed_extensions.include?(File.extname(file))
        path = File.expand_path("#{self.archive.destination}/#{file}")

        progress.advance if self.verbose

        if executable('img2pdf')
          %x( img2pdf "#{path}" -o "#{path}.pdf" )
        else
          STDERR.puts "cbz2pdf: executable 'img2pdf' not found..."
        end
      end
    end
  end


  def merge()
    progress = TTY::ProgressBar.new("merging    [:bar :percent]", total: self.total_files+1)
    pdf = CombinePDF.new

    Dir.foreach(self.archive.destination).sort.each do |file|
      next if     self.exclude?(file)
      next unless File.extname(file) == ".pdf"

      progress.advance if self.verbose

      path = File.expand_path("#{self.archive.destination}/#{file}")
      pdf << CombinePDF.load(path)
    end

      pdf.save("#{self.archive.basename}.pdf")

      progress.finish if self.verbose
  end


  def delete()
    unless self.keep
      File.delete(self.archive.path)
      FileUtils.remove_dir(self.archive.destination)
    end
  end
end




converter = Cbz2Pdf.new
converter.parse
converter.extract
converter.fix_folder
converter.count
converter.rearange
converter.convert
converter.merge
converter.delete
