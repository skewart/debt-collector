require 'fileutils'

class Collector
  
  DEBT_DIRECTORY_NAME = '.debt'

  def initialize(options)
    @root = options[:root] || '.'

    @is_collecting = false
  end

  def collect
    create_debt_directory unless File.directory? debt_directory_path
    files.each do |file_name|
      process_file file_name
    end
  end

  private

  attr_reader :root
  attr_accessor :is_collecting

  def files
    Dir.glob "#{root}/*.rb"
  end

  def tmp_name
    (0..10).to_a.map { ('a'..'z').to_a.sample }.join
  end

  def process_file(file_name)
    get_temp_files do |real_file, debt_file|
      debt_line_count = 0
      File.readlines(file_name).each do |line|
        debt_file.write line
        if debt? line
          debt_line_count += 1  
        else
          real_file.write line
        end
      end

      IO.copy_stream real_file, file_name
      stash(debt_file, file_name) if debt_line_count > 0
    end
  end

  def debt?(line)
    if cash_line? line
      toggle_collecting
      true
    else
      collecting?
    end
  end

  def cash_line?(line)
    line =~ /^#$/
  end

  def collecting?
    is_collecting
  end

  def toggle_collecting
    is_collecting = !is_collecting
  end

  def debt_directory_path
    @debt_directory_path ||= File.join(root, DEBT_DIRECTORY_NAME)
  end

  def create_debt_directory
    FileUtils.mkdir_p debt_directory_path
  end

  def stash(debt_file, file_name)
    file_parts = file_name.split File::SEPARATOR
    root_parts = root.split File::SEPARATOR

    debt_path_parts = root_parts + (file_parts - root_parts)
    FileUtils.mkdir_p File.join(debt_path_parts[0..-2])

    debt_path = File.join debt_path_parts
    IO.copy_stream debt_file, debt_path
  end

  def get_temp_files
    real_file = Tempfile.new tmp_name
    debt_file = Tempfile.new tmp_name

    yield real_file, debt_file
  ensure
    real_file.close
    real_file.unlink
    debt_file.close
    debt_file.unlink
  end
end
