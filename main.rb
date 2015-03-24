require_relative 'lib/xslt_processor'
require 'fileutils'
require 'pathname'

output_dir = ENV['XYLEME_OUTPUT_DIR'] || 'output'
FileUtils.rm_rf(output_dir) if Dir.exist?(output_dir)

ARGV.each do |a|
  FileUtils.mkdir_p("#{output_dir}/#{a}")
  files = Dir.glob("#{a}/**/*")
  xyleme_files = files.select {|f| File.file?(f) && f.split('.').last == 'xml'}
  other_files = files.select {|f| File.file?(f) && f.split('.').last != 'xml' }

  files = xyleme_files.inject({}) do |accum, filepath|
    accum.merge({filepath => File.read(filepath)})
  end

  xsl_stylesheet = File.read('xyleme_to_html.xsl')
  processor = XsltProcessor.new(xsl_stylesheet)
  output = processor.call(files)

  output.each do |filepath, file_content|
    File.open("#{output_dir}/#{filepath}", 'w+') { |file| file.write(file_content) }
  end

  other_files.each do |file|
    dest_path = Pathname("#{output_dir}/#{file}")
    FileUtils.mkpath(File.dirname(dest_path))
    FileUtils.copy(file, dest_path)
  end
end
