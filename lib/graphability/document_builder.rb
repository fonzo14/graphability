module Graphability
  class DocumentBuilder
    attr_reader :http_client, :memento

    def initialize(http_client, memento)
      @http_client = http_client
      @memento     = memento

      @patterns = {
          /youtube\.com\/.*v=/          => Builder::Youtube.new,
          /instagram\.com\/p\//         => Builder::Instagram.new,
          /dailymotion\.com\/video\//   => Builder::Dailymotion.new,
          /vine\.co\/v\//               => Builder::Vine.new,
          /twitpic\.com\/[A-Za-z0-9]+$/ => Builder::Twitpic.new,
          /tumblr\.com\/post\//         => Builder::Tumblr.new,
          /facebook.com\/photo\.php/    => Builder::FacebookPhoto.new
      }.freeze

      @default_builder = Builder::Default.new(@memento)
    end

    def build(url)
      document = Document::EMPTY

      begin
        url = HTTP::Url.new(url)

        if url.valid?
          http_response = @http_client.get(url.url)

          if http_response.success?
            last_effective_url = HTTP::Url.new(http_response.url)

            if last_effective_url.embedded?
              http_response = @http_client.get(last_effective_url.url)
            end

            if http_response.success?
              last_effective_url = HTTP::Url.new(http_response.url)

              document = builder_for(last_effective_url).build(last_effective_url, http_response.body)
            end
          end
        end
      rescue Exception => e
        #p [e.message,*e.backtrace]
        log.error [e.message,*e.backtrace] 
      end

      document.to_h
    end

    private
    def builder_for(url)
      pattern = @patterns.keys.find { |r| url.url =~ r }
      pattern ? @patterns[pattern] : @default_builder
    end
  end
end