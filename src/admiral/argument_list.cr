require "./string_value"

class Admiral::ArgumentList < Array(Admiral::StringValue)
  def self.new(strings : Array(String))
    new.tap do |ary|
      strings.each { |v| ary << StringValue.new v }
    end
  end
end
