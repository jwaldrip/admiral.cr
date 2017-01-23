require "../../src/admiral"

class BasicFlaggedCommand < Admiral::Command
  flag aa
  flag default, default: "something"

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
