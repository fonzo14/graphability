module Graphability
  class Facade
    attr_reader :http_client, :html_parser

    def initialize(http_client, html_parser)
      @http_client = http_client
      @html_parser = html_parser
    end

    def graph(url)
      graph    = {:url => url}

      begin
        response = http_client.get(url)
        if response.success?
          graph = html_parser.parse(response.url, response.body)
        end
      rescue Exception => e
        p [e.message,*e.backtrace]
      end

      graph
    end
  end
end