module Graphability
  class Facade
    attr_reader :http_client, :html_parser

    def initialize(http_client, html_parser)
      @http_client = http_client
      @html_parser = html_parser
    end

    def graph_url(url)
      response = http_client.get(url)
      if response.success?
        p html_parser.parse(response.url, response.body)
      end
    end

    def graph_content(url, content)
      html_parser.parse(url, content)
    end
  end
end