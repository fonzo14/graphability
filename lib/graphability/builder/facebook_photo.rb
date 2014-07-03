module Graphability
  module Builder
    class FacebookPhoto
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        meta = %w{description}.inject({}) do |h, property|
          h[property] = extract_meta(html, property)
          h
        end

        url = url.url.match(/(https?:\/\/www\.facebook\.com\/photo\.php\?fbid=[0-9]+).*/)[1]

        image = html.at_css("img[id=fbPhotoImage]")['src'].to_s

        doc       = Document.new
        doc.url   = HTTP::Url.new(url, :force => true)
        doc.title = to_text meta['description']
        doc.text  = ""
        doc.image = image

        doc.type     = DocumentType::IMAGE
        doc.platform = Platform::FACEBOOK

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end