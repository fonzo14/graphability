module Graphability
  class HtmlParser
    def parse(url, content, memento)
      html     = Nokogiri::HTML(content)

      newurl    = absolutify(find_url(url, html), root_url(url))
      newdomain = domain(newurl)

      newimage = find_image(html, newdomain, memento)
      newtitle = find_title(html, newdomain, memento)
      newdesc  = find_description(html, newdomain, newtitle, memento)
      newpub   = find_published(html)

      {
        :url          => newurl,
        :image        => newimage,
        :title        => newtitle,
        :description  => newdesc,
        :published_at => newpub
      }
    end

    private
    def find_published(html)
      published_at, og_pub = nil, nil

      meta = html.at_css("meta[property='article:published_time']")
      if meta
        og_pub = Time.parse(meta['content']).to_i
      end

      candidates = [og_pub].compact

      published_at = candidates.first

      published_at
    end

    def find_title(html, domain, memento)
      title, fb_title, html_title = nil, nil, nil

      meta = html.at_css("meta[property='og:title']")
      if meta
        fb_title = memento.verify(domain, "og:title", meta['content'])
      end

      title_tag = html.at_css("head title")
      if title_tag
        html_title = memento.verify(domain, "head:title", title_tag.text )
      end

      candidates = [fb_title, html_title].compact

      if candidates.size > 0
        title = candidates.first
      end

      textify title
    end

    def find_description(html, domain, title, memento)
      description, fb_description, twitter_description, meta_description = nil, nil, nil, nil

      meta = html.at_css("meta[property='og:description']")
      if meta
        if meta['content'] != title
          fb_description = memento.verify(domain, "og:description", meta['content'])
        end
      end

      meta = html.at_css("meta[property='twitter:description']")
      if meta
        if meta['content'] != title
          twitter_description = memento.verify(domain, "twitter:description", meta['content'])
        end
      end

      meta = html.at_css("meta[name='description']") || html.at_css("meta[name='Description']")
      if meta
        if meta['content'] != title
          meta_description = memento.verify(domain, "meta:description", meta['content'])
        end
      end
 
      candidates = [fb_description, twitter_description, meta_description].compact

      if candidates.size > 0
        description = candidates.first
      end

      textify description
    end

    def find_image(html, domain, memento)
      og_image, twitter_image, image_src = nil, nil, nil

      meta = html.at_css("meta[property='og:image']")
      if meta
        og_image = memento.verify(domain, "og:image", meta['content'])
      end

      meta = html.at_css("meta[property='twitter:image']")
      if meta
        twitter_image = memento.verify(domain, "twitter:image", meta['content'])
      end

      link = html.at_css("link[rel=image_src]")
      if link
        image_src = memento.verify(domain, "image_src", link['href'])
      end

      candidates = [og_image, twitter_image, image_src].compact

      candidates.first
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

    def domain(url)
      uri = Addressable::URI.parse(url)
      uri.host
    end

    def textify(html)
      return nil unless html
      Nokogiri::HTML(html).text.chomp.strip
    end
  end
end