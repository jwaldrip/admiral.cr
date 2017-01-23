require "../src/admiral"

class MyCommand < Admiral::Command
  description "An awesome command"

  flag namespace : String, short: n, optional: true
  flag context : String, short: c, optional: true
  flag port : UInt16, "the port to start on", short: p, default: 8888_u16
  flag foo : Array(String), "the value of foo", short: f
  flag verbose : Bool, short: v, long: verbose
  argument foo : String, "the value of foo", required: true

  sub_command exec : Sub, "a sub_command"

  def run
    puts flags
    puts arguments
  end

  class Sub < Admiral::Command
    def run
    end
  end
end

MyCommand.run "hello --foo bar --foo baz -p=9999 a -- b c d --e"
