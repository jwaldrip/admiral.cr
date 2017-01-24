require "./command/*"

abstract class Admiral::Command
  class Error < Exception; end

  class Stub < Command
    def run; end

    delegate exit, to: Process
    INSTANCE = Stub.new([] of String)
  end

  @parent : Admiral::Command = Stub::INSTANCE

  delegate exit, to: @parent

  def self.run(*args, **params)
    new(*args, **params).run_with_help
  end

  def initialize(string : String = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
    initialize(string.split(" "), program_name, input, output, error)
  end

  def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
    ary = ::Admiral::ARGV.new
    argv.each { |value| ary << Admiral::StringValue.new value }
    initialize(ary, program_name, input, output, error)
  end

  def initialize(argv : Admiral::ARGV, program_name : String, input : IO = STDIN, output : IO = STDOUT, error : IO = STDERR)
    @argv = argv
    @program_name = program_name
    @input_io = input
    @output_io = output
    @error_io = error
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

  protected def run_with_help
    if flags.help
      puts help
      exit
    else
      run
    end
  rescue e : ::Admiral::Command::Error
    error e.message
    exit 1
  end

  abstract def run
end
