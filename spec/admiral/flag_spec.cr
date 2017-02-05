require "spec"
require "tempfile"
require "../fixtures/*"

describe "flags" do
  context "basic flags" do
    context "with a positional value" do
      it "should puts the value" do
        Tempfile.open("test") do |io|
          BasicFlaggedCommand.run(["--aa", "foo"], output: io)
          io.rewind
          io.gets_to_end.should eq "foo\n"
        end
      end
    end

    context "with an assigned value (`=`)" do
      it "should puts the value" do
        Tempfile.open("test") do |io|
          BasicFlaggedCommand.run(["--aa=foo"], output: io)
          io.rewind
          io.gets_to_end.should eq "foo\n"
        end
      end
    end

    context "without a value" do
      it "should raise an error" do
        Tempfile.open("test") do |io|
          BasicFlaggedCommand.run(["--aa"], error: io)
          io.rewind
          io.gets_to_end.should eq "Flag: --aa is missing a value".colorize(:red).to_s + "\n"
        end
      end
    end

    context "with a default" do
      it "should return the default" do
        Tempfile.open("test") do |io|
          BasicFlaggedCommand.run([] of String, output: io)
          io.rewind
          io.gets_to_end.should eq "\n"
        end
      end

      it "should raise an error" do
        Tempfile.open("test") do |io|
          BasicWithDefaultFlaggedCommand.run([] of String, output: io)
          io.rewind
          io.gets_to_end.should eq "default value\n"
        end
      end
    end
  end

  context "typed flags" do
    context "with a positional value" do
      it "should puts the value" do
        Tempfile.open("test") do |io|
          TypedFlaggedCommand.run(["--aa", "123"], output: io)
          io.rewind
          io.gets_to_end.should eq "123\n"
        end
      end
    end

    context "with an assigned value (`=`)" do
      it "should puts the value" do
        Tempfile.open("test") do |io|
          TypedFlaggedCommand.run(["--aa=123"], output: io)
          io.rewind
          io.gets_to_end.should eq "123\n"
        end
      end
    end

    context "with a default" do
      it "should return the default" do
        Tempfile.open("test") do |io|
          TypedFlaggedCommand.run([] of String, output: io)
          io.rewind
          io.gets_to_end.should eq "\n"
        end
      end

      it "should raise an error" do
        Tempfile.open("test") do |io|
          TypedWithDefaultFlaggedCommand.run([] of String, output: io)
          io.rewind
          io.gets_to_end.should eq "678\n"
        end
      end

      context "when required" do
        Tempfile.open("test") do |io|
          RequiredTypedFlaggedCommand.run([] of String, error: io)
          io.rewind
          io.gets_to_end.should eq "Flag: --aa is required".colorize(:red).to_s + "\n"
        end
      end
    end
  end
end
