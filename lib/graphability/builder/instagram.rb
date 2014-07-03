module Graphability
  module Builder
    class Instagram
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        og = %w{url title description image}.inject({}) do |h, property|
          attribute = "og:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        doc       = Document.new
        doc.url   = HTTP::Url.new(og['url'] || url.url, :force => true)
        doc.image = og['image']

        doc.type     = DocumentType::IMAGE
        doc.platform = Platform::INSTAGRAM

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end