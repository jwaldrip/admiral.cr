require "../src/admiral"

class Complex < Admiral::Command
  class Sub < Admiral::Command
    def run
      parent_flags = parent.flags
      if parent_flags.is_a? Complex::Flags
        puts parent_flags.required_default
      end
    end
  end

  define_version "1.0.0"

  define_help description: "a complex command"

  define_flag simple
  define_flag typed_int : Int32
  define_flag typed_bool : Bool
  define_flag enum : Array(String)
  define_flag required : String, required: true
  define_flag required_default : String, required: true, default: "default value"
  define_flag with_description : String, description: "a described flag"
  define_flag with_short : String, short: f
  define_flag with_long : String, long: "with-long"

  define_argument required : Int32, required: true
  define_argument simple
  define_argument typed : Int32

  register_sub_command sub, Sub, description: "a sub command"

  def run
    puts flags.required_default
  end
end

Complex.run "--required foo 1 bar 2"
Complex.run "--required foo 1 bar 2 sub 1"
