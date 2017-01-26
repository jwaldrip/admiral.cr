abstract class Admiral::Command
  # Defines a version for the command.
  #
  # ```crystal
  # # hello.cr
  # class Hello < Admiral::Command
  #   define_version "1.0.0"
  #
  #   def run
  #   end
  # end
  # ```
  #
  # ```sh
  # $ crystal build ./hello.cr
  # $ hello --version
  # 1.0.0
  # ```
  macro define_version(string, flag = version, short = nil)
    {% if flag %}
      define_flag __version__ : Bool, long: {{flag}}, short: {{short}}
      protected def run! : Nil
        if flags.__version__
          puts version
          exit
        else
          previous_def
        end
      end
    {% end %}

    def version
      {{string}}
    end
  end
end
