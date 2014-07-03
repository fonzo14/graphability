module Graphability
  module Builder
    class Default
      include Builder::Helper

      def initialize(memento)
        @memento = memento
      end

      def build(url, body)
        html = parse(url.url, body)

        title = html.at_css("head title").text rescue nil

        title = @memento.memorize(url.domain, "head:title", title)

        canonical = HTTP::Url.new(extract_link(html, "canonical"))

        image = extract_link(html, "image_src")

        meta = %w{description}.inject({}) do |h, property|
          h[property] = extract_meta(html, property)
          h[property] = @memento.memorize(url.domain, "meta:#{property}", h[property])
          h
        end

        og = %w{url title description image}.inject({}) do |h, property|
          attribute = "og:#{property}"
          h[property] = extract_meta(html, attribute)
          if property != 'url'
            h[property] = @memento.memorize(url.domain, attribute, h[property])
          end
          h
        end

        og['url'] = HTTP::Url.new(og['url'])

        twitter = %w{url title description image}.inject({}) do |h, property|
          attribute = "twitter:#{property}"
          h[property] = extract_meta(html, attribute)
          if property != 'url'
            h[property] = @memento.memorize(url.domain, attribute, h[property])
          end
          h
        end

        twitter['url'] = HTTP::Url.new(twitter['url'])

        meta.merge!({
                        'url' => canonical,
                        'title' => title,
                        'image' => image
                    })

        doc = Document.new
        doc.url = find_url(url, meta, og, twitter)
        doc.title = find_title(meta, og, twitter)
        doc.text = find_text(doc.title, meta, og, twitter)

        # si pas de titre mais un texte alors on inverse
        if doc.title.size.zero? && doc.text.size > 0
          doc.title = doc.text.dup
          doc.text = ""
        end

        doc.image = find_image(meta, og, twitter)

        doc.type = DocumentType::ARTICLE
        doc.platform = Platform::UNKNOWN

        #<link rel="shortcut icon" href="//s1.lemde.fr/medias/web/1.2.642/ico/favicon.ico">
        favicon = extract_link(html, "shortcut icon") || extract_link(html, "SHORTCUT ICON")
        if favicon.to_s.start_with?("//")
          favicon = "http:#{favicon}"
        elsif favicon.to_s.start_with?("/")
          favicon = doc.url.domain_url + favicon
        end

        doc.author = Author.new(Platform::UNKNOWN, doc.url.domain, doc.url.domain_url, favicon.to_s)

        doc
      end

      private
      def find_url(url, meta, og, twitter)
        candidates = [meta['url'], url, og['url'], twitter['url']].compact.select { |url| url.valid? }
        candidates.max_by { |url| url.handicap }
      end

      def find_title(meta, og, twitter)
        to_text([og['title'], twitter['title'], meta['title']].compact.reject { |text| text.to_s.empty? }.first)
      end

      def find_text(title, meta, og, twitter)
        [og['description'], twitter['description'], meta['description']].compact.reject { |text| text.to_s.empty? || text.to_s.size < 10 }.map do |text|
          to_text(text)
        end.reject { |text| Hotwater.jaro_winkler_distance(title, text) > 0.95 }.first
      end

      def find_image(meta, og, twitter)
        [og['image'], twitter['image'], meta['image']].compact.select { |img| img.to_s.start_with?('http') }.reject { |u| u.include?('logo') }.first
      end
    end
  end
end