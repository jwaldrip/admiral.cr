require "./argument_list"
require "./command/*"

abstract class Admiral::Command
  @argv : ::Admiral::ArgumentList = ::Admiral::ArgumentList.new(::ARGV)
  @input_io : IO = STDIN
  @output_io : IO = STDOUT
  @error_io : IO = STDERR

  getter program_name : String = PROGRAM_NAME

  abstract def run

  def initialize(string : String = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(string.split(" "), program_name, input, output, error, parent)
  end

  def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR, parent : ::Admiral::Command? = nil)
    initialize(::Admiral::ArgumentList.new(argv), program_name, input, output, error, parent)
  end

  def initialize(@argv : ::Admiral::ArgumentList, @program_name : String, input : IO? = nil, output : IO? = nil, error : IO? = nil, parent : ::Admiral::Command? = nil)
    @parent = parent
    @input_io = input ? input : parent ? parent.@input_io : STDIN
    @output_io = output ? output : parent ? parent.@output_io : STDOUT
    @error_io = error ? error : parent ? parent.@error_io : STDERR
  end

  def exit(*args)
    (parent = @parent) ? parent.exit(*args) : Process.exit(*args)
  end

  def parent
    if (parent = @parent)
      parent
    else
      raise Error.new "No parent record"
    end
  end

  def puts(*args)
    @output_io.puts(*args)
  end

  def error(*args)
    @error_io.puts(*args)
  end

  def gets(*args)
    @input_io.gets(*args)
  end
end
