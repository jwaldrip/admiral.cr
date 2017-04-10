abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).__run__
    end

    rescue_from Admiral::Error do |e|
      panic e.message.colorize(:red)
    end

    rescue_from MissingArgument do |e|
      STDERR.puts "missing arg"
      run
    end

    protected def __run__ : Nil
      run_with_rescue do
        parse_flags!(validate: true)
        command = arguments.get?(:_COMMAND_)
        next sub(command.to_s, arguments.@__rest__) if command
        run
      end
    end
  end
end
