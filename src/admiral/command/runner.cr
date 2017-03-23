abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).__run__
    end

    protected def __run__ : Nil
      parse_flags!(validate: true)
      command = arguments.get(:_COMMAND_)
      return sub(command.to_s, arguments.@__rest__) if command
      run
    rescue MissingArgument
      __run_after_missing__
    rescue e : Admiral::Error
      panic e.message.colorize(:red)
    end

    private def __run_after_missing__
      run
    rescue e : Admiral::Error
      panic e.message.colorize(:red)
    end
  end
end
