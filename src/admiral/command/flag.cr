require "colorize"

abstract class Admiral::Command
  # Returns the commands `Flags` object.
  #
  # You can access names flags by name.
  abstract def flags

  private macro inherited
    struct Flags
      NAMES = [] of String
      DESCRIPTIONS = {} of String => String
      SHORT_NAMES = [] of String
      LONG_NAMES = [] of String

      def initialize(command : ::Admiral::Command)
      end

      def validate!(command)
        pos_index = (command.@argv.index(&.== "--") || 0) - 1
        undefined_flags = [] of String
        command.@argv[0..pos_index].each do |arg|
          if SubCommands.locate(arg)
            break
          elsif arg.starts_with? "-"
            undefined_flags << arg.split("=")[0]
          end
        end

        if undefined_flags.size == 1
          raise Admiral::Error.new "The following flag is not defined: #{undefined_flags.first}"
        elsif undefined_flags.size > 1
          raise Admiral::Error.new "The following flags are not defined: #{undefined_flags.join(", ")}"
        end
        self
      end

      def inspect(io)
        io << "<#{self.class}"
        io << "("
        io << NAMES.join(", ") unless NAMES.empty?
        io << ")"
        io << ">"
      end
    end

    def flags
      @flags ||= Flags.new(self)
    end

    private def parse_flags!(validate = false)
      flags.tap do |f|
        f.validate!(self) if validate
      end
    end
  end

  # Defines a command line flag.
  #
  # **Note:** When defining flags, the underscore method name will translate to a hyphen
  # on the command line. This can be overridden with the `long: my_name` option when
  # defining the flag.
  #
  # ### Simple Flags
  # Simple flags are denoted only by a name and will compile to returning a `String | Nil`.
  #
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_flag planet
  #
  #   def run
  #     puts "Hello #{flags.planet || "World"}"
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # ```sh
  # $ crystal build ./hello_world.cr
  # $ ./hello_world
  # Hello World
  # $ ./hello_world --planet Alderaan
  # Hello Alderaan
  # ```
  #
  # ### Typed Flags
  # Flags can also be assigned a type. This will result in a properly typed value when
  # calling `flags.flag_name`. By default flags are not required and will return a
  # `Union` including the type and `Nil`.
  #
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_flag number_of_greetings : UInt32, default: 1_u32, long: times
  #
  #   def run
  #     flags.times.times do
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
  # $ ./hello_world  --times 3
  # Hello World
  # Hello World
  # Hello World
  # ```
  #
  # #### Built in flag types
  # The following classes are assignable as flags by default:
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
  # To make any `Class` or `Struct` assignable as a flag, define a `.new(value : ::Admiral::StringValue)` or
  # `#initialize(value : ::Admiral::StringValue)`.
  #
  # ### Enumerable Flags
  # Enumerable flags allow for multiple values to be passed on the command line. For
  # example with a defined flag with `Array(String)` would return an array of `String`
  # values when calling the flag.
  #
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_flag citizens : Array(String), long: citizen
  #
  #   def run
  #     flags.citizen.each do |citizen|
  #       puts "Hello #{citizen}, citizen of Earth!"
  #     end
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  #
  # ```sh
  # $ crystal build ./hello_world.cr
  # $ ./hello_world  --citizen Jim --citizen Harry
  # Hello Jim, citizen of Earth!
  # Hello Harry, citizen of Earth!
  # ```
  #
  # ### Additional Flag Options
  # ```crystal
  # # hello_world.cr
  # class HelloWorld < Admiral::Command
  #   define_flag number_of_greetings : UInt32,
  #     description: "The number of times to greet the world", # The description of the flag to be used in auto generated help.
  #     default: 1_u32,                                        # The default value of the flag.
  #     long: times,                                           # The long version of the flag ex: `long: times` for `--times`.
  #     short: t,                                              # The short version of the flag ex: `short: t` for `-t`.
  #     required: true                                         # Denotes if a flag is required. Required flags without a default value will raise an error when not specified at command invocation.
  #
  #   def run
  #     flags.number_of_greetings.times do
  #       puts "Hello World"
  #     end
  #   end
  # end
  #
  # HelloWorld.run
  # ```
  macro define_flag(flag, description = "", default = nil, short = nil, long = nil, required = false, default_in_desc = true)
    {% var = flag.is_a?(TypeDeclaration) ? flag.var : flag.id %}
    {% type = flag.is_a?(TypeDeclaration) ? flag.type : String %}

    {% raise "A flag with the name `#{var}` has already been defined!" if Flags::NAMES.includes? var.stringify %}
    {% Flags::NAMES << var.stringify %}

    # Setup Helper Vars
    {% is_bool = type.is_a?(Path) && type.resolve == Bool %}
    {% is_enum = type.is_a?(Generic) && type.name.resolve < Enumerable %}
    {% is_union = type.is_a?(Union) %}
    {% is_nil = type.is_a?(Path) && type == Nil %}

    # Cast defaults
    {% required = true if default != nil || is_bool %}
    {% default = default != nil ? default : is_bool ? false : is_enum ? "#{type}.new".id : nil %}
    {% long = (long || var.id.stringify.gsub(/_/, "-")).id.stringify.gsub(/^--/, "").id %}

    # Validate
    {% long_reg = /^[0-9A-Za-z][-0-9A-Za-z]*[0-9A-Za-z]?$/ %}
    {% unless long.id.stringify =~ long_reg %}
      {% raise "The long flag #{@type}(#{long}) must match the regex: #{long_reg}" %}
    {% end %}

    {% if short != nil && short.id.stringify.size > 1 %}
      {% raise "The short flag of #{@type}(#{long}) can only be a single character, you specified: `#{short}`" %}
    {% end %}

    # Make short and long into flag strings
    {% falsey = "--no-" + long.stringify %}
    {% long = "--" + long.stringify %}
    {% short = "-" + short.id.stringify.gsub(/^-/, "") if short != nil %}
    {% raise "The long flag: `#{long.id}` has already been defined!" if Flags::LONG_NAMES.includes? long.stringify %}
    {% raise "The short flag: `#{short.id}` has already been defined!" if Flags::SHORT_NAMES.includes? short.stringify %}
    {% Flags::LONG_NAMES << long.stringify %}
    {% Flags::SHORT_NAMES << short.stringify if short != nil %}

    # Validate types and set type var
    {% if is_union %}
      {% union_types = flag.type.types.reject { |t| t.is_a?(Path) && t.resolve == Nil } %}
      {% if union_types.size == 1 %}
        {% type = union_types.first %}
      {% else %}
        {% raise "The flag #{@type}(#{long}) specified a union type, this is not supported." %}
      {% end %}
    {% else %}
      {% type = type %}
    {% end %}

    # Extend the flags class to include the flag
    struct Flags
      @{{var}} : {{ type }} | Nil{% if default != nil %} = {{ default }}{% end %}

      def initialize(command : ::Admiral::Command)
        {% for f in Flags::NAMES %}
        @{{ f.id }} = parse_{{ f.id }}(command){% end %}
      end

      def {{var}} : {{ type }}{% unless required %}| Nil{% end %}
        val = @{{var}}
        {% if required %}raise ::Admiral::Error.new("Flag: {{ long.id }} is required") if val.nil?{% end %}
        val
      end

      private def parse_{{var}}(command : ::Admiral::Command) : {{ type }} | Nil
        values = ::Admiral::ArgumentList.new
        index = 0
        while arg = command.@argv[index]?
          flag = arg.split("=", 2)[0]
          if arg == "--" || SubCommands::NAMES.any? { |name| arg == name }
            break
          elsif flag == {{ long }}{% if short %} || flag.starts_with?({{short}}){% end %}
            del = command.@argv.delete_at index
            if value = arg.split("=", 2)[1]?
              values << ::Admiral::StringValue.new(value)
            {% if is_bool %}
              else
                values << ::Admiral::StringValue.new("true")
            {% else %}
              elsif command.@argv[index]?
                value = command.@argv.delete_at index
                values << value
              else
                raise ::Admiral::Error.new("Flag: {{ long.id }} is missing a value")
            {% end %}
            end
          {% if is_bool && default == true %}
            elsif flag == {{falsey}}
              del = command.@argv.delete_at index
              if value = arg.split("=")[1]?
                values << ::Admiral::StringValue.new((!Bool.new(::Admiral::StringValue.new(value))).to_s)
              else
                values << ::Admiral::StringValue.new("false")
              end
          {% end %}
          else
            index += 1
          end
        end

        {% if is_enum %} # Enum Type Flag
          values.empty? ? {{ default }} : {{ type }}.new(values)
        {% else %} # Boolean and value type flags
          values[-1]? != nil ? {{ type }}.new(values[-1]) : {% unless default.nil? %}{{ default }}{% else %}nil{% end %}
        {% end %}
      end
    end

    # Add the flag to the description constant
    Flags::DESCRIPTIONS[{{ long + (short ? ", #{short.id}" : "") }}{% if (default != nil) %} + ({{default_in_desc}} ? " (default: #{{{default}}})" : "") {% elsif required == true %}+ " (required)"{% end %}] = {{ description }}
  end
end
