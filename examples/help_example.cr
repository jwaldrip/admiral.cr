require "../src/admiral"

class Help < Admiral::Command
  define_help description: "A command that helps you", short: 'h'
  define_flag why, default: "42..."
  define_flag print_why : Bool, default: false, default_in_desc: false, description: "Prints why"

  def run
    unless flags.__help__
      puts "You didn't specify '--help'"
    end

    if flags.print_why
      print "Why?: ", flags.why, '\n'
    end
  end

  def exit(*args); end
end

puts "help --help"
Help.run "--help"

puts "help --print-why" 
Help.run "--print-why"
