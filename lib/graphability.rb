require 'nokogiri'
require 'hotwater'

require 'graphability/http/url'
require 'graphability/http/response'

require 'graphability/platform'
require 'graphability/document_type'
require 'graphability/author'
require 'graphability/document'
require 'graphability/document_builder'

require 'graphability/builder/helper'
require 'graphability/builder/default'
require 'graphability/builder/youtube'
require 'graphability/builder/dailymotion'
require 'graphability/builder/vine'
require 'graphability/builder/instagram'
require 'graphability/builder/twitpic'
require 'graphability/builder/tumblr'
require 'graphability/builder/facebook_photo'

module Graphability
  class << self
    def new(options = {})
      memento = options.delete(:memento) || begin
        require 'graphability/memento/null'
        Memento::Null.new
      end

      http_client = options.delete(:http_client) || begin
        require 'graphability/http/client/synchrony'
        HTTP::Client::Synchrony.new
      end

      DocumentBuilder.new(http_client, memento)
    end
  end
end