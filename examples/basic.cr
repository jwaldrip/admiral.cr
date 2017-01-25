require "admiral"

class Basic < Admiral::Command
  define_flag aa
  define_flag default, default: "something"

  def run
  end

  def exit(*args)
  end
end

Basic.run ""
