abstract class Admiral::Command
  macro define_help(custom, flag = help, short = nil)
    {% if flag %}
      define_flag __help__ : Bool, long: {{flag}}, short: {{short}}
      protected def run! : Nil
        if flags.__help__
          puts help
          exit
        else
          previous_def
        end
      end
    {% end %}

    def help
      {{custom}}
    end
  end

  # ## Auto-generated Help

  # Adds a help to the command.
  #
  # ```crystal
  # # hello.cr
  # class Hello < Admiral::Command
  #   define_help description: "A command that says hello"
  #   define_argument planet, default: "World"
  #
  #   def run
  #     puts "Hello #{arguments.planet}"
  #   end
  # end
  # ```
  #
  # ```sh
  # $ crystal build ./hello.cr
  # $ ./hello --help
  # Usage:
  #   ./hello [flags...] <planet> [arg...]
  #
  # A command that says hello
  #
  # Flags:
  #   --help (default: false)
  #
  # Arguments:
  #   planet (default: World)
  # ```
  #
  # ### Custom Help
  # You can also generate your own custom help text.
  #
  # ```crystal
  # # hello.cr
  # class Hello < Admiral::Command
  #   define_help custom: "This is the help for my command"
  #
  #   def run
  #   end
  # end
  # ```
  macro define_help(description = nil, flag = help, short = nil)
    {% if flag %}
      define_flag __help__ : Bool, long: {{flag}}, short: {{short}}
      protected def run! : Nil
        if flags.__help__
          puts help
          exit
        else
          previous_def
        end
      end
    {% end %}

    def help
      left_col_len = [Flags::DESCRIPTIONS, Arguments::DESCRIPTIONS, SubCommands::DESCRIPTIONS].flat_map(&.keys).map(&.size).sort[-1]? || 0
      String.build do |str|
        # Add Usage
        str << "Usage:"
        commands = [] of String
        commands << begin
          String.build do |cmd|
            Arguments::DESCRIPTIONS.keys.each do |attr|
              cmd << " <#{attr}>"
            end
            cmd << " [arg...]"
          end
        end
        commands << " {command}" unless SubCommands::NAMES.empty?
        commands.each do |cmd|
          str << "\n  #{@program_name}"
          str << " [flags...]" unless Flags::NAMES.empty?
          str << cmd unless cmd.empty?
        end
        str << "\n" # add newline

        {% if description %}
          # Add Description
          str << "\n{{description.id}}\n"
        {% end %}

        # Add Flags
        unless Flags::NAMES.empty?
          str << "\nFlags:\n"
          Flags::DESCRIPTIONS.each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Args
        unless Arguments::NAMES.empty?
          str << "\nArguments:\n"
          Arguments::DESCRIPTIONS.each do |string, desc|
            str << "  #{string}"
            if desc.size > 1
              str << " " * (left_col_len - string.size)
              str << "  # #{desc}"
            end
            str << "\n"
          end
        end

        # Add Commands
        unless SubCommands::NAMES.empty?
          str << "\nSubcommands:\n"
          SubCommands::DESCRIPTIONS.each do |string, desc|
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
  end
end
