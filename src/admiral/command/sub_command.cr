abstract class Admiral::Command
  private macro inherited
    private struct SubCommands
      NAMES = [] of String
      DESCRIPTIONS = {} of String => String

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
          sub_command_class.new(command).run!
        else
          raise ::Admiral::Command::Error.new("Invalid subcommand: #{@name}")
        end
      end

      def locate : Nil; end
    end
  end

  macro define_sub_command(command, description = "")
    {% raise "Subcommand: `#{command.var}` must have a type declared" unless command.is_a? TypeDeclaration %}
    {% raise "Subcommand: `#{command.var}` type must inherit from Admiral::Command" unless command.type.resolve < ::Admiral::Command %}
    {% SubCommands::NAMES << command.var.stringify unless SubCommands::NAMES.includes? command.var.stringify %}

    # Add the subcommand to the description constant
    SubCommands::DESCRIPTIONS[{{ command.var.stringify }}] = {{ description }}

    private struct SubCommands
      def locate
        previous_def || @name == {{ command.var.stringify }} ? {{ command.type }} : nil
      end
    end
  end
end
