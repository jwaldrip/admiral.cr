# Admiral.cr
[![Build Status](https://travis-ci.org/jwaldrip/admiral.cr.svg?branch=master)](https://travis-ci.org/jwaldrip/admiral.cr)
[![GitHub release](https://img.shields.io/github/tag/jwaldrip/admiral.cr.svg)](https://github.com/jwaldrip/promise.cr/releases)
[![Crystal Docs](https://img.shields.io/badge/Crystal-Docs-8A2BE2.svg)](https://jwaldrip.github.com/admiral.cr)

A robust command line DSL for terminal applications written in [Crystal](https://crystal-lang.org).

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
  run
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

> NOTE: When defining flags, the underscore method name will translate to a hyphen
  on the command line. This can be overridden with the `long: my_name` option when
  defining the flag.

### Simple
Simple flags are denoted only by a name and will compile to returning a `String | Nil`.

```crystal
class HelloWorld < Admiral::Command
  define_flag planet

  run
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
class HelloWorld < Admiral::Command
  define_flag times : UInt32, default: 1_u32

  run
    flag.times.times do
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
class HelloWorld < Admiral::Command
  define_flag citizens : Array(String), long: citizen

  run
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
class HelloWorld < Admiral::Command
  define_flag number_of_greetings : UInt32,
              description: "The number of times to greet the world",
              default: 1_u32,
              long: times,
              short: t,
              required: true

  run
    flag.number_of_greetings.times do
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
`long`           | The long version of the flag ex: `long: times` for `--times`
`short`          | The short version of the flag ex: `short: t` for `-t`
`required`       | Denotes if a flag is required. Required flags without a default value will raise an error when not specified at command invocation.

## Arguments

## Sub Commands

## Command Help

### Auto-generated Help

### Custom Help

## Command Version

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
- [ ] Fully Tested
- [ ] Bash Completion
- [ ] Zsh Completion

## Contributing

See [CONTRIBUTING](https://github.com/jwaldrip/admiral.cr/blob/master/CONTRIBUTING.md) for details on how to contribute.
