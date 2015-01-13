require 'net/http'
require 'rexml/document'
require 'fileutils'

unless ARGV.length == 1
  puts "Usage: ruby s3-bucket-downloader.rb <bucketname>\n"
  exit
end

def download_file(http, filepath) 
  if filepath.split('').last == '/'
    return
  end

  dir = File.dirname(filepath)

  unless File.directory?(dir)
    FileUtils.mkdir_p(dir)
  end

  resp = http.get("/" + filepath)

  open(filepath , "wb") { |file|
    file.write(resp.body)
  }
end

baseurl = ARGV[0] + ".s3.amazonaws.com"

# Retrieve XML index
xml_data = Net::HTTP.get_response(URI.parse("http://" + baseurl)).body
doc = REXML::Document.new(xml_data)

puts "downloading contents of " + baseurl

Net::HTTP.start(baseurl) do |http|
  doc.elements.each('ListBucketResult/Contents/Key') do |element|
    if File.exists?(element.text)
      puts "skipping " + element.text
    else
      puts "downloading " + element.text
      download_file(http, element.text)
    end
  end
end

puts "Done"


