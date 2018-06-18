abstract class Admiral::Command
  class MissingArgument < Exception; end

  # Returns the commands `Arguments` object.
  #
  # You can access names arguments by name.
  # You can also access the remaning arguments using `.arguments[index]`.
  abstract def arguments

  private macro inherited
    struct Arguments
      include Enumerable(String)
      include Iterable(String)

      SPECS = {} of String => NamedTuple(
        type: String,
        description: Tuple(String, String),
        default: String,
        is_required: Bool
      )

      delegate :[], :each, to: @__rest__
      @__rest__ : Array(String) = [] of String

      macro finished
        def initialize(command : ::Admiral::Command)
          \{% for var, spec in SPECS %}
            @\{{var.id}} = value_from_spec(
              command,
              arg: \{{var}},
              type: \{{ spec[:type].id }},
              default: \{{ spec[:default].id }},
              is_required: \{{ spec[:is_required].id }}
            )
          \{% end %}
          @__rest__ = command.@argv.map(&.value)
        end

        def get(name : Symbol)
          \{% if !SPECS.empty? %}
            {
              \{% for var, spec in SPECS %}
                \{{var.id}}: @\{{var.id}},
              \{% end %}
            }[name]?
          \{% end %}
        end

        def get?(name : Symbol)
          exists?(name) ? get(name) : false
        end

        def exists?(name : Symbol)
          !!SPECS[name]?
        end

        def validate!(command : ::Admiral::Command)
        end
      end

      def value_from_spec(command : ::Admiral::Command, *, arg : String, type, default, is_required : Bool)
        pos_only = false
        index = 0
        while command.@argv[index]?.to_s.starts_with?("-") && !pos_only
          index += 1
          pos_only = command.@argv[index]? == "--"
        end
        if command.@argv[index]?
          value = command.@argv.delete_at index
          type.new(value)
        end
      end

      def get(name : Symbol) : Nil
        raise MissingArgument.new
      end

      def get?(name : Symbol)
        exists?(name) ? get(name) : false
      end

      def exists?(name : Symbol)
        false
      end

      def inspect(io)
        names = SPECS.keys
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
    {%
      var = attr.is_a?(TypeDeclaration) ? attr.var : attr.id
      type = attr.is_a?(TypeDeclaration) ? attr.type : String
      Arguments::SPECS[var.id.stringify] = {
        type: type.stringify,
        description: {
          var.stringify.gsub(/_([A-Z_]+)_/, "\\1") + (required ? " (required)" : ""),
          description
        },
        default: default.id.stringify,
        is_required: required
      }
    %}

    struct Arguments
      @{{ var }} : {{ type }} | Nil

      def {{var}} : {{ type }}{% unless required %} | Nil{% end %}
        @{{var}}{% if required %}.not_nil!{% end %}
      end
    end
  end
end
