module Graphability
  module Builder
    module Helper
      def parse(url, body)
        begin
          Nokogiri::HTML(body, url)
        rescue Exception
          body.encode!('UTF-8', 'UTF-8', :invalid => :replace)
          Nokogiri::HTML(body, url)
        end
      end

      def extract_meta(html, name)
        (html.at_css("meta[property='#{name}']") || html.at_css("meta[name='#{name}']"))['content'] rescue nil
      end

      def extract_link(html, name)
        html.at_css("link[rel='#{name}']")['href'] rescue nil
      end

      def to_text(html, options = {})
        return "" if html.to_s.empty?
        text = []
        options = {:max_length => 25, :replacement => '[...]'}.merge(options)
        Nokogiri::HTML(html).traverse do |node|
          text << node.text unless node.children.size > 0
        end
        text = text.compact.join(' ').gsub("<br />", '').gsub("<br/>", '').gsub(/\s+/, ' ').strip
        text = text.split(' ').map do |word|
          (word =~ /[[:alnum:]][^[:alnum:]]+[[:alnum:]]/ && (real_length(word) > options[:max_length])) ? options[:replacement] : word
        end
        text = text.join(' ')
        if !options.key?(:second_call) && text.match(/<.*\/?>/)
          text = to_text(text, options.merge(:second_call => true))
        end
        text
      end

      private
      def real_length(word)
        word.gsub(/^\W+/, '').gsub(/\W+$/, '').size
      end
    end
  end
end