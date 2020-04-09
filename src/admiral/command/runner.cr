abstract class Admiral::Command
  private macro inherited
    def self.run(*args, **params)
      new(*args, **params).parse_and_run
    end

    rescue_from ::Admiral::Error do |e|
      panic e.message.colorize(:red)
    end

    protected def parse_and_run : Nil
      with_rescue do
        puts_version
        puts_help
        validate_flags!
        validate_arguments!
        command = @argv.shift if SubCommands.locate(@argv[0]?)
        next sub(command.to_s, @argv) if command
        run
      end
    end
  end
end
