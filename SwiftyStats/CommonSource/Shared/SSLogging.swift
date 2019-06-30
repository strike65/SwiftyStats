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
    private static var subsystem = Bundle.main.bundleIdentifier
    
    static let log_stat = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "functions_parameters")
    static let log_dev = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "severe_bugs")
    static let log_fs = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "de.strike65.SwiftyStats", category: "filesystem")
}
/// Defines the Logsystem for SwiftyStats

#endif
