require "../src/admiral"

class MyCommand < Admiral::Command
  class Exec < Admiral::Command
    def run
      puts arguments
    end
  end

  description "An awesome command"

  flag namespace : String, short: n
  flag context : String, short: c
  flag port : UInt16, "the port to start on", short: p, default: 8888_u16
  flag foo : Array(String), "the value of foo", short: f
  flag verbose : Bool, short: v, long: verbose

  argument foo : String, "the value of foo", required: true

  sub_command exec : Exec, "a sub_command"

  def run
    puts flags
    puts arguments
  end
end

# MyCommand.run "--foo bar exec --foo baz -p=9999 a -- b c d --e"
MyCommand.run "--foo bar exec hello"
