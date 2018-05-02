require "spec"
require "tempfile"
require "../fixtures/*"

describe "commands" do
  context "when required" do
    it "should raise an error" do
      Tempfile.open("test") do |io|
        RequiredArgumentCommand.run([] of String, error: io)
        io.rewind
        io.gets_to_end.should eq "Missing required attribute: <aa>".colorize(:red).to_s + "\n"
      end
    end

    context "when help is passed" do
      it "should not raise an error" do
        Tempfile.open("test") do |io|
          RequiredArgumentCommand.run(["--help"] of String, output: io)
          io.rewind
          io.gets_to_end.includes?("HELP TEXT").should be_true
        end
      end
    end

    context "when version is passed" do
      it "should not raise an error" do
        Tempfile.open("test") do |io|
          RequiredArgumentCommand.run(["--version"] of String, output: io)
          io.rewind
          io.gets_to_end.includes?("1.0.0").should be_true
        end
      end
    end
  end
end
