//
// ParsablCommands.swift
//
// Created by Jim Studt on 11/22/20.
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import Foundation

public enum ParserErrors : Error {
    case noCommand
    case noSuchCommand(String)
    case argumentParserError( ParsableCommand.Type, Error)
}

/// A collection of commands for ParsableCommands.parse to search.
public protocol ParsableCommands {
    static var commands : [ParsableCommand.Type] {get}
}

extension ParsableCommands {
    public static subscript(_ name:String) -> ParsableCommand.Type? {
        return commands.first(where: { $0._commandName == name })
    }
    
    /// Find the appropriate command, parse it, and return it.
    ///
    /// - Parameter arguments: An array of arguments. The first one is consumed finding the command.
    /// - Throws: Will throw anything ArgumentParser throws on parsing, plus a couple for no command found.
    /// - Returns: The `ParsableCommand` ready to be `run()`
    public static func parse(_ arguments: [String]) throws -> ArgumentParser.ParsableCommand {
        guard let name = arguments.first else { throw ParserErrors.noCommand }
        
        if let t = self[name] {
            do {
                return try t.parseAsRoot( Array(arguments[1...]) )
            } catch {
                throw ParserErrors.argumentParserError( t, error)
            }
        }
        
        throw ParserErrors.noSuchCommand(name)
    }
    
    /// Return a list of available commands.
    /// - Parameter columns: Ideally used for wrapping, but ignored currently.
    /// - Returns: A list of commands suitable for displaying to a user.
    public static func helpMessage( columns: Int? = nil ) -> String {
        let sorted = commands.sorted { $0._commandName < $1._commandName }
        let cmdWidth = commands.map{ $0._commandName.count }.max() ?? 8
        
        return "Available commands:\n" +
            sorted.map{ $0._commandName.padding(toLength: cmdWidth, withPad: " ", startingAt: 0) + " " + "description" }.joined(separator:"\n") + "\n"
    }
    
    /// Format a ParserError for human reading, suitable for display to users.
    ///
    /// This is similare to `.fullMessage(for:)` but also does not
    /// include the usage information..
    ///
    /// Format the error for users to read. If passed something other than  a
    /// ParserError it will simply return `"Error: ` followed by whatever
    /// the error expands to. You may not want to let that happen.
    ///
    /// - Parameter error: the error
    /// - Returns: A rendition suitable for displaying to users.
    public static func message( for error: Error ) -> String {
        switch error {
        case let e as ParserErrors:
            switch e {
            case .argumentParserError(let cmd, let err):
                return cmd.message(for: err)
            case .noSuchCommand(let name):
                return "No such command: \(name)"
            case .noCommand:
                return "No command"
            }
        default:
            return "Error: \(error)"
        }
    }

    /// Format a ParserError for human reading, suitable for display to users.
    ///
    /// This is similare to `.message(for:)` but also includes usage information.
    ///
    /// Format the error for users to read. If passed something other than  a
    /// ParserError it will simply return `"Error: ` followed by whatever
    /// the error expands to. You may not want to let that happen.
    ///
    /// - Parameter error: the error
    /// - Returns: A rendition suitable for displaying to users.
    public static func fullMessage( for error: Error ) -> String {
        switch error {
        case let e as ParserErrors:
            switch e {
            case .argumentParserError(let cmd, let err):
                return cmd.fullMessage(for: err)
            case .noSuchCommand(let name):
                return "No such command: \(name)"
            case .noCommand:
                return "No command"
            }
        default:
            return "Error: \(error)"
        }
    }

}
