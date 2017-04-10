require "spec"
require "tempfile"
require "../fixtures/*"

class Admiral::Command
  def panic
    raise "PANIC"
  end
end

describe "rescue_from" do
  it "should handle the rescue" do
    RescuedCommand.run("")
  end
end
