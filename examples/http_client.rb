require "graphability"

class MementoMock
  def verify(domain, attribute, value)
     value
  end
end

g = Graphability.new :memento => MementoMock.new

EM.synchrony do
  p g.graph('http://www.ouest-france.fr/ofdernmin_-Coree-du-Nord.-Le-mysterieux-smartphone-de-Kim-Jong-Un_6346-2160823-fils-tous_filDMA.Htm')

  EM.stop
end