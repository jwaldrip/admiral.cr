abstract class Admiral::Command
  private macro argument(attr, description = "", default = nil, required = false)
    {% var = attr.is_a?(TypeDeclaration) ? attr.var : attr.id %}
    {% type = attr.is_a?(TypeDeclaration) ? attr.type : String %}
    {% ARGS << var.stringify %}

    private struct Arguments
      getter {{ var }} : {{ type }}

      def initialize(command : ::Admiral::Command)
        {% for a in ARGS %}
        @{{ a.id }} = parse_{{ a.id }}(command){% end %}
        @rest = parse_rest(command)
      end

      def parse_{{ var }}(command : ::Admiral::Command) : {{ type }}
        pos_only = false
        index = {{ ARGS.size - 1 }}
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

      # Test the usage of the flag
      begin
        new([] of String).arguments.{{ var }}
      rescue
        ::Admiral::Command::Error
      end
    end

    # Add the attr to the description constant
    DESCS[:args][{{ var.stringify }}] = {{ description }}
  end
end
