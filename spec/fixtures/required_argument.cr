require "../../src/admiral"

class RequiredArgumentCommand < Admiral::Command
  define_help description: "HELP TEXT"
  define_version "1.0.0"
  define_argument aa, required: true

  def run
    puts arguments.aa
  end

  def exit(*args)
  end
end
