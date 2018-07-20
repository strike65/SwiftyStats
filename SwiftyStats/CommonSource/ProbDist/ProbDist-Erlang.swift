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

// MARK: Erlang

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Erlang distribution.
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func paraErlangDist(shape a: Double!, scale b: UInt!) throws -> SSContProbDistParams {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result:SSContProbDistParams = try! paraGammaDist(shape: a, scale: Double(b))
    return result
}


/// Returns the pdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func pdfErlangDist(x: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! pdfGammaDist(x: x, shape: a, scale: Double(b))
}

/// Returns the cdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func cdfErlangDist(x: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result: Double
    do {
        result = try cdfGammaDist(x: x, shape: a, scale: Double(b))
        return result
    }
    catch {
        throw error
    }
}

/// Returns the quantile of the Erlang distribution.
/// - Parameter p: p
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || p < 0 || p > 1
public func quantileErlangDist(p: Double!, shape a: Double!, scale b: UInt!) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1 ", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p == 0.0 {
        return 0.0
    }
    if p == 1.0 {
        return Double.infinity
    }
    return try! quantileGammaDist(p: p, shape: a, scale: Double(b))
}


