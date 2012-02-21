#!/bin/ruby

puts "Loading old resources"

formats = {}

File.open("old_res.h", 'r').readlines.each do |line|
  if /format='(\d+)'/ =~ line
    format = Regexp.last_match[1]
    /NSS\("([^"]+)"\)/ =~ line
    id = Regexp.last_match[1]
    formats[id] = format
  end
end

lines = []

File.open("res.h", 'r').readlines.each do |line|
  if /format='(\d+)'/ =~ line
    format = Regexp.last_match[1]
    /NSS\("([^"]+)"\)/ =~ line
    id = Regexp.last_match[1]
    prev_format = formats[id]
    if prev_format && prev_format != '0' && format == '0'
      puts "Patching #{id} from #{format} to #{prev_format}"

      line.gsub!(/format='(\d+)'/, "format='#{prev_format}'")
    end
  end

  lines << line
end

File.open("res_out.h", 'w') do |f|
  lines.each do |line|
    f.print(line)
  end
end
