module Graphability
  module Builder
    class Vine
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        twitter = %w{title description image player}.inject({}) do |h, property|
          attribute = "twitter:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        doc = Document.new

        url = twitter['player'].gsub("/card","")

        doc.url   = HTTP::Url.new(url || url.url, :force => true)
        doc.title = to_text twitter['description']
        doc.text  = to_text ""
        doc.image = twitter['image']

        doc.type     = DocumentType::VINE
        doc.platform = Platform::VINE

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end