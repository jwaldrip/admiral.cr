require "./argument_list"
require "./command/*"

abstract class Admiral::Command
  @argv : ArgumentList
  @program_name : String
  @argv : ArgumentList = Admiral.new_arglist(::ARGV)
  @input_io : IO::FileDescriptor | Bool = STDIN
  @output_io : IO::FileDescriptor | Bool = STDOUT
  @error_io : IO::FileDescriptor | Bool = STDERR
  @parent : ::Admiral::Command?

  # Returns the commands program name.
  getter program_name : String = PROGRAM_NAME

  def self.expand_short_flags(argv : Admiral::ArgumentList)
    Admiral::ArgumentList.new.tap do |args|
      argv.each do |arg|
        if arg =~ /^-\w+/
          flags_with_value = arg.split("=", 2)
          flags = flags_with_value[0][1..-1].chars.map(&.to_s)
          if value = flags_with_value[1]?
            flags[-1] = flags[-1] + "=" + value
          end
          flags.each do |flag|
            args << StringValue.new("-" + flag)
          end
        else
          args << arg
        end
      end
    end
  end

  # Initializes a command with a `String`, which will be split into arguments.
  def initialize(string : String, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(string.split(" "), program_name, input, output, error, parent)
  end

  # Initializes a command with an `Array(String)` of arguments.
  def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(Admiral.new_arglist(argv), program_name, input, output, error, parent)
  end

  # Initializes a command with an `Admiral::ArgumentList`.
  def initialize(argv, program_name, input = nil, output = nil, error = nil, parent = nil)
    @argv = self.class.expand_short_flags argv
    @program_name = parent ? "#{parent.program_name} #{program_name}" : program_name
    @parent = parent
    @input_io = !input.nil? ? input : !parent.nil? ? parent.@input_io : STDIN
    @output_io = !output.nil? ? output : !parent.nil? ? parent.@output_io : STDOUT
    @error_io = !error.nil? ? error : !parent.nil? ? parent.@error_io : STDERR
  end

  # The run command.
  abstract def run

  # Returns the parent command if one is specified, or returns an error.
  def parent
    if (parent = @parent)
      parent
    else
      raise Error.new "No parent record"
    end
  end

  # Prints to the command's output `IO`.
  def print(*args)
    case (io = @output_io)
    when IO
      io.print(*args)
    end
  end

  # Puts to the command's output `IO`.
  def puts(*args)
    case (io = @output_io)
    when IO
      io.puts(*args)
    end
  end

  # Puts to the command's error `IO`.
  def error(*args)
    case (io = @error_io)
    when IO
      io.puts(*args)
    end
  end

  def panic(*args)
    error *args
    exit 1
  end

  # Prints to the command's error `IO`.
  def print_error(*args)
    case (io = @error_io)
    when IO
      io.print(*args)
    end
  end

  # Gets from the command's input `IO`.
  def gets(*args)
    case (io = @input_io)
    when IO
      io.gets(*args)
    else
      raise "Input is not allocated"
    end
  end
end
