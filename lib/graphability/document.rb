module Graphability
  class Document
    EMPTY = Document.new

    attr_reader :title, :text
    attr_accessor :image, :type, :platform, :url, :created_at, :author

    def title=(t)
      title = t.to_s.strip
      elements = title.split("|")
      if elements.size == 2
        title = elements.sort_by { |e| e.size }.last
      end
      @title = truncate(title, 150)
    end

    def text=(t)
      @text = truncate(t.to_s.strip, 250)
    end

    def valid?
      is_valid = (author && title && !title.empty? && title.size > 5 && url && url.valid?)
      unless is_valid
        log.debug "[NOT VALID] #{to_h}" if log.debug?
      end
      is_valid
    end

    def to_h
      {
          :url        => url ? url.url : "",
          :title      => title,
          :text       => text,
          :image      => image,
          :created_at => created_at,
          :platform   => platform.to_h,
          :type       => type.to_h,
          :author     => author.to_h
      }
    end

    def to_s
      to_h.to_s
    end

    private
    def truncate(text, length, options = {})
      text = text.dup
      options[:omission] ||= "..."

      length_with_room_for_omission = length - options[:omission].length
      chars = text
      stop = options[:separator] ?
          (chars.rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission) : length_with_room_for_omission

      (chars.length > length ? chars[0...stop] + options[:omission] : text).to_s
    end
  end
end