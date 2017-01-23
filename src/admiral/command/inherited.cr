abstract class Admiral::Command
  private macro inherited
    FLAGS = [] of String
    ARGS = [] of String
    flag help : Bool
    private OPTIONS = { strict: false }
    private DESCS = {
      args: {} of String => String,
      flags: {} of String => String,
      subcm: {} of String => String,
    }
    private struct Flags
      def initialize(command : ::Admiral::Command)
        raise_on_undefined_flags!(command)
      end

      def raise_on_undefined_flags!(command)
        pos_index = (command.@argv.index(&.== "--") || 0) - 1
        undefined_flags = command.@argv[0..pos_index].select(&.starts_with? "--")
        if undefined_flags.size == 1
          raise Admiral::Command::Error.new "The following flag is not defined: #{undefined_flags.first}"
        elsif undefined_flags.size > 1
          raise Admiral::Command::Error.new "The following flags are not defined: #{undefined_flags.join(", ")}"
        end
      end
    end

    private struct Arguments
      getter rest : Array(String) = [] of String

      def initialize(command : ::Admiral::Command)
        @rest = parse_rest(command)
      end

      private def parse_rest(command : ::Admiral::Command)
        command.@argv.select(&.!= "--").map(&.value)
      end
    end

    def flags
      @flags ||= Flags.new(self)
    end

    def arguments
      @arguments ||= Arguments.new(self)
    end

    def help
      left_col_len = DESCS[:args].merge(DESCS[:subcm].merge(DESCS[:flags])).keys.map(&.size).sort[-1]? || 0
      String.build do |str|
        # Add Usage
        str << "Usage:"
        commands = [] of String
        commands << begin
          String.build do |cmd|
            DESCS[:args].keys.each do |attr|
              cmd << " <#{attr}>"
            end
            cmd << " [arg...]" unless OPTIONS[:strict]
          end
        end
        commands << " {command}" unless DESCS[:subcm].empty?
        commands.each do |cmd|
          str << "\n  #{@program_name}"
          str << " [flags...]" unless DESCS[:flags].empty?
          str << cmd unless cmd.empty?
        end
        str << "\n\n" # add newlines

        # Add Description
        str << "#{description}\n" if description

        # Add Flags
        unless DESCS[:flags].empty?
          str << "\nFlags:\n"
          DESCS[:flags].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Args
        unless DESCS[:args].empty?
          str << "\nArguments:\n"
          DESCS[:args].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Commands
        unless DESCS[:subcm].empty?
          str << "\nCommands:\n"
          DESCS[:subcm].each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end
      end
    end

    def description : Nil
    end
  end
end
