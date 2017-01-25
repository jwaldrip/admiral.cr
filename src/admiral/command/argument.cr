abstract class Admiral::Command
  private macro inherited
    private struct Arguments
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

  macro define_argument(attr, description = "", default = nil, required = false)
    {% var = attr.is_a?(TypeDeclaration) ? attr.var : attr.id %}
    {% type = attr.is_a?(TypeDeclaration) ? attr.type : String %}
    {% raise "Cannot define required argument `#{var}` after optional arguments" if required && Arguments::NAMES != Arguments::REQUIRED_NAMES %}
    {% Arguments::NAMES << var.stringify unless Arguments::NAMES.includes? var.stringify %}
    {% Arguments::REQUIRED_NAMES << var.stringify if required == true && !Arguments::REQUIRED_NAMES.includes?(var.stringify) %}

    private struct Arguments
      getter {{ var }} : {{ type }}{% unless required %} | Nil{% end %}

      def initialize(command : ::Admiral::Command)
        {% for a in Arguments::NAMES %}
        @{{ a.id }} = parse_{{ a.id }}(command){% end %}
        @__rest__ = parse_rest(command)
      end

      def parse_{{ var }}(command : ::Admiral::Command) : {{ type }}{% unless required %} | Nil{% end %}
        pos_only = false
        index = {{ Arguments::NAMES.size - 1 }}
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
    Arguments::DESCRIPTIONS[{{ var.stringify }}] = {{ description }}
  end
end
