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
public func paraErlangDist(shape k: UInt!, rate lambda: Double!) throws -> SSContProbDistParams {
    if (k == 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (lambda <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result:SSContProbDistParams = SSContProbDistParams()
    result.mean = Double(k) / lambda
    result.variance = Double(k) / pow(lambda, 2.0)
    result.skewness = 2.0 / sqrt(Double(k))
    result.kurtosis = 3.0 + 6.0 / Double(k)
    return result
}


/// Returns the pdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func pdfErlangDist(x: Double!, shape k: UInt!, rate lambda: Double!) throws -> Double {
    if (k == 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (lambda <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x.isZero || x < 0 {
        return 0.0
    }
    let s1:Double = exp(-lambda * x) * pow(lambda, Double(k)) * pow(x, Double(k - 1))
    let s2:Double = logFactorial(Int(k - 1))
    return s1 / exp(s2)
}

/// Returns the cdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func cdfErlangDist(x: Double!, shape k: UInt!, rate lambda: Double!) throws -> Double {
    if (k == 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (lambda <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x.isZero || x < 0 {
        return 0.0
    }
    var result: Double = 0.0
    var cv: Bool = false
    result = gammaNormalizedP(x: x * lambda, a: Double(k), converged: &cv)
    if cv {
        return result
    }
    else {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("unable to retrieve a result", log: log_stat, type: .error)
        }
        
        #endif
        throw SSSwiftyStatsError.init(type: .maxNumberOfIterationReached, file: #file, line: #line, function: #function)
    }
}

/// Returns the quantile of the Erlang distribution.
/// - Parameter p: p
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || p < 0 || p > 1
public func quantileErlangDist(p: Double!, shape k: UInt!, rate lambda: Double!) throws -> Double {
    if (k == 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (lambda <= 0) {
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
    if p == 0.0 {
        return 0.0
    }
    if p == 1.0 {
        return Double.infinity
    }
    let a = Double(k)
    var gVal: Double = 0.0
    var maxG: Double = 0.0
    var minG: Double = 0.0
    maxG = a * lambda + 4000.0
    minG = 0.0
    gVal = a * lambda
    var test: Double
    var i = 1
    while((maxG - minG) > 1.0E-14) {
        test = try! cdfErlangDist(x: gVal, shape: k, rate: lambda)
        if test > p {
            maxG = gVal
        }
        else {
            minG = gVal
        }
        gVal = (maxG + minG) * 0.5
        i = i + 1
        if i >= 7500 {
            break
        }
    }
    if((a * lambda) > 10000) {
        let t1: Double = gVal * 1E07
        let ri: UInt64 = UInt64(t1)
        let rd: Double = Double(ri) / 1E07
        return rd
    }
    else {
        return gVal
    }

}


