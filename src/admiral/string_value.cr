# A wrapper for arguments passed to `Admiral::Command.run`
# All methods are delegated to `String`.
struct Admiral::StringValue
  getter value : String

  def initialize(@value : String); end

  {% for method in String.methods %}
    delegate(:{{method.name}}, to: @value)
  {% end %}
end
