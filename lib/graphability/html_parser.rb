module Graphability
  class HtmlParser
    def parse(url, content)
      html = Nokogiri::HTML(content)

      url   = find_url(url, html)
      image = find_image(html)

      {
        :url   => url,
        :image => image
      }
    end

    private
    def find_image(html)
      meta = html.at_css("meta[property='og:image']")
      return meta['content'] if meta

      meta = html.at_css("meta[property='twitter:image']")
      return meta['content'] if meta

      nil
    end

    def find_url(url, html)
      link = html.at_css("link[rel=canonical]")
      return link['href'] if link

      meta = html.at_css("meta[property='og:url']")
      return meta['content'] if meta

      meta = html.at_css("meta[property='twitter:url']")
      return meta['content'] if meta

      PostRank::URI.clean(url)
    end
  end
end