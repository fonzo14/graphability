module Graphability
  class DocumentType
    attr_reader :id, :name

    def initialize(id, name)
      @id, @name = id, name
    end

    def to_h
      {
          :id => @id,
          :name => @name.to_s
      }
    end

    ARTICLE = DocumentType.new(0, :article)
    VIDEO   = DocumentType.new(1, :video)
    IMAGE   = DocumentType.new(2, :image)
    VINE    = DocumentType.new(3, :vine)
    TWEET   = DocumentType.new(4, :tweet)

    class << self
      def [](name)
        case name.to_sym
          when :article then ARTICLE
          when :video then VIDEO
          when :image then IMAGE
          when :vine then VINE
          when :tweet then TWEET
          else ARTICLE
        end
      end
    end
  end
end