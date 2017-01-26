class Array(T)
  def self.new(argv : ::Admiral::ArgumentList)
    argv.map { |arg| T.new arg }
  end
end

struct Set(T)
  def self.new(argv : ::Admiral::ArgumentList)
    argv.map { |arg| T.new arg }.to_set
  end
end

def String.new(sv : ::Admiral::StringValue)
  sv.to_s
end

def Bool.new(sv : ::Admiral::StringValue)
  value = sv.downcase
  if %w(1 y yes t true).includes? value
    true
  elsif %w(0 n no f false).includes? value
    false
  else
    raise "#{sv.value} is not a valid boolean value"
  end
end

def Int.new(sv : ::Admiral::StringValue)
  sv.to_i
end

{% for int in %w(8 16 32 64).map(&.id) %}
  def Int{{ int }}.new(sv : ::Admiral::StringValue)
    sv.to_i{{ int }}
  end

  def UInt{{ int }}.new(sv : ::Admiral::StringValue)
    sv.to_u{{ int }}
  end
{% end %}

def Float.new(sv : ::Admiral::StringValue)
  sv.to_f
end

{% for fl in %w(32 64).map(&.id) %}
  def Float{{ fl }}.new(sv : ::Admiral::StringValue)
    sv.to_f{{ fl }}
  end
{% end %}
