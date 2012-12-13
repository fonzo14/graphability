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
      fb_url, twitter_url, canonical_url = nil, nil, nil

      meta   = html.at_css("meta[property='og:url']")
      fb_url = meta['content'] if meta

      meta        = html.at_css("meta[property='twitter:url']")
      twitter_url = meta['content'] if meta

      link = html.at_css("link[rel=canonical]")
      canonical_url = link['href'] if link

      candidates = [fb_url, twitter_url, canonical_url].compact

      # Les urls fb / twitter peuvent avoir des paramètres de tracking. Prendre celle qui n'en a pas si possible
      if candidates.size > 0
        best_candidate_url = candidates.map do |candidate_url|
          score = 0
          score +=1 if candidate_url.start_with?('http')
          score +=1 unless candidate_url.include?('?')
          score +=1 unless candidate_url.include?('#')
          [candidate_url, score]
        end.sort { |u1,u2| u2[1] <=> u1[1] }.map { |u| u[0] }.first
        return PostRank::URI.clean(best_candidate_url)
      else
        return PostRank::URI.clean(url)
      end
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