# Пробуем упростить работу по конвертированию файлов...

$cur_class = ""
$context = :none

def conv_declar(l, static)
  l = l[1..-1] #Убираем +-

  l = l.strip
  l = l[0..-2] if l.end_with?(";")

  mp = l.split(":")
  method = mp.slice!(0)
  params = ""

  m = /\((.*)\) *(.*)/.match(method.strip)
  type = m[1]
  method = m[2]

  mp.each do |x|
    mx = /(.*) +(\w+)/.match(x)
    pp = nil
    if mx.nil?
      pp = x
    else
      pp = mx[1]
      method += mx[2]
    end

    mx = /\((.*)\)(.*)/.match(pp.strip)
    params += ", " unless params == ""
    params += mx[1] + " " + mx[2]
  end

  type = "IID" if type == "id"

  if $context == :impl
    return "#{type} #{$cur_class}::#{method}(#{params}) // #{static ? 'static' : 'normal'}"
  elsif $context == :proto || $context == :iface
    r = "#{type} #{method}(#{params})"
    r = "static #{r}" if static
    r = "virtual #{r}" unless static
    r += ";"
    return r
  else
    raise "WRONG CONTEXT"
  end
end

def conv_call(l)
  m = /\[([^ ]+) +(.*)\]/.match(l)
#  puts "Full: #{l}"
#  puts "Obj: #{m[1]}"
#  puts "Params: #{m[2]}"

  return nil if m.nil?

  mp = m[2].split(':')
  method = mp.slice!(0)
  params = ""
  i = 1
  mp.each do |x|
    mx = /(.*) +(\w+)/.match(x) unless i == mp.size
    mx = nil if i == mp.size
    if mx.nil?
      params += ", " unless params == ""
      params += x
    else
      params += ", " unless params == ""
      params += mx[1]
      method += mx[2]
    end
    i = i + 1
  end
  #mp = /(.+:[^:]+)*/.match(m[2])
  #puts "#{method}(#{params})"

  obj = m[1]

  if obj[0] >= 'A'[0] and obj[0] <= 'Z'[0]
    return "#{obj}::#{method}(#{params})"
  else
    return "#{obj}->#{method}(#{params})"
  end
end

def conv_line(l)
  line_regex = /([^\w0-9])(\[[^\[\]]*\])/

  sl = l.strip

  if $context == :proto || $context == :iface
    return "" if sl == "{" || sl == '}'
  end

  m = nil
  while (!(m = line_regex.match(l)).nil?)
    cc = conv_call(m[2])
    break if cc.nil?
    l = l.sub!(line_regex, "\\1#{cc}" )
  end

  if l.start_with?("+")
    l = conv_declar(l, true)
  elsif l.start_with?("-")
    l = conv_declar(l, false)
  end

  if l.start_with?("@implementation")
    m = /@implementation (.*)/.match(l)
    $cur_class = m[1].strip
    $context = :impl
  end

  if l.start_with?("@end")
    l = "};" if $context == :proto || $context == :iface
    l = "" if $context == :impl

    $cur_class = ""
    $context = :none
  end

  if l.start_with?("@interface")
    m = /@interface +(\w+)/.match(l)
    name = m[1]
    r = "class #{name}"

    base_class = ""
    protocols = []

    m = /:(.*)<(.*)>/.match(l)
    if m.nil?
      m = /:(.*)/.match(l)
      base_class = m[1].strip unless m.nil?
    else
      base_class = m[1].strip
      protocols = m[2].split(",").map { |p| p.strip }
    end

    protocols = [ base_class ] + protocols if base_class != ""
    protocols.map! { |p| "public #{p}" }

    r += " : #{protocols * ", "}" unless protocols.size == 0

    r += "\n{\npublic:\n    NSOBJ(#{name});\n"
    l = r
    $context = :iface
  end

  if l.start_with?("@protocol")
    m = /@protocol (.*)/.match(l)
    name = m[1]
    r = "class #{name}\n{\n"
    l = r
    $context = :proto
  end

  l = "//#{l}" if l.start_with?("@protected") || l.start_with?("@public") || l.start_with?("@private") || l.start_with?("@optional")

  l
end

file_name = ARGV[0]

puts "Converting #{file_name}"

File.open(file_name, "r").readlines.each do |l|
  begin
    puts conv_line(l)
  rescue Exception => err
    puts "Error on converting: #{l}"
    raise err
  end
end
