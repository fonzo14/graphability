module Graphability
  module HTTP

    class Response
      attr_reader :url, :body, :code, :headers

      def initialize(url, body, code, headers={})
        @url, @body, @code, @headers = url.sub(':80',''), body, code.to_i, headers
      end

      def success?
        code > 0 && code < 400
      end

      def failure?
        !success?
      end

      def to_s
        [url, code, body].join(' : ')
      end
    end

  end
end