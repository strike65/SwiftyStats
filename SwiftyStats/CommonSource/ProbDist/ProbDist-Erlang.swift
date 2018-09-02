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
public func paraErlangDist<FPT: SSFloatingPoint & Codable>(shape k: UInt, rate lambda: FPT) throws -> SSContProbDistParams<FPT> {
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
    var result:SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    result.mean = makeFP(k) / lambda
    result.variance = makeFP(k) / pow1(lambda, 2)
    result.skewness = 2 / sqrt(makeFP(k))
    result.kurtosis = 3 + 6 / makeFP(k)
    return result
}


/// Returns the pdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func pdfErlangDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape k: UInt, rate lambda: FPT) throws -> FPT {
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
        return 0
    }
    let s1:FPT = exp1(-lambda * x) * pow1(lambda, makeFP(k)) * pow1(x, makeFP(k - 1))
    let s2:FPT = logFactorial(Int(k - 1))
    return s1 / exp1(s2)
}

/// Returns the cdf of the Erlang distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0
public func cdfErlangDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape k: UInt, rate lambda: FPT) throws -> FPT {
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
        return 0
    }
    var result: FPT = 0
    var cv: Bool = false
    result = gammaNormalizedP(x: x * lambda, a: makeFP(k), converged: &cv)
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
public func quantileErlangDist<FPT: SSFloatingPoint & Codable>(p: FPT, shape k: UInt!, rate lambda: FPT) throws -> FPT {
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
    if p == 0 {
        return 0
    }
    if p == 1 {
        return FPT.infinity
    }
    if p == 0 {
        return 0
    }
    if p == 1 {
        return FPT.infinity
    }
    let a = FPT(k)
    var gVal: FPT = 0
    var maxG: FPT = 0
    var minG: FPT = 0
    maxG = a * lambda + 4000
    minG = 0
    gVal = a * lambda
    var test: FPT
    var i = 1
    while((maxG - minG) > makeFP(1.0E-14)) {
        test = try! cdfErlangDist(x: gVal, shape: k, rate: lambda)
        if test > p {
            maxG = gVal
        }
        else {
            minG = gVal
        }
        gVal = (maxG + minG) * makeFP(0.5 )
        i = i + 1
        if i >= 7500 {
            break
        }
    }
    if((a * lambda) > 10000) {
        let t1: FPT = gVal * makeFP(1E07)
        let ri: FPT = floor(t1)
        let rd: FPT = makeFP(ri) / makeFP(1E07)
        return rd
    }
    else {
        return gVal
    }

}


