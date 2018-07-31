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


// MARK: Chi Square

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Throws: SSSwiftyStatsError if b <= 0
public func paraExtremValueDist(location a: Double!, scale b: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let ZETA3: Double = 1.2020569031595942853997381
    result.mean = a + EULERGAMMA
    result.variance = (b * b * PISQUARED) / 6.0
    result.skewness = (12.0 * SQRTSIX * ZETA3) / (PISQUARED * Double(PIL))
    result.kurtosis = 5.4
    return result
}


/// Returns the pdf of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter x: x
/// - Throws: SSSwiftyStatsError if b <= 0
public func pdfExtremValueDist(x: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double = 0.0
    result = exp(-(x - a) / b) * exp(-exp(-(x - a) / b)) / b
    return result
}

/// Returns the cdf of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter x: x
/// - Throws: SSSwiftyStatsError if b <= 0
public func cdfExtremValueDist(x: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double = 0.0
    result = exp(-exp(-(-a + x) / b ))
    return result
}


/// Returns the p-quantile of the Extrem Value distribution.
/// - Parameter a: location
/// - Parameter b: scale
/// - Parameter p: p
/// - Throws: SSSwiftyStatsError if b <= 0
public func quantileExtremValueDist(p: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if b <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p <= 0.0 {
        return -Double.infinity
    }
    else if (p >= 1.0) {
        return Double.infinity
    }
    else {
        return a - b * log(-log(p))
    }
}
