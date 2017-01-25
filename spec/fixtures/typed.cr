require "../../src/admiral"

class TypedFlaggedCommand < Admiral::Command
  define_flag aa : UInt16

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
