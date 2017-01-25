abstract class Admiral::Command
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
