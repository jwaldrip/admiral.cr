require "../../src/admiral"

class BasicWithDefaultFlaggedCommand < Admiral::Command
  flag aa, default: "default value"

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
