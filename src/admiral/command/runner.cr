abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).run!
    end

    protected def run! : Nil
      parse_flags!
      command = arguments.get(:_COMMAND_)
      if command
        sub(command.to_s, arguments.@__rest__)
      else
        run
      end
    rescue MissingArgument
      run
    rescue e : Admiral::Error
      panic e.message.colorize(:red)
    end
  end
end
