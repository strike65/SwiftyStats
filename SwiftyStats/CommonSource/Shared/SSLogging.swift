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
import os.log

extension OSLog {
    @available(macOS 10.12, iOS 13.0, *)
    private static var subsystem = Bundle.main.bundleIdentifier
    @available(macOS 10.12, iOS 13.0, *)
    static let log_stat = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.stike65.SwiftyStats", category: "functions_parameters")
    @available(macOS 10.12, iOS 13.0, *)
    static let log_dev = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.stike65.SwiftyStats", category: "severe_bugs")
    @available(macOS 10.12, iOS 13.0, *)
    static let log_fs = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.stike65.SwiftyStats", category: "filesystem")
}
/// Defines the Logsystem for SwiftyStats

public func wtf(truth: Bool) {
    if truth {
        print("There is no truth. There are only expectations and broken hearts")
    }
    else {
        print("You are beautiful and smart.")
    }
}
#endif
