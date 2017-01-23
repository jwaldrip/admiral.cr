require "./admiral/*"
require "./core_ext/*"

module Admiral
  struct StringValue
    getter value : String

    def initialize(@value : String); end

    {% for method in String.methods %}
      delegate(:{{method.name}}, to: @value)
    {% end %}
  end

  class ARGV < Array(StringValue); end
end
