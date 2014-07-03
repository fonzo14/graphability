require "graphability"

g = Graphability.new

EM.synchrony do
  p Graphability::DocumentType['article']

  p Graphability::Platform['toto']
  p Graphability::Platform['twitter']

  p g.build('http://www.ouest-france.fr/ofdernmin_-Coree-du-Nord.-Le-mysterieux-smartphone-de-Kim-Jong-Un_6346-2160823-fils-tous_filDMA.Htm')

  #p g.build "http://rss.feedsportal.com/c/32389/f/463430/s/296d4474/l/0L0Slinternaute0N0Cactualite0Csociete0Efrance0Cces0Etueurs0Equi0Eont0Eridiculise0Ela0Epolice0C/story01.htm"

  #p g.build("https://t.co/LOkBhElMUD")

  #p g.build("http://t.co/xRyweNsYYW")

  #p g.build("https://t.co/YU7GfNcS8w")

  #p g.build("http://t.co/EUEmB7fFuB")

  #p g.build("http://t.co/CLAZB7tT9Q")

  EM.stop
end