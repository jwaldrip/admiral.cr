require "spec"
require "tempfile"
require "../fixtures/*"

describe "arguments" do
  context "when required" do
    context "when given" do
      it "should not raise an error" do
        Tempfile.open("test") do |io|
          RequiredArgumentCommand.run(["abc"] of String, output: io)
          io.rewind
          io.gets_to_end.should eq "abc\n"
        end
      end
    end

    context "when not given" do
      it "should raise an error" do
        Tempfile.open("test") do |io|
          RequiredArgumentCommand.run([] of String, error: io)
          io.rewind
          io.gets_to_end.should eq "Argument required: aa".colorize(:red).to_s + "\n"
        end
      end
    end
  end
end
