module Graphability
  class Facade
    attr_reader :http_client, :html_parser

    def initialize(http_client, html_parser)
      @http_client = http_client
      @html_parser = html_parser
    end

    def graph_url(url)
      graph    = nil

      response = http_client.get(url)
      if response.success?
        graph = html_parser.parse(response.url, response.body)
      end

      graph
    end
  end
end