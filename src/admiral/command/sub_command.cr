abstract class Admiral::Command
  private macro sub_command(command, description = "")
    # Add the subcommand to the description constant
    DESCS[:subcm][{{ command.var.stringify }}] = {{ description }}
  end
end
