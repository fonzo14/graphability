module Graphability
  class Author
    attr_accessor :platform, :name, :url

    def initialize(platform, name, url, image)
      @platform, @name, @url, @image = platform, name, url, image
    end

    def to_h
      {
          :platform => @platform.to_h,
          :name => @name,
          :url => @url,
          :image => @image
      }
    end

    UNKNOWN = Author.new(Platform::UNKNOWN, "", "", "")
  end
end