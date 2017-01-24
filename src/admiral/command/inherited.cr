abstract class Admiral::Command
  private macro inherited
    FLAG_NAMES = [] of String
    ARGUMENT_NAMES = [] of String
    SUB_COMMAND_NAMES = [] of String

    private DESCRIPTIONS = {
      arguments: {} of String => String,
      flags: {} of String => String,
      sub_commands: {} of String => String,
    }

    private struct Flags
      def initialize(command : ::Admiral::Command)
        raise_on_undefined_flags!(command)
      end

      def raise_on_undefined_flags!(command)
        pos_index = (command.@argv.index(&.== "--") || 0) - 1
        undefined_flags = command.@argv[0..pos_index].select(&.starts_with? "--")
        if undefined_flags.size == 1
          raise Admiral::Command::Error.new "The following flag is not defined: #{undefined_flags.first}"
        elsif undefined_flags.size > 1
          raise Admiral::Command::Error.new "The following flags are not defined: #{undefined_flags.join(", ")}"
        end
      end
    end

    private struct Arguments
      delegate :[], :each, to: @__rest__

      @__rest__ : Array(String) = [] of String

      def initialize(command : ::Admiral::Command)
        @__rest__ = parse_rest(command)
      end

      private def parse_rest(command : ::Admiral::Command)
        command.@argv.select(&.!= "--").map(&.value)
      end
    end

    private struct SubCommands
      def self.locate(name : ::Admiral::StringValue)
        new(name).locate
      end

      def self.invoke(name : ::Admiral::StringValue, command : ::Admiral::Command)
        new(name).invoke(command)
      end

      def initialize(@name : ::Admiral::StringValue)
      end

      def invoke(command : ::Admiral::Command)
        if sub_command_class = locate
          command.@argv.shift
          sub_command_class.new(command).run_with_help
        else
          raise ::Admiral::Command::Error.new("Invalid subcommand: #{@name}")
        end
      end

      def locate : Nil; end
    end

    def self.run(*args, **params)
      new(*args, **params).run_with_help
    end

    def initialize(string : String = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
      initialize(string.split(" "), program_name, input, output, error)
    end

    def initialize(argv : Array(String) = ::ARGV.clone, program_name = PROGRAM_NAME, input = STDIN, output = STDOUT, error = STDERR)
      initialize(::Admiral::ARGV.new(argv), program_name, input, output, error)
    end

    def initialize(argv : ::Admiral::ARGV, program_name : String, input : IO = STDIN, output : IO = STDOUT, error : IO = STDERR)
      @argv = argv
      @program_name = program_name
      @input_io = input
      @output_io = output
      @error_io = error
    end

    def initialize(command : ::Admiral::Command)
      @argv = command.@argv
      @program_name = command.@program_name
      @input_io = command.@input_io
      @output_io = command.@output_io
      @error_io = command.@error_io
      @parent = command
    end

    def flags
      @flags ||= Flags.new(self)
    end

    def arguments
      @arguments ||= Arguments.new(self)
    end

    private def puts(*args)
      @output_io.puts(*args)
    end

    private def error(*args)
      @error_io.puts(*args)
    end

    private def gets(*args)
      @input_io.gets(*args)
    end

    protected def run_with_help : Nil
      if flags.help
        puts help
        exit
      elsif @argv[0]? && SubCommands.locate(@argv[0])
        SubCommands.invoke(@argv[0], self)
      else
        run
      end
    rescue e : ::Admiral::Command::Error
      error e.message
      exit 1
    end

    private def help : String
      left_col_len = DESCRIPTIONS.values.flat_map(&.keys).map(&.size).sort[-1]? || 0
      String.build do |str|
        # Add Usage
        str << "Usage:"
        commands = [] of String
        commands << begin
          String.build do |cmd|
            DESCRIPTIONS[:arguments].keys.each do |attr|
              cmd << " <#{attr}>"
            end
            cmd << " [arg...]"
          end
        end
        commands << " {command}" unless DESCRIPTIONS[:sub_commands].empty?
        commands.each do |cmd|
          str << "\n  #{@program_name}"
          str << " [flags...]" unless DESCRIPTIONS[:flags].empty?
          str << cmd unless cmd.empty?
        end
        str << "\n\n" # add newlines

        # Add Description
        str << "#{description}\n" if description

        # Add Flags
        unless DESCRIPTIONS[:flags].empty?
          str << "\nFlags:\n"
          DESCRIPTIONS[:flags].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Args
        unless DESCRIPTIONS[:arguments].empty?
          str << "\nArguments:\n"
          DESCRIPTIONS[:arguments].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Commands
        unless DESCRIPTIONS[:sub_commands].empty?
          str << "\nCommands:\n"
          DESCRIPTIONS[:sub_commands].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end
      end
    end

    def description : Nil
    end

    @parent : ::Admiral::Command = ::Admiral::Command::Stub::INSTANCE
    delegate exit, to: @parent
    flag help : Bool
  end
end
