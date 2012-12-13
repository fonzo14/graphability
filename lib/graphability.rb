require 'nokogiri'
require 'postrank-uri'

require 'graphability/http/response'
require 'graphability/html_parser'
require 'graphability/facade'

module Graphability
  class << self
    def new(options = {})
      memento = options.delete(:memento)
      raise "You should set a memento" unless memento

      http_client = options.delete(:http_client)
      unless http_client
        require 'graphability/http/client/synchrony'
        http_client = HTTP::Client::Synchrony.new
      end

      Facade.new(http_client, HtmlParser.new, memento)
    end
  end
end