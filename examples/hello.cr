require "../src/admiral"

class Hello < Admiral::Command
  define_help description: "A command that says hello"
  define_argument planet, default: "World"

  def run
    puts "Hello #{arguments.planet}"
  end
end

Hello.run "--help"
