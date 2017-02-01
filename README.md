# Admiral.cr
[![Build Status](https://travis-ci.org/jwaldrip/admiral.cr.svg?branch=master)](https://travis-ci.org/jwaldrip/admiral.cr)
[![Crystal Docs](https://img.shields.io/badge/Crystal-Docs-8A2BE2.svg)](https://jwaldrip.github.com/admiral.cr)

A robust DSL for writing command line interfaces written in [Crystal](https://crystal-lang.org).

---

> [Installation](#installation) |
  [Usage](#usage) |
  [Examples](https://github.com/jwaldrip/admiral.cr/tree/master/examples) | [Contributing](https://github.com/jwaldrip/admiral.cr/blob/master/CONTRIBUTING.md) |
  [In the Wild](#in-the-wild)

## Installation

Add the following to your application's `shard.yml` file.

```yml
dependencies:
  admiral:
    github: jwaldrip/admiral.cr
```

## Usage

> [Creating a new CLI](#creating-a-new-cli) |
  [Flags](#flags) |
  [Arguments](#arguments) |
  [Sub Commands](#sub-commands) |
  [Command Help](#command-help) |
  [Command Version](#command-version)

## Creating a new CLI

You can define a CLI by creating a new class that inherits from `Admiral::Command`.
All your class needs to implement is a run method. Inside the run method will be
the logic of your cli application. The following is a very basic CLI. You can
run the command by invoking `HelloWorld.run`. By default this method will use
`ARGV`, but you can also pass `Array(String)` or `String`.

```crystal
# hello_world.cr
require "admiral"

class HelloWorld < Admiral::Command
  def run
    puts "Hello World"
  end
end

HelloWorld.run
```

```sh
$ crystal run ./hello_world.cr
Hello World
```

## Flags
Flags can be added to the command. To define a flag use the `define_flag` macro.

> **Note:** When defining flags, the underscore method name will translate to a hyphen
  on the command line. This can be overridden with the `long: my_name` option when
  defining the flag.

### Simple Flags
Simple flags are denoted only by a name and will compile to returning a `String | Nil`.

```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_flag planet

  def run
    puts "Hello #{flags.planet || "World"}"
  end
end

HelloWorld.run
```

```sh
$ crystal build ./hello_world.cr
$ ./hello_world
Hello World
$ ./hello_world --planet Alderaan
Hello Alderaan
```

### Typed Flags
Flags can also be assigned a type. This will result in a properly typed value when
calling `flags.flag_name`. By default flags are not required and will return a
`Union` including the type and `Nil`.

```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_flag number_of_greetings : UInt32, default: 1_u32, long: times

  def run
    flags.times.times do
      puts "Hello World"
    end
  end
end

HelloWorld.run
```

```sh
$ crystal build ./hello_world.cr
$ ./hello_world  --times 3
Hello World
Hello World
Hello World
```

#### Built in flag types
The following classes are assignable as flags by default:
* `String`
* `Bool`
* `Float32`
* `Float64`
* `Int8`
* `Int16`
* `Int32`
* `Int64`
* `UInt8`
* `UInt16`
* `UInt32`
* `UInt64`

> **Pro Tip**  
  To make any `Class` or `Struct` assignable as a flag, define a `.new(value : ::Admiral::StringValue)` or  
  `#initialize(value : ::Admiral::StringValue)`.

### Enumerable Flags
Enumerable flags allow for multiple values to be passed on the command line. For
example with a defined flag with `Array(String)` would return an array of `String`
values when calling the flag.

```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_flag citizens : Array(String), long: citizen

  def run
    flags.citizen.each do |citizen|
      puts "Hello #{citizen}, citizen of Earth!"
    end
  end
end

HelloWorld.run
```

```sh
$ crystal build ./hello_world.cr
$ ./hello_world  --citizen Jim --citizen Harry
Hello Jim, citizen of Earth!
Hello Harry, citizen of Earth!
```

### Additional Flag Options
```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_flag number_of_greetings : UInt32,
              description: "The number of times to greet the world",
              default: 1_u32,
              long: times,
              short: t,
              required: true

  def run
    flags.number_of_greetings.times do
      puts "Hello World"
    end
  end
end

HelloWorld.run
```

Option           | Description
              ---|---
`description`    | The description of the flag to be used in auto generated help.
`default`        | The default value of the flag.
`long`           | The long version of the flag ex: `long: times` for `--times`.
`short`          | The short version of the flag ex: `short: t` for `-t`.
`required`       | Denotes if a flag is required. Required flags without a default value will raise an error when not specified at command invocation.

## Arguments
Arguments can be added to the command. To define a argument use the `define_argument` macro.

### Simple Arguments
Simple arguments are denoted only by a name and will compile to returning a `String | Nil`.

```crystal
# hello.cr
class Hello < Admiral::Command
  define_argument planet

  def run
    puts "Hello #{arguments.planet || "World"}"
  end
end

HelloWorld.run
```

```sh
$ crystal build ./world.cr
$ ./hello
Hello World
$ ./hello Alderaan
Hello Alderaan
```

### Typed Arguments
Arguments can also be assigned a type. This will result in a properly typed value when
calling `arguments.arg_name`. By default arguments are not required and will return a
`Union` including the type and `Nil`.

```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_argument number_of_greetings : UInt32, default: 1_u32

  def run
    arguments.number_of_greetings.times do
      puts "Hello World"
    end
  end
end

HelloWorld.run
```

```sh
$ crystal build ./hello_world.cr
$ ./hello_world  3
Hello World
Hello World
Hello World
```

#### Built in argument types
The following classes are assignable as arguments by default:
* `String`
* `Bool`
* `Float32`
* `Float64`
* `Int8`
* `Int16`
* `Int32`
* `Int64`
* `UInt8`
* `UInt16`
* `UInt32`
* `UInt64`

> **Pro Tip**  
  To make any `Class` or `Struct` assignable as a argument, define a `.new(value : ::Admiral::StringValue)` or  
  `#initialize(value : ::Admiral::StringValue)`.

### Additional Argument Options
```crystal
# hello_world.cr
class HelloWorld < Admiral::Command
  define_argument number_of_greetings : UInt32,
                  description: "The number of times to greet the world",
                  default: 1_u32,
                  required: true

  def run
    arguments.number_of_greetings.times do
      puts "Hello World"
    end
  end
end

HelloWorld.run
```

Option           | Description
              ---|---
`description`    | The description of the argument to be used in auto generated help.
`default`        | The default value of the argument.
`required`       | Denotes if a argument is required. Required arguments without a default value will raise an error when not specified at command invocation.

> **Note:**  
  Required arguments cannot be defined after optional arguments.

## Sub Commands
Sub commands can be added to the command. To define a sub command use the
`register_subcommand` macro. You also have the option to add a description for
the auto-generated help.

```crystal
# hello.cr
class Hello < Admiral::Command
  class Planetary < Admiral::Command
    def run
      puts "Hello World"
    end
  end

  class Municipality < Admiral::Command
    def run
      puts "Hello Denver"
    end
  end

  register_subcommand planet, Planetary
  register_subcommand city, Municipality

  def run
    puts help
  end
end

HelloWorld.run
```

```sh
$ crystal build ./hello.cr
$ ./hello planet
Hello World
$ ./hello city
Hello Denver
```

## Command Help

### Auto-generated Help

You can add a help command to your CLI by using the `define_help` macro.
`define_help` also takes a description argument to give additional information
about your command.

```crystal
# hello.cr
class Hello < Admiral::Command
  define_help description: "A command that says hello"
  define_argument planet, default: "World"

  def run
    puts "Hello #{arguments.planet}"
  end
end
```

```sh
$ crystal build ./hello.cr
$ ./hello --help
Usage:
  ./hello [flags...] <planet> [arg...]

A command that says hello

Flags:
  --help (default: false)

Arguments:
  planet (default: World)
```

### Custom Help
You can also generate your own custom help text.

```crystal
# hello.cr
class Hello < Admiral::Command
  define_help custom: "This is the help for my command"

  def run
  end
end
```

## Command Version
Like most CLI applications, you can set a version flag.

```crystal
# hello.cr
class Hello < Admiral::Command
  define_version "1.0.0"

  def run
  end
end
```

```sh
$ crystal build ./hello.cr
$ hello --version
1.0.0
```

## Examples

*Example CLIs can be found in [./examples](https://github.com/jwaldrip/admiral.cr/tree/master/examples)*

## In the wild

Here are some tools using Admiral.cr in the wild. Have your own you would like to plug? Submit a pull request!

* [commercialtribe/psykube](https://github.com/commercialtribe/psykube)

## Todo

- [x] Basic Flags
- [x] Typed Flags
- [x] Boolean Flags
- [x] Enum Flags
- [x] Named Arguments
- [x] Positional Arguments
- [x] Sub Commands
- [x] Documentation
- [ ] Fully Tested
- [ ] Bash Completion
- [ ] Zsh Completion

## Contributing

See [CONTRIBUTING](https://github.com/jwaldrip/admiral.cr/blob/master/CONTRIBUTING.md) for details on how to contribute.
