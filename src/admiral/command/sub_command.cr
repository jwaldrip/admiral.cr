abstract class Admiral::Command
  abstract def sub(command, *args, **params)

  private macro inherited
    private struct SubCommands
      NAMES = [] of String
      DESCRIPTIONS = {} of String => String

      def self.locate(name)
        new(name).locate
      end

      def self.invoke(name, *args, **params)
        new(name).invoke(*args, **params)
      end

      def initialize(name : ::Admiral::StringValue)
        initialize name.value
      end

      def initialize(@name : String)
      end

      def invoke(*args, **params)
        if sub_command_class = locate
          sub_command_class.new(*args, **params, program_name: @name).run!
        else
          raise ::Admiral::Error.new("Invalid subcommand: #{@name}")
        end
      end

      def locate : Nil; end
    end

    def sub(command, *args, **params)
      SubCommands.invoke(command, *args, **params, parent: self)
    end
  end

  macro register_sub_command(command, description = "")
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
