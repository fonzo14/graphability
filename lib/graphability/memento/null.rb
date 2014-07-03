module Graphability
  module Memento
    class Null
      def verify(domain, attribute, value)
        value
      end

      alias_method :memorize, :verify
    end
  end
end