require "graphability"

g = Graphability.new

EM.synchrony do
  p g.graph('http://bigbrowser.blog.lemonde.fr/2012/10/08/baptiste-giabiconi-le-top-exclu-du-top/?utm_source=45')

  EM.stop
end