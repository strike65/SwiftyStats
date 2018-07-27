//
//  Created by VT on 20.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
/*
 Copyright (c) 2017 Volker Thieme
 
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
#endif

// MARK: binomial

/// Returns the cdf of the Binomial Distribution
/// - Parameter k: number of events
/// - Parameter lambda: rate
/// - Parameter tail: .lower, .upper
/// - Throws: SSSwiftyStatsError if lambda <= 0, k < 0
public func cdfPoissonDist(k: Int!, rate lambda: Double!, tail: SSCDFTail) throws -> Double {
    if lambda <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lambda is expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if k < 0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("k is expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var conv: Bool = false
    let result: Double = gammaNormalizedQ(x: lambda, a: 1.0 + Double(k), converged: &conv)
    if conv {
        switch tail {
            case .lower:
                return result
            case .upper:
                return 1.0 - result
        }
    }
    else {
        return Double.nan
    }
}


/// Returns the pdf of the Binomial Distribution
/// - Parameter k: number of events
/// - Parameter lambda: rate
/// - Throws: SSSwiftyStatsError if lambda <= 0, k < 0
public func pdfPoissonDist(k: Int!, rate lambda: Double!) throws -> Double {
    if lambda <= 0.0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("lambda is expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if k < 0 {
        #if os(macOS) || os(iOS)
        if #available(macOS 10.12, iOS 10, *) {
            os_log("k is expected to be > 0", log: log_stat, type: .error)
        }
        #endif
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result: Double = Double(k) * log(lambda) - lambda - logFactorial(k)
    return exp(result)
}
