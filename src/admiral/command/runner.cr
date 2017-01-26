abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).run!
    end

    protected def run! : Nil
      if @argv[0]? && SubCommands.locate(@argv[0])
        command = @argv.shift
        sub(command, @argv)
      else
        puts "running: #{program_name}"
        run
      end
    rescue e : ::Admiral::Error
      error e.message.colorize(:red)
      exit 1
    end
  end
end
