abstract class Admiral::Command
  private macro strict!
    OPTIONS[:strict] = true
    private class Arguments
      def rest

      end
    end
  end
end
