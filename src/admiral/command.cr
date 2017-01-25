require "./command/*"

abstract class Admiral::Command
  class Error < Exception; end

  class Stub < Command
    def run; end

    delegate exit, to: Process
    INSTANCE = Stub.new([] of String)
  end

  @argv : ::Admiral::ARGV = ::Admiral::ARGV.new(::ARGV)
  @input_io : IO = STDIN
  @output_io : IO = STDOUT
  @error_io : IO = STDERR

  getter program_name : String = PROGRAM_NAME
  getter parent : ::Admiral::Command = ::Admiral::Command::Stub::INSTANCE
  delegate exit, to: @parent

  abstract def run

  def initialize(string : String = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
    initialize(string.split(" "), program_name, input, output, error)
  end

  def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
    initialize(::Admiral::ARGV.new(argv), program_name, input, output, error)
  end

  def initialize(argv : ::Admiral::ARGV, program_name : String, input : IO = STDIN, output : IO = STDOUT, error : IO = STDERR)
    @argv = argv
    @program_name = program_name
    @input_io = input
    @output_io = output
    @error_io = error
  end

  def initialize(command : ::Admiral::Command)
    @argv = command.@argv
    @program_name = command.@program_name
    @input_io = command.@input_io
    @output_io = command.@output_io
    @error_io = command.@error_io
    @parent = command
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
