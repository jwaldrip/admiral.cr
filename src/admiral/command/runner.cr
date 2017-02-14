abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).run!
    end

    protected def run! : Nil
      flags
      if @argv[0]? && SubCommands.locate(@argv[0])
        command = @argv.shift
        sub(command, @argv)
      else
        arguments
        run
      end
    rescue e : Admiral::Error
      panic e.message.colorize(:red)
    end
  end
end
