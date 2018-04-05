abstract class Admiral::Command
  private module Run
    def run
      raise ::Admiral::Error.new("Missing subcommand.")
    end
  end

  # Invokes a sub command by name, passing `self` as the parent.
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
          sub_command_class.new(*args, **params, program_name: @name).run
        else
          raise ::Admiral::Error.new("Invalid subcommand: #{@name}.")
        end
      end

      def locate : Nil; end
    end

    def sub(command, *args, **params)
      SubCommands.invoke(command, *args, **params, parent: self)
    end
  end

  # Registers a subcommand.
  #
  # ```crystal
  # # hello.cr
  # class Hello < Admiral::Command
  #   class Planetary < Admiral::Command
  #     def run
  #       puts "Hello World"
  #     end
  #   end
  #
  #   class Municipality < Admiral::Command
  #     def run
  #       puts "Hello Denver"
  #     end
  #   end
  #
  #   register_subcommand planet : Planetary
  #   register_subcommand city : Municipality
  #
  #   def run
  #     puts help
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # ```sh
  # $ crystal build ./hello.cr
  # $ ./hello planet
  # Hello World
  # $ ./hello city
  # Hello Denver
  # ```
  macro register_sub_command(command, type = nil, *, description = nil, short = nil)
    {% if command.is_a? TypeDeclaration %}
      {% name = command.var.stringify %}
      {% type = command.type %}
    {% else %}
      {% name = command.id.stringify %}
    {% end %}

    {% SubCommands::NAMES << name unless SubCommands::NAMES.includes? name %}

    # Add the subcommand to the description constant
    SubCommands::DESCRIPTIONS[{{ name }}{% if short %} + ", {{ short.id }}" {% end %}] = {{ description }} || {{ type }}::HELP["description"]

    {% unless Arguments::NAMES.includes? "_COMMAND_" %}
      define_argument "_COMMAND_", "The sub command to run."
    {% end %}

    private struct SubCommands
      def locate
        previous_def || begin
          if @name == {{ name }} {% if short %}|| @name == {{ short.id.stringify }} {% end %}
            {{ type }}
          end
        end
      end
    end

    include Run
  end
end
