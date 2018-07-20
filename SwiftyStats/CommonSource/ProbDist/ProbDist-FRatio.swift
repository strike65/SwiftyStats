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


// MARK: F-RATIO

/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the F ratio distribution.
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func paraFRatioDist(numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> SSContProbDistParams {
    var result = SSContProbDistParams()
    if df1 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if df2 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("denominator degrees of freedom expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if (df2 > 2.0) {
        result.mean = df2 / (df2 - 2)
    }
    else {
        result.mean = Double.nan
    }
    if (df2 > 4.0) {
        result.variance = (2 * pow(df2, 2.0) * (df1 + df2 - 2.0)) / (df1 * pow(df2 - 2.0,2.0) * (df2 - 4))
    }
    else {
        result.variance = Double.nan
    }
    if (df2 > 6.0) {
        let d1 = (2 * df1 + df2 - 2)
        let d2 = (df2 - 6)
        let s1 = (8 * (df2 - 4))
        let s2 = (df1 * (df1 + df2 - 2))
        result.skewness = (d1 / d2) * sqrt(s1 / s2)
    }
    else {
        result.skewness = Double.nan
    }
    if (df2 > 8.0) {
        let s1 = pow(df2 - 2,2.0)
        let s2 = df2 - 4
        let s3 = df1 + df2 - 2.0
        let s4 = 5.0 * df2 - 22
        let s5 = df2 - 6
        let s6 = df2 - 8
        let s7 = df1 + df2 - 2
        let ss1 = (s1 * (s2) + df1 * (s3) * (s4))
        let ss2 = df1 * (s5) * (s6) * (s7)
        result.kurtosis = 3.0 + (12 * ss1) / (ss2)
        //            result.kurtosis = 3.0 + (12 * (pow(df2 - 2,2.0) * (df2 - 4) + df1 * (df1 + df2 - 2.0) * (5.0 * df2 - 22))) / (df1 * (df2 - 6) * (df2 - 8) * (df1 + df2 - 2))
        //                                      s1            s2                 s3                   s4                        s5          s6            s7
    }
    else {
        result.kurtosis = Double.nan
    }
    return result
}

/// Returns the pdf of the F-ratio distribution.
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func pdfFRatioDist(f: Double!, numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
    if df1 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if df2 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("denominator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    var result: Double
    var f1: Double
    var f2: Double
    var f3: Double
    var f4: Double
    var f5: Double
    var f6: Double
    var f7: Double
    var f8: Double
    var f9: Double
    var lg1: Double
    var lg2: Double
    var lg3: Double
    if f >= 0.0 {
        f1 = (df1 + df2) / 2.0
        f2 = df1 / 2.0
        f3 = df2 / 2.0
        lg1 = lgamma(f1)
        lg2 = lgamma(f2)
        lg3 = lgamma(f3)
        f4 = (df1 / 2.0) * log(df1 / df2)
        f5 = (df1 / 2.0 - 1.0) * log(f)
        f6 = ((df1 + df2)/2.0) * log(1.0 + df1 * f / df2)
        f7 = lg1 - (lg2 + lg3) + f4
        f8 = f5 - f6
        f9 = f7 + f8
        result = exp(f9)
    }
    else {
        result = 0.0
    }
    return result
}

/// Returns the cdf of the F-ratio distribution. (http://mathworld.wolfram.com/F-Distribution.html)
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func cdfFRatio(f: Double!, numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
    if f <= 0.0 {
        return 0.0
    }
    if df1 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if df2 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("denominator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let result = betaNormalized(x: (f * df1) / (df2 + df1 * f), a: df1 / 2.0, b: df2 / 2.0)
    return result
}

/// Returns the quantile function of the F-ratio distribution.
/// - Parameter p: p
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0 and/or p < 0 and/or p > 1
public func quantileFRatioDist(p: Double!,numeratorDF df1: Double!, denominatorDF df2: Double!) throws -> Double {
    if df1 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("numerator degrees of freedom are expected to be > 0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    if df2 <= 0 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("denominator degrees of freedom expected to be > 0", log: log_stat, type: .error)
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
    let eps: Double = 1E-15
    if fabs( p - 1.0 ) <= eps  {
        return Double.infinity
    }
    if fabs(p) <= eps {
        return 0.0
    }
    var fVal: Double
    var maxF: Double
    var minF: Double
    maxF = 9999.0
    minF = 0.0
    fVal = 1.0 / p
    var it: Int = 0
    var temp_p: Double
    while((maxF - minF) > 1.0E-12)
    {
        if it == 1000 {
            break
        }
        do {
            temp_p = try cdfFRatio(f: fVal, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            return Double.nan
        }
        if temp_p > p {
            maxF = fVal
        }
        else {
            minF = fVal
        }
        fVal = (maxF + minF) * 0.5
        it = it + 1
    }
    return fVal
}

