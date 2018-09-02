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


// MARK: Gamma

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Gamma distribution.
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func paraGammaDist<FPT: SSFloatingPoint & Codable>(shape a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    result.mean = a * b
    result.variance = a * b * b
    result.kurtosis = 3 + 6 / a
    result.skewness = 2 / sqrt(a)
    return result
}


/// Returns the pdf of the Gamma distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfGammaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0 {
        return 0
    }
    else {
        let a1: FPT = -a * log1(b)
        let a2: FPT = -x / b
        let a3: FPT = -1 + a
        let a4: FPT = a1 + a2 + a3 * log1(x) - lgamma1(a)
        let result = exp1(a4)
        return result
        //            return exp(-a * log(b) + (-x / b) + (-1.0 + a) * log(x) - lgamma(a))
    }
}

/// Returns the cdf of the Gamma distribution.
/// - Parameter x: x
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfGammaDist<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x < 0 {
        return 0
    }
    var cv: Bool = false
    let result = gammaNormalizedP(x: x / b, a: a, converged: &cv)
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

/// Returns the quantile of the Gamma distribution.
/// - Parameter p: p
/// - Parameter a: Shape parameter
/// - Parameter b: Scale parameter
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
public func quantileGammaDist<FPT: SSFloatingPoint & Codable>(p: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
    if (a <= 0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0) {
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
    var gVal: FPT = 0
    var maxG: FPT = 0
    var minG: FPT = 0
    maxG = a * b + 4000
    minG = 0
    gVal = a * b
    var test: FPT
    var i = 1
    while((maxG - minG) > makeFP(1.0E-14)) {
        test = try! cdfGammaDist(x: gVal, shape: a, scale: b)
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
    if((a * b) > 10000) {
        let t1: FPT = gVal * makeFP(1E07)
        let ri: FPT = floor(t1)
        let rd: FPT = ri / makeFP(1E07)
        return rd
    }
    else {
        return gVal
    }
}

