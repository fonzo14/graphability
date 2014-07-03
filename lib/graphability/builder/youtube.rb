module Graphability
  module Builder
    class Youtube
      include Builder::Helper

      def build(url, body)
        html = parse(url.url, body)

        twitter = %w{url title description image}.inject({}) do |h, property|
          attribute = "twitter:#{property}"
          h[property] = extract_meta(html, attribute)
          h
        end

        doc       = Document.new
        doc.url   = HTTP::Url.new(twitter['url'] || url.url, :force => true)
        doc.title = to_text twitter['title']
        doc.text  = to_text twitter['description']
        doc.image = twitter['image']

        doc.type     = DocumentType::VIDEO
        doc.platform = Platform::YOUTUBE

        #<span itemprop="author" itemscope itemtype="http://schema.org/Person">
        #<link itemprop="url" href="http://www.youtube.com/user/maya8184">
        #</span>

        doc.author = Author::UNKNOWN

        doc
      end
    end
  end
end