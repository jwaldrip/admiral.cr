require "./string_value"

module Admiral
  alias ArgumentList = Array(Admiral::StringValue)

  def self.new_arglist(strings : Array(String))
    ArgumentList.new.tap do |ary|
      strings.each { |v| ary << StringValue.new v }
    end
  end
end
