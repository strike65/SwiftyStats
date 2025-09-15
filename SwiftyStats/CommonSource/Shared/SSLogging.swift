//
//  SSLogging.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
//
/*
 Copyright (2017-2019) strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

import Foundation
#if os(macOS) || os(iOS)
import OSLog

// Keep existing OSLog categories for backward compatibility elsewhere
extension OSLog {
    @available(macOS 10.12, iOS 13.0, *)
    static let log_stat = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "functions_parameters")
    @available(macOS 10.12, iOS 13.0, *)
    static let log_dev = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "severe_bugs")
    @available(macOS 10.12, iOS 13.0, *)
    static let log_fs = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "filesystem")
}

// New Logger-based API for Swift 6+
struct SSLogger {
    @available(macOS 11.0, iOS 14.0, *)
    static let stat = Logger(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "functions_parameters")
    @available(macOS 11.0, iOS 14.0, *)
    static let dev = Logger(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "severe_bugs")
    @available(macOS 11.0, iOS 14.0, *)
    static let fs = Logger(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "filesystem")
}
/// Defines the logging system for SwiftyStats.

/// Prints a playful message to stdout depending on the `truth` flag.
/// - Parameter truth: If true, prints a pessimistic quip; otherwise, a compliment.
public func wtf(truth: Bool) {
    if truth {
        print("There is no truth. There are only expectations and broken hearts")
    }
    else {
        print("You are beautiful and smart.")
    }
}
#endif

// Cross-platform wrapper with no-op fallback on older platforms
public enum SSLog {
    public static func statError(_ message: String) {
        #if os(macOS) || os(iOS)
        if #available(macOS 11.0, iOS 14.0, *) {
            SSLogger.stat.error("\(message, privacy: .public)")
        }
        #endif
    }
    public static func devError(_ message: String) {
        #if os(macOS) || os(iOS)
        if #available(macOS 11.0, iOS 14.0, *) {
            SSLogger.dev.error("\(message, privacy: .public)")
        }
        #endif
    }
    public static func fsError(_ message: String) {
        #if os(macOS) || os(iOS)
        if #available(macOS 11.0, iOS 14.0, *) {
            SSLogger.fs.error("\(message, privacy: .public)")
        }
        #endif
    }
}
