require "../../src/admiral"

class TypedFlaggedCommand < Admiral::Command
  flag aa : UInt16

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
