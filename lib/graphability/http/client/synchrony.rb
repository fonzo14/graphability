require "em-synchrony"
require "em-synchrony/em-http"

module Graphability
  module HTTP
    module Client

      class Synchrony
        def get(url)
          http = ::EventMachine::HttpRequest.new(url).get({:redirects => 5})
          last_url = http.last_effective_url ? http.last_effective_url.to_s : url
          HTTP::Response.new last_url, http.response, http.response_header.status, http.response_header
        end
      end

    end
  end
end