require "../src/admiral"

class Complex < Admiral::Command
  class Sub < Admiral::Command
    def run
    end
  end

  define_version "1.0.0"

  define_help description: "a complex command"

  define_flag simple
  define_flag typed_int : Int32
  define_flag typed_bool : Bool
  define_flag enum : Array(String)
  define_flag required : String, required: true
  define_flag require_default : String, required: true, default: "default value"

  define_argument required : Int32
  define_argument simple
  define_argument typed : Int32

  define_sub_command sub : Sub, description: "a sub command"

  def run
  end
end

Complex.run "--required foo 1 bar 2"
Complex.run "--required sub"
