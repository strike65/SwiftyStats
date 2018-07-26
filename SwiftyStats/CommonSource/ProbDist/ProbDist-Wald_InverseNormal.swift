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


// MARK: Wald / Inverse Normal

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Wald (inverse normal) distribution.
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func paraWaldDist(mean a: Double!, lambda b: Double) throws -> SSContProbDistParams {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var reault = SSContProbDistParams()
    reault.mean = a
    reault.variance = (a * a * a) / b
    reault.kurtosis = 3.0 + 15.0 * a / b
    reault.skewness = 3.0 * sqrt(a / b)
    return reault
}

/// Returns the pdf of the Wald (inverse normal) distribution.
/// - Parameter x: x
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfWaldDist(x: Double!, mean a: Double!, lambda b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if x <= 0.0 {
        return 0.0
    }
    else {
        return sqrt(b / ( 2.0 * Double.pi * x * x * x)) * exp(b / a - b / (x + x) - (b * x) / (2.0 * a * a))
    }
}

/// Returns the cdf of the Wald (inverse normal) distribution.
/// - Parameter x: x
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfWaldDist(x: Double!, mean a: Double!, lambda b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let n1 = cdfStandardNormalDist(u: sqrt(b / x) * (x / a - 1.0))
    let n2 = cdfStandardNormalDist(u: -sqrt(b / x) * (x / a + 1.0))
    let result = n1 + exp(2.0 * b / a) * n2
    return result
}

/// Returns the quantile of the Wald (inverse normal) distribution.
/// - Parameter p: p
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 0
public func quantileWaldDist(p: Double!, mean a: Double!, lambda b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
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
    
    if fabs(p - 1.0) <= 1e-12 {
        return Double.infinity
    }
    if (fabs(p) <= 1e-12) {
        return 0.0
    }
    var wVal: Double
    var MaxW: Double
    var MinW: Double
    MaxW = 99999
    MinW = 0.0
    wVal = p * a * b
    var pVal: Double
    var i: Int = 0
    while (MaxW - MinW) > 1.0E-16 {
        do {
            pVal = try cdfWaldDist(x: wVal, mean: a, lambda: b)
        }
        catch {
            return Double.nan
        }
        if pVal > p {
            MaxW = wVal
        }
        else {
            MinW = wVal
        }
        wVal = (MaxW + MinW) * 0.5
        i = i + 1
        if  i >= 500 {
            break
        }
    }
    return wVal
}

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Wald (inverse normal) distribution.
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func paraInverseNormalDist(mean a: Double!, lamdba b: Double) throws -> SSContProbDistParams {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! paraWaldDist(mean:a, lambda:b)
}

/// Returns the pdf of the Wald (inverse normal) distribution.
/// - Parameter x: x
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func pdfInverseNormalDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! pdfWaldDist(x:x, mean:a, lambda:b)
}

/// Returns the cdf of the Wald (inverse normal) distribution.
/// - Parameter x: x
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
public func cdfInverseNormalDist(x: Double!, mean a: Double!, scale b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("scale parameter a is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    return try! cdfWaldDist(x:x, mean:a, lambda:b)
}

/// Returns the quantile of the Wald (inverse normal) distribution.
/// - Parameter p: p
/// - Parameter a: mean
/// - Parameter b: Scale
/// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 0
public func quantileInverseNormalDist(p: Double!, mean a: Double!, scale b: Double) throws -> Double {
    if (a <= 0.0) {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("parameter mean is expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (b <= 0.0) {
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
    return try! quantileWaldDist(p:p, mean:a, lambda:b)
}
