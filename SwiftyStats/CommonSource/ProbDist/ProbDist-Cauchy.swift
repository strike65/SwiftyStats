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

// MARK: Cauchy
/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Cauchy distribution.
/// - Parameter a: Location parameter a
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func paraCauchyDist(location a: Double!, scale b: Double!) throws -> SSContProbDistParams {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return SSContProbDistParams()
}

/// Returns the pdf of the Cauchy distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter a
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func pdfCauchyDist(x: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let p = (x - a) / b
    let result = Double.pi * b * (1.0 + (p * p))
//    let result = Double.pi * b * (1.0 * pow((x - a) / b, 2.0))
    return 1.0 / result
}

/// Returns the cdf of the Cauchy distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter a
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if b <= 0
public func cdfCauchyDist(x: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result = 0.5 + 1.0 / Double.pi * atan((x - a) / b)
    return result
}

/// Returns the pdf of the Cauchy distribution.
/// - Parameter x: x
/// - Parameter a: Location parameter a
/// - Parameter b: Scale parameter b
/// - Throws: SSSwiftyStatsError if (b <= 0 || p < 0 || p > 1)
public func quantileCauchyDist(p: Double!, location a: Double!, scale b: Double!) throws -> Double {
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("shape parameter b is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p < 0.0 || p > 1.0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if p.isZero {
        return -Double.infinity
    }
    if fabs(p - 1.0) < Double.leastNonzeroMagnitude {
        return Double.infinity
    }
    let result = a + b * tan((-0.5 + p) * Double.pi)
    return result
}

