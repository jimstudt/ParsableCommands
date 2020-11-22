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
    var token : String? = nil
    var escaped : Bool = false
    
    /// Add a character to the token
    ///
    /// Create the token if needed, otherwise just append.
    ///
    /// - Parameter character: The character to add
    func accept( _ character : Character) {
        if token != nil {
            token?.append(character)
        } else {
            token = String(character)
        }
    }
    
    /// Read until the `unquote` terminating character. Respect the backslash.
    ///
    /// This may create a token, even it accepts no characters. This is required
    /// for matching empty strings.
    ///
    /// - Parameter unquote: The character to terminate the quote, unless escapted.
    func quoted( unquote : Character) {
        var escaped = false
        
        // we know we are making a token, even if we
        // accept no characters from a non-token start.
        if token == nil { token = "" }
        
        while let qch = iter.next() {
            switch (qch,escaped) {
            case ( unquote, false):
                return           // <<-- out loop exit
            case ("\\", false):
                escaped = true
            default:
                escaped = false
                accept(qch)
            }
        }
    }
    
    // Grab a character until there are none left
    while let ch = iter.next() {
        switch ( ch, escaped) {
        case ( "\"", false):
            quoted( unquote:"\"")
        case ("'", false):
            quoted( unquote:"'")
        case ("\\", false):
            // A backslash which introduces an escape sequence
            escaped = true
        case (let ch, false) where ch.isWhitespace:
            // Whitespace.
            if let t = token {
                // If we were making a token, finish it and put it in the arguments
                result.append(t)
                token = nil
            }
        default:
            // Any other character, possibly following a backslash, add to the token
            escaped = false
            accept(ch)
        }
    }
    
    // if a token is in progress, finish it.
    if let t = token { result.append(t)}
    
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
