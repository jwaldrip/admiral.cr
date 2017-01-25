require "../../src/admiral"

class BasicFlaggedCommand < Admiral::Command
  define_flag aa
  define_flag default, default: "something"

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
