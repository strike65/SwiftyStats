//
//  Created by VT on 20.07.18.
//  Copyright © 2018 strike65. All rights reserved.
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
#endif


// MARK: Chi Square

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Throws: SSSwiftyStatsError if b <= 0
public func paraExtremValueDist<FPT: SSFloatingPoint & Codable>(location a: FPT, scale b: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let ZETA3: FPT = makeFP(1.202056903159594285399738161511449990764986292340498881792271555)
    result.mean = a + FPT.eulergamma
    result.variance = (b * b * FPT.pisquared) / 6
    result.skewness = (12 * FPT.sqrt6 * ZETA3) / (FPT.pisquared * FPT.pi)
    result.kurtosis = makeFP(5.4)
    return result
}


/// Returns the pdf of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter x: x
/// - Throws: SSSwiftyStatsError if b <= 0
public func pdfExtremValueDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: FPT = 0
    let e1: FPT = x - a
    let e2: FPT = e1 / b
    result = exp1(-e2) * exp1(-exp1(-e2)) / b
//    result = exp1(-(x - a) / b) * exp1(-exp1(-(x - a) / b)) / b
    return result
}

/// Returns the cdf of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter x: x
/// - Throws: SSSwiftyStatsError if b <= 0
public func cdfExtremValueDist<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: FPT = 0
    result = exp1(-exp1(-(-a + x) / b ))
    return result
}


/// Returns the p-quantile of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter p: p
/// - Throws: SSSwiftyStatsError if b <= 0
public func quantileExtremValueDist<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT) throws -> FPT {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p <= 0 {
        return -FPT.infinity
    }
    else if (p >= 1) {
        return FPT.infinity
    }
    else {
        return a - b * log1(-log1(p))
    }
}
