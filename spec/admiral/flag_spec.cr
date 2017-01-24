require "spec/dsl"
require "../fixtures/*"

describe "flags" do
  context "basic flags" do
    context "with a positional value" do
      it "should puts the value" do
        io = IO::Memory.new
        BasicFlaggedCommand.run(["--aa", "foo"], output: io)
        io.rewind
        io.gets_to_end.should eq "foo\n"
      end
    end

    context "with an assigned value (`=`)" do
      it "should puts the value" do
        io = IO::Memory.new
        BasicFlaggedCommand.run(["--aa=foo"], output: io)
        io.rewind
        io.gets_to_end.should eq "foo\n"
      end
    end

    context "without a value" do
      it "should raise an error" do
        io = IO::Memory.new
        BasicFlaggedCommand.run(["--aa"], error: io)
        io.rewind
        io.gets_to_end.should eq "Flag: --aa is missing a value\n"
      end
    end

    context "with a default" do
      it "should return the default" do
        io = IO::Memory.new
        BasicFlaggedCommand.run([] of String, output: io)
        io.rewind
        io.gets_to_end.should eq "\n"
      end

      it "should raise an error" do
        io = IO::Memory.new
        BasicWithDefaultFlaggedCommand.run([] of String, output: io)
        io.rewind
        io.gets_to_end.should eq "default value\n"
      end
    end
  end

  context "typed flags" do
    context "with a positional value" do
      it "should puts the value" do
        io = IO::Memory.new
        TypedFlaggedCommand.run(["--aa", "123"], output: io)
        io.rewind
        io.gets_to_end.should eq "123\n"
      end
    end

    context "with an assigned value (`=`)" do
      it "should puts the value" do
        io = IO::Memory.new
        TypedFlaggedCommand.run(["--aa=123"], output: io)
        io.rewind
        io.gets_to_end.should eq "123\n"
      end
    end

    context "without a value" do
      it "should raise an error" do
        io = IO::Memory.new
        TypedFlaggedCommand.run(["--aa"], error: io)
        io.rewind
        io.gets_to_end.should eq "Flag: --aa is missing a value\n"
      end
    end

    context "with a default" do
      it "should return the default" do
        io = IO::Memory.new
        TypedFlaggedCommand.run([] of String, output: io)
        io.rewind
        io.gets_to_end.should eq "\n"
      end

      it "should raise an error" do
        io = IO::Memory.new
        TypedWithDefaultFlaggedCommand.run([] of String, output: io)
        io.rewind
        io.gets_to_end.should eq "678\n"
      end

      context "when required" do
        io = IO::Memory.new
        RequiredTypedFlaggedCommand.run([] of String, error: io)
        io.rewind
        io.gets_to_end.should eq "Flag: --aa is required\n"
      end
    end
  end
end
