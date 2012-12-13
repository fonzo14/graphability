require "graphability"

g = Graphability.new

EM.synchrony do
  p g.graph('http://www.chron.com/news/world/article/Syria-state-media-Blast-near-Damascus-kills-16-4114032.php#src=fb')

  EM.stop
end