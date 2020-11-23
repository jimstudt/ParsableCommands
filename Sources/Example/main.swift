//
//  Example/main.swift
//  
//  Wherein I demonstrate the use of ParsableCommands, but with
//  the added complexity of commands which require context. It
//  makes sense since I use this package in a server that takes
//  SSH connections and you need to know where to send your
//  output.
//
//  But if you ignore anything that says "context", and the
//  `ConsoleCommand` type, and the bit where I scrutinize the
//  type of the parsed command to decide what sort of context to
//  pass, then you have the simple version.
//
//  Created by Jim Studt on 11/22/20.
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import ParsableCommands
import ArgumentParser

/// A command to echo its arguments, one per line, with little markers
/// so you can see if it has spaces around it.
struct Echo: ConsoleCommand {
    @Argument var arguments: [String]

    static var configuration
        = CommandConfiguration(abstract: "Echo my arguments.")

    mutating func run( context:ConsoleContext) {
        for (n,v) in arguments.enumerated() {
            context.write("\(n): «\(v)»\n")
        }
    }
}

/// A command to tell us to stop. Making use of the `context` for this.
struct Exit: ConsoleCommand {
    static var configuration
        = CommandConfiguration(abstract: "Exit the program.")

    mutating func run( context:ConsoleContext) {
        context.done = true
    }
}

/// A command with a long enough abstract to force it to wrap for testing.
struct Elucidate: ConsoleCommand {
    static var configuration
        = CommandConfiguration(abstract: "Explain a topic in great detail and possibly at great length.")

    mutating func run( context:ConsoleContext) {
        context.write("Nah, I'm good.\n")
    }
}


/// A command to get help for either a specific command, or to list the
/// available commands.
struct Help: ConsoleCommand {
    @Argument var command: String?
    
    static var configuration
        = CommandConfiguration(abstract: "Get some help.")

    mutating func run( context:ConsoleContext) {
        if let cmdName = command {
            if let cmd = ConsoleCommands[cmdName] {
                context.write( cmd.helpMessage(columns: 40))
            } else {
                context.write("No such command: \(cmdName)\n")
            }
        } else {
            context.write( ConsoleCommands.helpMessage(columns: 40) )
        }
    }
}

/// Here we gather up all of our commands. You will need one of these.
struct ConsoleCommands : ParsableCommands {
    static var commands : [ParsableCommand.Type] = [ Echo.self, Exit.self, Help.self, Elucidate.self ]
}

/// A special kind of ParsableCommand which needs a `ConsoleContext` to run.
/// We need to have a function to absorb our output, and that is in the context.
///
/// Ignore this if you don't need a context, just make your commands be
/// `ParsableCommand` instead.
protocol ConsoleCommand : ParsableCommand {
    mutating func run( context:ConsoleContext) throws
}

/// A context to hold our `write` function so we know where to send our output.
/// Also a flag to say when we are done.
///
/// Ignore this if you aren't interesting in passing context to commands.
class ConsoleContext {
    var write : (String)->Void
    var done : Bool = false

    internal init(write: @escaping (String) -> Void) {
        self.write = write
    }
}

/// Read a line from standard input, with a prompt.
///
/// What are we? Barbarians? User's deserve a prompt and it spoiled
/// the look of my `while` loop to do it in the main part of the example.
///
/// - Parameters:
///   - prompt: The prompt to display before reading input.
///   - strippingNewline: take off the newline
/// - Returns: A line of text from standard input
func readLine(prompt:String, strippingNewline: Bool = true) -> String? {
    print(prompt, terminator: "")
    return readLine(strippingNewline: strippingNewline)
}

/// Our context shared among all commands. You could also make a new context for each
/// command, which I do when I drive this from an SSH command listener.
///
/// You can ignore this if you aren't interesting in passing context to commands.
let context = ConsoleContext(write: { (s:String)->Void in print(s, terminator:"") })

//
// Read lines of input until EOF or someone sets the `done` flag in the context.
//
while !context.done, let line = readLine(prompt: "$ ", strippingNewline: true) {
    do {
        var parsed = try ConsoleCommands.parse( line)
  
        // Sort out which kind of command I have. If it needs a context then
        // pass in an appropriate context. If not, then just `.run()`
        switch parsed {
        case var po as ConsoleCommand:
            try po.run(context:context )
        default:
            try parsed.run()
        }
    } catch ParserErrors.noCommand {
        // it's ok, just a blank line or something got in.
    } catch {
        // Odd choice. I probably should send that to the context's
        // `write(_)` method so the user sees it, but its an example.
        print("\(ConsoleCommands.fullMessage(for: error))")
    }

}
