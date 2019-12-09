require "../../src/admiral"

class EnumerableCommand < Admiral::Command
  define_flag services : Array(String),
			short: 's',
			long: "--services",
      required: true

  def run
    puts flags.services
  end

  def exit(*args)
  end
end
