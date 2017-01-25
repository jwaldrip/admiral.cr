abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).run!
    end

    protected def run! : Nil
      if @argv[0]? && SubCommands.locate(@argv[0])
        SubCommands.invoke(@argv[0], self)
      else
        run
      end
    rescue e : ::Admiral::Command::Error
      error e.message.colorize(:red)
      exit 1
    end
  end
end
