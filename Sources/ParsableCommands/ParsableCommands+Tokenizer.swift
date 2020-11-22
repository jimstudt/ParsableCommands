//
//  ParsableCommands+Tokenizer.swift
//  
//
//  SPDX-License-Identifier: MIT
//
//  Created by Jim Studt on 11/22/20.
//

import Foundation
import ArgumentParser

/// Tokenize a string in a manner similar to `sh`.
///
/// Supports…
/// - dropping whitespace outside of strings
/// - strings, both kinds of quotes
/// - backslash escaping of quotes and backslashes
///
/// An unterminated quote will consume to the end of the string.
///
/// Special sequences, like \t are not translated. Might in the future.
///
/// - Parameter command: The command to be tokenized
/// - Returns: An array of tokens
internal func tokenize( _ command:String) -> [String] {
    var result : [String] = []
    var iter = command.makeIterator()
    var token : String = ""
    var escaped : Bool = false
    
    // Grab a character until there are none left
    while let ch = iter.next() {
        switch ( ch, escaped) {
        case ( "\"", false):
            // We are beginning a " delimited string
            var quoteEscaped = false
            loop: while let qch = iter.next() {
                switch (qch,quoteEscaped) {
                case ( "\"", false):
                    break loop
                case ("\\", false):
                    quoteEscaped = true
                default:
                    quoteEscaped = false
                    token.append(qch)
                }
            }
        case ("'", false):
            // We are beginning a '"' delimited string
            var apostropheEscaped = false
            loop: while let ach = iter.next() {
                switch (ach, apostropheEscaped) {
                case ( "'", false):
                    break loop
                case ("\\", false):
                    apostropheEscaped = true
                default:
                    apostropheEscaped = false
                    token.append(ach)
                }
            }
        case ("\\", false):
            // A backslash which introduces an escape sequence
            escaped = true
        case (let ch, false) where ch.isWhitespace:
            // Whitespace.
            if token != "" {
                // If we were making a token, finish it and put it in the arguments
                result.append(token)
                token = ""
            }
        default:
            // Any other character, possibly following a backslash, add to the token
            escaped = false
            token.append(ch)
        }
    }
    
    if token != "" { result.append(token)}
    
    return result
}

extension ParsableCommands {
    /// Tokenize a string in a manner similar to `sh` and parse it.
    ///
    /// Tokeniing supports:
    /// - dropping whitespace outside of strings
    /// - strings, both kinds of quotes
    /// - backslash escaping of quotes and backslashes
    ///
    /// Ultimately it passes the parsed arguments down to the regular `.parse` function.
    /// - Parameter command: A command string to be tokenized and parsed.
    /// - Throws: Anything from the underlying .parse
    /// - Returns: A ParsableCommand ready for running.
    public static func parse(_ command: String) throws -> ArgumentParser.ParsableCommand {
        return try parse(tokenize(command))
    }
}
