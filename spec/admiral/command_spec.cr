require "spec"
require "tempfile"
require "../fixtures/*"

describe "commands" do
  context "when required" do
    it "should raise an error" do
      Tempfile.open("test") do |io|
        RequiredArgumentCommand.run([] of String, error: io)
        io.rewind
        io.gets_to_end.should eq "Argument required: aa".colorize(:red).to_s + "\n"
      end
    end
  end
end
