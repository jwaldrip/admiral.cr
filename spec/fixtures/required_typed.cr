require "../../src/admiral"

class RequiredTypedFlaggedCommand < Admiral::Command
  define_flag aa : UInt16, required: true

  def run
    puts flags.aa
  end

  def exit(*args)
  end
end
