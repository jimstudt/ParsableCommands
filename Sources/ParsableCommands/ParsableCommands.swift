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
    ///
    /// The commands will be alphabetized and formatted to fit the available
    /// number of columns.
    /// 
    /// - Parameter columns: Specify a loose maximum length for the lines. .
    /// - Returns: A list of commands suitable for displaying to a user.
    public static func helpMessage( columns: Int? = nil ) -> String {
        let width = columns ?? Int.max
        let sorted = commands.sorted { $0._commandName < $1._commandName }

        // Don't let the commands be more than half the width
        let cmdWidth = min( commands.map{ $0._commandName.count }.max() ?? 8, width/2)

        let indent = "  "
        let gap = "  "
        
        let descWidth = width - indent.count - cmdWidth - gap.count
        
        /// Word wrap a string.
        ///
        ///  Don't go beyond `width` if wrapping will prevent it. Very long words might still
        ///  go past `width`. The first line starts in the `indent` position, Any new lines
        ///  are indented by `indent` spaces.
        ///
        /// - Note: This will collapse adjacent spaces.
        ///
        /// - Parameters:
        ///   - source: A string to word wrap
        ///   - width: The maximum width for a line
        ///   - indent: The number of spaces to indent successive lines.
        /// - Returns: A word wrapped string with indented following lines.
        func wrapWords( source:String, width:Int, indent:Int) -> String {
            let prefix = String(repeating: " ", count: indent)
            
            var result = ""
            var lineLength = indent   // first one starts already indented
            var freshLine = true
            
            for w in source.components(separatedBy: .whitespaces) {
                if freshLine {
                    result += w
                    lineLength += w.count
                    freshLine = false
                } else if w.count + lineLength < width {
                    result += " " + w
                    lineLength += 1 + w.count
                } else {
                    result += "\n" + prefix + w
                    lineLength = indent + w.count
                }
            }
            return result
        }
        
        /// Format a single command's entry.
        ///
        /// It will be indented and the abstract aligned with other rows. The abstract
        /// may be word wrapped if too long for the available columns.
        ///
        /// - Parameter command: The ParsableCommand.Type to describe
        /// - Returns: A newline terminated string for this row, possibly with internal newlines.
        func format( _ command : ParsableCommand.Type ) -> String {
            let name = command._commandName
            let description = command.configuration.abstract

            let paddedDescription = (description.count <= descWidth) ? description : wrapWords( source:description,
                                                                                                width:width,
                                                                                                indent:indent.count + cmdWidth + gap.count)
            
            return indent +
                name.padding(toLength: cmdWidth, withPad: " ", startingAt: 0) +
                gap +
                paddedDescription +
                "\n"
        }
        
        return "Available commands:\n" + sorted.map{ format($0) }.joined()
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
