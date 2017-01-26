require "./argument_list"
require "./command/*"

abstract class Admiral::Command
  @argv : ArgumentList = ArgumentList.new(::ARGV)
  @input_io : IO = STDIN
  @output_io : IO = STDOUT
  @error_io : IO = STDERR

  # Returns the commands program name.
  getter program_name : String = PROGRAM_NAME

  # Initializes a command with a `String`, which will be split into arguments.
  def initialize(string : String, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(string.split(" "), program_name, input, output, error, parent)
  end

  # Initializes a command with an `Array(String)` of arguments.
  def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(ArgumentList.new(argv), program_name, input, output, error, parent)
  end

  # Initializes a command with an `Admiral::ArgumentList`.
  def initialize(@argv : ArgumentList, program_name : String, input : IO? = nil, output : IO? = nil, error : IO? = nil, parent : ::Admiral::Command? = nil)
    @program_name = parent ? "#{parent.program_name} #{program_name}" : program_name
    @parent = parent
    @input_io = input ? input : parent ? parent.@input_io : STDIN
    @output_io = output ? output : parent ? parent.@output_io : STDOUT
    @error_io = error ? error : parent ? parent.@error_io : STDERR
  rescue e : ::Admiral::Error
    @error_io.puts e.message.colorize(:red)
    exit 1
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

  # Puts to the command's output `IO`.
  def puts(*args)
    @output_io.puts(*args)
  end

  # Puts to the command's error `IO`.
  def error(*args)
    @error_io.puts(*args)
  end

  # Gets from the command's input `IO`.
  def gets(*args)
    @input_io.gets(*args)
  end
end
