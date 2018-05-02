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
        parse_flags!(validate: true)
        command = arguments.get?(:_COMMAND_)
        next sub(command.to_s, arguments.@__rest__) if command
        run
      end
    end
  end
end
