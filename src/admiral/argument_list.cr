require "./string_value"

module Admiral
  private class ArgumentList < Array(Admiral::StringValue)
    def self.new(strings : Array(String))
      new.tap do |ary|
        strings.each { |v| ary << StringValue.new v }
      end
    end
  end
end
