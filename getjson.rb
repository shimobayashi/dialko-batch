require 'json/pure'

def getJson(yearago)

  filename = yearago.strftime('%Y_%m.js');
  filename = File.dirname(__FILE__) + '/tweets/' + filename

  lines = []
  File::open(filename) do |f|
    while l = f.gets
      lines << l
    end
  end
  lines.shift

  json = lines.join();

  return JSON.parse(json)
end
