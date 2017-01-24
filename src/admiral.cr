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

  class ARGV < Array(StringValue)
    def self.new(strings : Array(String))
      new.tap do |ary|
        strings.each { |v| ary << StringValue.new v }
      end
    end
  end
end
