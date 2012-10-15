module Graphability
  class HtmlParser
    def parse(url, content)
      html = Nokogiri::HTML(content)

      newurl   = absolutify(find_url(url, html), root_url(url))
      newimage = find_image(html)

      {
        :url   => newurl,
        :image => newimage
      }
    end

    private
    def find_image(html)
      meta = html.at_css("meta[property='og:image']")
      return meta['content'] if meta

      meta = html.at_css("meta[property='twitter:image']")
      return meta['content'] if meta

      link = html.at_css("link[rel=image_src]")
      return link['href'] if link

      nil
    end

    def find_url(url, html)
      meta = html.at_css("meta[property='og:url']")
      return meta['content'] if meta

      meta = html.at_css("meta[property='twitter:url']")
      return meta['content'] if meta

      link = html.at_css("link[rel=canonical]")
      return link['href'] if link

      PostRank::URI.clean(url)
    end

    def absolutify(url, root_url)
      if url =~ /^\w*\:/i
        url
      else
        root_url + ("/" + url).squeeze("/")
      end
    end

    def root_url(url)
      uri = Addressable::URI.parse(url)
      (uri.scheme || 'http') + "://" + uri.host
    end
  end
end