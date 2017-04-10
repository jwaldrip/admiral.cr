require "../../src/admiral"

class RescuedCommand < Admiral::Command
  class CustomException < Exception
  end

  rescue_from CustomException do |e|
    puts e.message
  end

  def run
    raise CustomException.new("it failed")
  end

  def exit(*args)
  end
end
