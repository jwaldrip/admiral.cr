require "../src/admiral"

class MyCommand < Admiral::Command
  class Exec < Admiral::Command
    def run
      puts parent.flags
      puts arguments
    end
  end

  define_flag namespace : String, short: n
  define_flag context : String, short: c
  define_flag port : UInt16, "the port to start on", short: p, default: 8888_u16
  define_flag foo : Array(String), "the value of foo", short: f
  define_flag verbose : Bool, short: v, long: verbose

  define_argument foo : String, "the value of foo", required: true

  define_sub_command exec : Exec, "a sub_command"

  define_help description: "An awesome command"

  define_version "1.0.0"

  def run
    puts flags.port
  end
end

MyCommand.run "--version"
