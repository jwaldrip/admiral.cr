abstract class Admiral::Command
  macro rescue_from(klass, method)
    private def run_with_rescue(&block)
      previous_def do
        begin
          yield
        rescue e : {{ klass }}
          {{ method }}(e)
        end
      end
    end
  end

  macro rescue_from(klass, &block)
    {% method = "__rescue_from_#{klass}".gsub(/:/, "_").id %}
    def {{ method }}({% for arg, index in block.args %}{% if index > 0 %},{% end %}{{ arg }}{% end %})
      {{ block.body }}
    end

    rescue_from({{ klass }}, {{ method }})
  end

  macro inherited
    private def run_with_rescue(&block)
      yield
    end
  end
end
