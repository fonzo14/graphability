module Graphability
  module Builder
    class Twitpic
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        twitter = %w{url title description image}.inject({}) do |h, property|
          attribute = "twitter:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        og = %w{url title description image}.inject({}) do |h, property|
          attribute = "og:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        doc       = Document.new
        doc.url   = HTTP::Url.new(twitter['url'] || og['url'] || url.url, :force => true)
        doc.title = to_text og['title']
        doc.text  = ""
        doc.image = twitter['image']

        doc.type     = DocumentType::IMAGE
        doc.platform = Platform::TWITTER

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end