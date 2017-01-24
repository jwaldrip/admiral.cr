abstract class Admiral::Command
  private macro sub_command(command, description = "")
    {% raise "Subcommand: `#{command.var}` must have a type declared" unless command.is_a? TypeDeclaration %}
    {% raise "Subcommand: `#{command.var}` type must inherit from Admiral::Command" unless command.type.resolve < ::Admiral::Command %}
    {% SUB_COMMAND_NAMES << command.var.stringify unless SUB_COMMAND_NAMES.includes? command.var.stringify %}

    # Add the subcommand to the description constant
    {% DESCRIPTIONS[:sub_commands][command.var.stringify] = description.stringify %}

    private struct SubCommands
      def locate
        previous_def || @name == {{ command.var.stringify }} ? {{ command.type }} : nil
      end
    end
  end
end
