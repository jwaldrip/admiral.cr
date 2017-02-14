abstract class Admiral::Command
  # Returns the commands `Arguments` object.
  #
  # You can access names arguments by name.
  # You can also access the remaning arguments using `.arguments[index]`.
  abstract def arguments

  private macro inherited
    struct Arguments
      include Enumerable(String)
      include Iterable(String)

      NAMES = [] of String
      REQUIRED_NAMES = [] of String
      DESCRIPTIONS = {} of String => String

      delegate :[], :each, to: @__rest__

      @__rest__ : Array(String) = [] of String

      def initialize(command : ::Admiral::Command)
        @__rest__ = parse_rest(command)
      end

      private def parse_rest(command : ::Admiral::Command)
        command.@argv.select(&.!= "--").map(&.value)
      end

      def inspect(io)
        names = NAMES.clone
        names << "..." if size > 0
        io << "<#{self.class}"
        io << "("
        io << names.join(", ") unless names.empty?
        io << ")"
        io << ">"
      end
    end

    def arguments
      @arguments ||= Arguments.new(self)
    end
  end

  # Defines a named command line argument.
  #
  # ### Simple Arguments
  # Simple arguments are denoted only by a name and will compile to returning a `String | Nil`.
  #
  # ```crystal
  # # hello.cr
  # class Hello < Admiral::Command
  #   define_argument planet
  #
  #   def run
  #     puts "Hello #{arguments.planet || "World"}"
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # ```sh
  # $ crystal build ./world.cr
  # $ ./hello
  # Hello World
  # $ ./hello Alderaan
  # Hello Alderaan
  # ```
  #
  # ### Typed Arguments
  # Arguments can also be assigned a type. This will result in a properly typed value when
  # calling `arguments.arg_name`. By default arguments are not required and will return a
  # `Union` including the type and `Nil`.
  #
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_argument number_of_greetings : UInt32, default: 1_u32
  #
  #   def run
  #     arguments.number_of_greetings.times do
  #       puts "Hello World"
  #     end
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # ```sh
  # $ crystal build ./hello_world.cr
  # $ ./hello_world  3
  # Hello World
  # Hello World
  # Hello World
  # ```
  #
  # #### Built in argument types
  # The following classes are assignable as arguments by default:
  # * `String`
  # * `Bool`
  # * `Float32`
  # * `Float64`
  # * `Int8`
  # * `Int16`
  # * `Int32`
  # * `Int64`
  # * `UInt8`
  # * `UInt16`
  # * `UInt32`
  # * `UInt64`
  #
  # **Pro Tip:**
  # To make any `Class` or `Struct` assignable as a argument, define a `.new(value : ::Admiral::StringValue)` or
  # `#initialize(value : ::Admiral::StringValue)`.
  #
  # ### Additional Argument Options
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_argument number_of_greetings : UInt32,
  #     description: "The number of times to greet the world", # The description of the argument to be used in auto generated help.
  #     default: 1_u32,                                        # The default value of the argument.
  #     required: true                                         # Denotes if a argument is required. Required arguments without a default value will raise an error when not specified at command invocation.
  #
  #
  #   def run
  #     arguments.number_of_greetings.times do
  #       puts "Hello World"
  #     end
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # **Note:**
  # Required arguments cannot be defined after optional arguments.
  macro define_argument(attr, description = "", default = nil, required = false)
    {% var = attr.is_a?(TypeDeclaration) ? attr.var : attr.id %}
    {% type = attr.is_a?(TypeDeclaration) ? attr.type : String %}
    {% raise "Cannot define required argument `#{var}` after optional arguments" if required && Arguments::NAMES != Arguments::REQUIRED_NAMES %}
    {% raise "A argument with the name `#{var}` has already been defined" if Arguments::NAMES.includes? var.stringify %}
    {% Arguments::NAMES << var.stringify %}
    {% Arguments::REQUIRED_NAMES << var.stringify if required == true && !Arguments::REQUIRED_NAMES.includes?(var.stringify) %}

    struct Arguments
      getter {{ var }} : {{ type }}{% unless required %} | Nil{% end %}

      def initialize(command : ::Admiral::Command)
        {% for a in Arguments::NAMES %}
        @{{ a.id }} = parse_{{ a.id }}(command){% end %}
        @__rest__ = parse_rest(command)
      end

      def parse_{{ var }}(command : ::Admiral::Command) : {{ type }}{% unless required %} | Nil{% end %}
        pos_only = false
        index = 0
        while command.@argv[index]?.to_s.starts_with?("-") && !pos_only
          index += 1
          pos_only = command.@argv[index]? == "--"
        end
        value = if command.@argv[index]?
                  command.@argv.delete_at index
                else
                  {% if required %}raise Admiral::Error.new "Missing required attribute: <{{var}}>"{% else %}return nil{% end %}
                end
        {{ type }}.new(value)
      end
    end

    # Add the attr to the description constant
    Arguments::DESCRIPTIONS[{{ var.stringify }}{% if required %} + " (required)"{% end %}] = {{ description }}
  end
end
