require "colorize"

abstract class Admiral::Command
  # Returns the commands `Flags` object.
  #
  # You can access names flags by name.
  abstract def flags

  private macro inherited
    struct Flags
      SPECS = {} of String => NamedTuple(
        type: String,
        default: String,
        description: Tuple(String, String),
        short: String?,
        long: String,
        is_required: Bool
      )
      DESCRIPTIONS = {} of String => String

      macro finished
        def initialize(command : ::Admiral::Command)
          \{% for var, spec in SPECS %}
            @\{{var.id}} = value_from_spec(
              command,
              type: \{{ spec[:type].id }},
              default: \{{ spec[:default].id }},
              short: \{{ spec[:short] }},
              long: \{{ spec[:long] }}
            ) \{% spec[:is_required] %}
          \{% end %}
        end

        def validate!(command)
          \{% for var, spec in SPECS %}
            raise Admiral::Error.new("Flag required: --\{{spec[:long].id}}") if \{{spec}}[:is_required] && @\{{var.id}}.nil?
          \{% end %}
          raise_extra_flags!(command)
        end
      end

      private def value_from_spec(command : ::Admiral::Command, *, type : Enumerable.class, default, short : String, long : String)
        values = values_from_spec(command, type: type, default: default, short: short, long: long)
        values.empty? ? default : type.new(values)
      end

      private def value_from_spec(command : ::Admiral::Command, *, type, default, short : String, long : String)
        values = values_from_spec(command, type: type, default: default, short: short, long: long)
        values[-1]? != nil ? type.new(values[-1]) : default
      end

      private def values_from_spec(command : ::Admiral::Command, *, type : Bool.class, default, short : String, long : String)
        falsey_flag = "--no-#{long}"
        long_flag = "--#{long}"
        short_flag = "-#{short}" unless short.empty?
        values = ::Admiral::ArgumentList.new
        index = 0
        while arg = command.@argv[index]?
          flag = arg.split("=", 2)[0]
          if arg == "--" || SubCommands::NAMES.any? { |name| arg == name }
            break
          elsif flag == long_flag || flag == short_flag
            command.@argv.delete_at index
            values << ::Admiral::StringValue.new("true")
          elsif default == true && flag == falsey_flag
            del = command.@argv.delete_at index
            if value = arg.split("=")[1]?
              values << ::Admiral::StringValue.new((!Bool.new(::Admiral::StringValue.new(value))).to_s)
            else
              values << ::Admiral::StringValue.new("false")
            end
          else
            index += 1
          end
        end
        return values
      end

      private def values_from_spec(command : ::Admiral::Command, *, type, default, short : String, long : String)
        long_flag = "--#{long}"
        short_flag = "-#{short}" unless short.empty?
        values = ::Admiral::ArgumentList.new
        index = 0
        while arg = command.@argv[index]?
          flag = arg.split("=", 2)[0]
          if arg == "--" || SubCommands::NAMES.any? { |name| arg == name }
            break
          elsif flag == long_flag || flag == short_flag
            del = command.@argv.delete_at index
            if value = arg.split("=", 2)[1]?
              values << ::Admiral::StringValue.new(value)
            elsif command.@argv[index]?
              value = command.@argv.delete_at index
              values << value
            else
              raise ::Admiral::Error.new("Flag: #{flag == long_flag ? long_flag : short_flag} is missing a value")
            end
          else
            index += 1
          end
        end
        return values
      end

      private def raise_extra_flags!(command)
        last_index = (command.@argv.index(&.== "--") || 0) - 1
        return self if last_index < 0
        undefined_flags = [] of String
        command.@argv[0..last_index].each do |arg|
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
        io << SPECS.keys.join(", ") unless SPECS.empty?
        io << ")"
        io << ">"
      end
    end

    def flags
      @flags ||= Flags.new(self)
    end

    private def validate_flags!
      flags.validate!(self)
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
  macro define_flag(flag, description = "", default = nil, short = nil, long = nil, required = false)
    {%
      # Convert type and var
      var = flag.is_a?(TypeDeclaration) ? flag.var : flag.id
      type = flag.is_a?(TypeDeclaration) ? flag.type : String

      # Setup Helper Vars
      is_bool = type.is_a?(Path) && type.resolve == Bool
      is_enum = type.is_a?(Generic) && type.name.resolve < Enumerable
      is_nil = type.is_a?(Path) && type == Nil

      # Cast defaults
      required = true if default != nil || is_bool
      default = default != nil ? default : is_bool ? false : is_enum ? "#{type}.new".id : nil
      long = (long || var.id.stringify.gsub(/_/, "-")).id.stringify.gsub(/^--/, "").id

      # Validate Flag Formats
      unless long.id.stringify =~ /^[0-9A-Za-z][-0-9A-Za-z]*[0-9A-Za-z]?$/
        raise "The long flag #{@type}(#{long}) must match the regex: #{long_reg}"
      end

      unless short == nil || short.id.stringify =~ /^[0-9A-Za-z][-0-9A-Za-z]?$/
        raise "The short flag of #{@type}(#{long}) can only be a single character, you specified: `#{short}`"
      end

      # Set spec
      Flags::SPECS[var.id.stringify] = {
        type: type.id.stringify,
        default: default.stringify,
        description: {
          "--#{long.id}" + (short ? ", -#{short.id}" : "") + (default != nil && !is_bool ? " (default: #{default})" : default == nil && required == true ? " (required)": ""),
          description
        },
        short: short.id.stringify,
        long: long.id.stringify,
        is_required: required
      }
    %}

    # Extend the flags struct to include the flag
    struct Flags
      getter {{var}} : {{ type }} | Nil{% if default != nil %} = {{ default }}{% end %}
    end
  end
end
