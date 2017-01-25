require "../../src/admiral"

class TypedWithDefaultFlaggedCommand < Admiral::Command
  define_flag aa : UInt16, default: 678_u16

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
