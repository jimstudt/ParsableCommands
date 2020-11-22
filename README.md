# ParsableCommands

The ParsableCommands protocol expands on [Swift Argument Parser] to handle many 
commands, which are not structured as subcommands of a main command.

It is MIT licensed.

## Why Would I Use This?

If you are providing a "command line" like experience where you want to select between
many `ParsableCommand` choices based on the first argument, then this is your friend.

You could probably structure your program to put them all as subcommands of a master
command and then hide the master command from the user, but the various help and 
diagnostic messages tend to bleed that out to the user.

## How Big Is This Thing?

It's tiny. It's a one-pager. Plus a second one-pager to tokenize command lines in a shell like manner which you might or might not want to use.

## What Does It Look Like?

```swift
import ParsableCommands

// Define your individual ParsableCommand types up here

// Make our type collecting all of the commands
struct MyCommands : ParsableCommands {
    static var commands : [ParsableCommand.Type] = [ SomeCommand.self, SomeOtherCommand.self ] // ...
}

// Read lines from stdin and send them out to the commands.
while let line = readLine(prompt: "$ ", strippingNewline: true) {
    do {
        try MyCommands.parse( line).run()
    } catch ParserErrors.noCommand {
        // it's ok, just a blank line or something got in.
    } catch {
        print("\(MyCommands.fullMessage(for: error))")
    }
}
```

There is an [example program](https://github.com/jimstudt/ParsableCommands/blob/main/Sources/Example/main.swift) 
which is a little more complicated because I'm also showing how to extend ArgumentParser to pass contexts into the 
commands, which is important if you have a server that accepts lots of connections and lets them run commands.
If you are just a simple program reading commands you can ignore everything in the example that talks about `context`.

## Where Does It Go From Here?

This does everything I need, so it feels done. I'm sure someone else has other needs that I'm ignoring, make an issue 
or a pull request and we can round this thing out.

I'll probably restructure this into a pull request on ArgumentParser and see if I can get them to absorb or reinvent the 
functionality. Until such time, here it is.

The command tokenizer is really independent, but I weep a little whenever I see code doing `line.split(…` and calling
that command parsing. It's not much code, just copy it out into your project if you need it on its own. I'm not going to
make a micro-repository for it.

