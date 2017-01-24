abstract class Admiral::Command
  private macro argument(attr, description = "", default = nil, required = false)
    {% var = attr.is_a?(TypeDeclaration) ? attr.var : attr.id %}
    {% type = attr.is_a?(TypeDeclaration) ? attr.type : String %}
    {% ARGUMENT_NAMES << var.stringify unless ARGUMENT_NAMES.includes? var.stringify %}

    private struct Arguments
      getter {{ var }} : {{ type }}

      def initialize(command : ::Admiral::Command)
        {% for a in ARGUMENT_NAMES %}
        @{{ a.id }} = parse_{{ a.id }}(command){% end %}
        @__rest__ = parse_rest(command)
      end

      def parse_{{ var }}(command : ::Admiral::Command) : {{ type }}
        pos_only = false
        index = {{ ARGUMENT_NAMES.size - 1 }}
        while command.@argv[index]?.to_s.starts_with?("-") && !pos_only
          index += 1
          pos_only = command.@argv[index]? == "--"
        end
        value = if command.@argv[index]?
                  command.@argv.delete_at index
                else
                  {% if required %}raise "Missing required attribute: <{{var}}>"{% else %}return nil{% end %}
                end
        {{ type }}.new(value)
      end
    end

    # Test the usage of the flag
    begin
      new([] of String).arguments.{{ var }}
    rescue
      ::Admiral::Command::Error
    end

    # Add the attr to the description constant
    {% DESCRIPTIONS[:arguments][var.stringify] = description %}
  end
end
