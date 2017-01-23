abstract class Admiral::Command
  private macro argument(attr, description = "", default = nil, required = false)
    {% ARGS << attr.var.stringify %}

    private struct Arguments
      getter {{ attr.var }} : {{ attr.type }}

      def initialize(command : ::Admiral::Command)
        {% for a in ARGS %}
        @{{ a.id }} = parse_{{ a.id }}(command){% end %}
        @rest = parse_rest(command)
      end

      def parse_{{ attr.var }}(command : ::Admiral::Command) : {{ attr.type }}
        pos_only = false
        index = {{ ARGS.size - 1 }}
        while command.@argv[index]?.to_s.starts_with?("-") && !pos_only
          index += 1
          pos_only = command.@argv[index]? == "--"
        end
        value = if command.@argv[index]?
                  command.@argv.delete_at index
                else
                  {% if required %}raise "Missing required attribute: <{{attr.var}}>"{% else %}return nil{% end %}
                end
        {{ attr.type }}.new(value)
      end
    end

    # Add the attr to the description constant
    DESCS[:args][{{ attr.var.stringify }}] = {{ description }}
  end
end
