require "./command/*"

abstract class Admiral::Command
  class Error < Exception; end

  class Stub < Command
    def run; end

    delegate exit, to: Process
    INSTANCE = Stub.new([] of String)
  end

  @argv : ::Admiral::ARGV = ::Admiral::ARGV.new(::ARGV)

  abstract def run
end
