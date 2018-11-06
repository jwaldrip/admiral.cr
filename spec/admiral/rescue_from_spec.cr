require "spec"
require "../fixtures/*"

class Admiral::Command
  def panic
    raise "PANIC"
  end
end

describe "rescue_from" do
  it "should handle the rescue" do
    File.tempfile("test") do |io|
      RescuedCommand.run("", output: io)
      io.rewind
      io.gets_to_end.should eq "it failed\n"
    end
  end
end
