require "graphability"

class MementoMock
  def verify(domain, attribute, value)
     value
  end
end

g = Graphability.new :memento => MementoMock.new

EM.synchrony do
  p g.graph('http://www.ouest-france.fr/ofdernmin_-Coree-du-Nord.-Le-mysterieux-smartphone-de-Kim-Jong-Un_6346-2160823-fils-tous_filDMA.Htm')

  p g.graph "http://rss.feedsportal.com/c/32389/f/463430/s/296d4474/l/0L0Slinternaute0N0Cactualite0Csociete0Efrance0Cces0Etueurs0Equi0Eont0Eridiculise0Ela0Epolice0C/story01.htm"
  EM.stop
end