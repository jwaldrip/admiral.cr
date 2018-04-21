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

  protected def puts_version : Nil
  end
  
  macro define_version(string, flag = version, short = nil)
    {% if flag %}
      define_flag __version__ : Bool, long: {{flag}}, short: {{short}}, description: "Displays the version of the current application."

      protected def puts_version : Nil
        if flags.__version__
          puts version
          exit
        end
      end
    {% end %}

    def version
      {{string}}
    end
  end
end
