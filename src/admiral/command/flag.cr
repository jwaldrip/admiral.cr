abstract class Admiral::Command
  private macro flag(flag, description = "", default = nil, short = nil, long = nil, required = false)
    {% var = flag.is_a?(TypeDeclaration) ? flag.var : flag.id %}
    {% type = flag.is_a?(TypeDeclaration) ? flag.type : String %}
    {% Flags::NAMES << var.stringify unless Flags::NAMES.includes? var.stringify %}

    # Setup Helper Vars
    {% is_bool  = type.is_a?(Path) && type.resolve == Bool %}
    {% is_enum  = type.is_a?(Generic) && type.name.resolve < Enumerable %}
    {% is_union = type.is_a?(Union) %}
    {% is_nil   = type.is_a?(Path) && type == Nil %}

    # Cast defaults
    {% default = default != nil ? default : is_bool ? false : is_enum ? "#{type}.new".id : nil %}
    {% long = long || var %}

    # Validate
    {% if short != nil && short.id.stringify.size > 1 %}
      {% raise "The short flag of #{@type}(#{long}) can only be a single character, you specified: `#{short}`" %}
    {% end %}

    # Make short and long into flag strings
    {% falsey = "--no-" + long.stringify %}
    {% long = "--" + long.stringify %}
    {% short = "-" + short.stringify if short != nil %}

    # Validate types and set type var
    {% if is_union %}
      {% union_types = flag.type.types.reject { |t| t.is_a?(Path) && t.resolve == Nil } %}
      {% if union_types.size == 1 %}
        {% type = union_types.first }
      {% else %}
        {% raise "The flag #{@type}(#{long}) specified a union type, this is not supported." %}
      {% end %}
    {% else %}
      {% type = type %}
    {% end %}

    # Extend the flags class to include the flag
    private struct Flags
      getter {{ var }} : {{ type }}{% unless required %}| Nil{% end %}{% if default != nil %} = {{ default }}{% end %}

      def initialize(command : ::Admiral::Command)
        {% for f in Flags::NAMES %}
        @{{ f.id }} = parse_{{ f.id }}(command){% end %}
        raise_on_undefined_flags!(command)
      end

      private def parse_{{var}}(command : ::Admiral::Command) : {{ type }} {% unless required %}| Nil{% end %}
        values = ::Admiral::ARGV.new
        index = 0
        while arg = command.@argv[index]?
          flag = arg.split("=")[0]
          if arg == "--" || SubCommands::NAMES.any? { |name| arg == name }
            break
          elsif flag == {{ long }}{% if short %} || flag == {{short}}{% end %}
            del = command.@argv.delete_at index
            if value = arg.split("=")[1]?
              values << ::Admiral::StringValue.new(value)
            {% if is_bool %}
              else
                values << ::Admiral::StringValue.new("true")
            {% else %}
              elsif command.@argv[index]?
                value = command.@argv.delete_at index
                values << value
              else
                raise ::Admiral::Command::Error.new("Flag: {{ long.id }} is missing a value")
            {% end %}
            end
          {% if is_bool && default == true %}
            elsif flag == {{falsey}}
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
          values[-1]? != nil ? {{ type }}.new(values[-1]) : {% if required == true %}raise ::Admiral::Command::Error.new("Flag: {{ long.id }} is required"){% else %}{{ default }}{% end %}
        {% end %}
      end
    end

    # Add the flag to the description constant
    {% Flags::DESCRIPTIONS["#{long}#{", " + short.stringify if short}#{"=" + default.stringify if default != nil}"] = description %}

    # Test the usage of the flag
    begin
      new([] of String).flags.{{var}}
    rescue
      ::Admiral::Command::Error
    end
  end
end
