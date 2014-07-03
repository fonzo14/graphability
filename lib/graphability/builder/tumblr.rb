module Graphability
  module Builder
    class Tumblr
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        twitter = %w{card url title description image}.inject({}) do |h, property|
          attribute = "twitter:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        doc       = Document.new
        doc.url   = HTTP::Url.new(twitter['url'] || url.url, :force => true)
        doc.title = to_text twitter['description']
        doc.text  = ""
        doc.image = twitter['image']

        twitter_card = twitter["card"].to_s.strip.downcase

        doc.type = case twitter_card
                     when "photo" then DocumentType::IMAGE
                     when "summary", "summary_large_image" then DocumentType::ARTICLE
                     else DocumentType::ARTICLE
                   end

        doc.platform = Platform::TUMBLR

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end