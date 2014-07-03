
module Graphability
  module Builder
    class Dailymotion
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
        doc.title = to_text og['title']
        doc.text  = to_text og['description']

        doc.type     = DocumentType::VIDEO
        doc.platform = Platform::DAILYMOTION

        author_url  = extract_meta(html, "video:director")
        author_name = author_url.split('/').last

        doc.author = Author.new(Platform::DAILYMOTION, author_name, author_url, "")

        doc
      end
    end
  end
end