module Graphability
  class Platform
    attr_reader :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    def to_h
      {
          :id => @id,
          :name => @name.to_s
      }
    end

    DAILYMOTION = Platform.new(0, :dailymotion)
    YOUTUBE     = Platform.new(1, :youtube)
    TWITTER     = Platform.new(2, :twitter)
    INSTAGRAM   = Platform.new(3, :instagram)
    VINE        = Platform.new(4, :vine)
    TUMBLR      = Platform.new(5, :tumblr)
    FACEBOOK    = Platform.new(6, :facebook)
    UNKNOWN     = Platform.new(7, :unknown)

    class << self
      def [](name)
        case name.to_sym
          when :dailymotion then DAILYMOTION
          when :youtube then YOUTUBE
          when :twitter then TWITTER
          when :instagram then INSTAGRAM
          when :vine then VINE
          when :tumblr then TUMBLR
          when :facebook then FACEBOOK
          else UNKNOWN
        end
      end
    end
  end
end