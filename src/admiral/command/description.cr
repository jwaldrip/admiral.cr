abstract class Admiral::Command
  private macro description(string)
    def description : String
      {{ string }}
    end
  end
end
