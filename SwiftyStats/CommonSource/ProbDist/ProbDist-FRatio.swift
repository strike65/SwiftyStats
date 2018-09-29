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
public func paraFRatioDist<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
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
    if (df2 > 2) {
        result.mean = df2 / (df2 - 2)
    }
    else {
        result.mean = FPT.nan
    }
    if (df2 > 4) {
        let e1: FPT = (df1 + df2 - 2)
        let e2: FPT = (df2 - 4)
        let e3: FPT = df1 * pow1(df2 - 2, 2)
        let e4: FPT = 2 * pow1(df2, 2)
        result.variance = (e4 * e1) / (e3 * e2)
    }
    else {
        result.variance = FPT.nan
    }
    if (df2 > 6) {
        let d1 = (2 * df1 + df2 - 2)
        let d2 = (df2 - 6)
        let s1 = (8 * (df2 - 4))
        let s2 = (df1 * (df1 + df2 - 2))
        result.skewness = (d1 / d2) * sqrt(s1 / s2)
    }
    else {
        result.skewness = FPT.nan
    }
    if (df2 > 8) {
        let s1 = pow1(df2 - 2,2)
        let s2 = df2 - 4
        let s3 = df1 + df2 - 2
        let s4 = 5 * df2 - 22
        let s5 = df2 - 6
        let s6 = df2 - 8
        let s7 = df1 + df2 - 2
        let ss1 = (s1 * (s2) + df1 * (s3) * (s4))
        let ss2 = df1 * (s5) * (s6) * (s7)
        result.kurtosis = 3 + (12 * ss1) / (ss2)
        //            result.kurtosis = 3.0 + (12 * (pow(df2 - 2,2.0) * (df2 - 4) + df1 * (df1 + df2 - 2.0) * (5.0 * df2 - 22))) / (df1 * (df2 - 6) * (df2 - 8) * (df1 + df2 - 2))
        //                                      s1            s2                 s3                   s4                        s5          s6            s7
    }
    else {
        result.kurtosis = FPT.nan
    }
    return result
}

/// Returns the pdf of the F-ratio distribution.
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func pdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
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
    var result: FPT
    var f1: FPT
    var f2: FPT
    var f3: FPT
    var f4: FPT
    var f5: FPT
    var f6: FPT
    var f7: FPT
    var f8: FPT
    var f9: FPT
    var lg1: FPT
    var lg2: FPT
    var lg3: FPT
    if f >= 0 {
        f1 = (df1 + df2) / 2
        f2 = df1 / 2
        f3 = df2 / 2
        lg1 = lgamma1(f1)
        lg2 = lgamma1(f2)
        lg3 = lgamma1(f3)
        f4 = (df1 / 2) * log1(df1 / df2)
        f5 = (df1 / 2 - 1) * log1(f)
        f6 = ((df1 + df2) / 2) * log1(1 + df1 * f / df2)
        f7 = lg1 - (lg2 + lg3) + f4
        f8 = f5 - f6
        f9 = f7 + f8
        result = exp1(f9)
    }
    else {
        result = 0
    }
    return result
}

/// Returns the cdf of the F-ratio distribution. (http://mathworld.wolfram.com/F-Distribution.html)
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func cdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
    if f <= 0 {
        return 0
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
    let result = betaNormalized(x: (f * df1) / (df2 + df1 * f), a: df1 / 2, b: df2 / 2)
    return result
}

/// Returns the quantile function of the F-ratio distribution.
/// - Parameter p: p
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0 and/or p < 0 and/or p > 1
public func quantileFRatioDist<FPT: SSFloatingPoint & Codable>(p: FPT,numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
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
    if p < 0 || p > 1 {
        #if os(macOS) || os(iOS)
        
        if #available(macOS 10.12, iOS 10, *) {
            os_log("p is expected to be >= 0.0 and <= 1.0", log: log_stat, type: .error)
        }
        
        #endif
        
        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
    }
    let eps: FPT = FPT.ulpOfOne
    if abs( p - 1 ) <= eps  {
        return FPT.infinity
    }
    if abs(p) <= eps {
        return 0
    }
    var fVal: FPT
    var maxF: FPT
    var minF: FPT
    maxF = 9999
    minF = 0
    fVal = 1 / p
    var it: Int = 0
    var temp_p: FPT
    let lower: FPT = makeFP(1E-12)
    let half: FPT = FPT.half
    while((maxF - minF) > lower)
    {
        if it == 1000 {
            break
        }
        do {
            temp_p = try cdfFRatioDist(f: fVal, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            return FPT.nan
        }
        if temp_p > p {
            maxF = fVal
        }
        else {
            minF = fVal
        }
        fVal = (maxF + minF) * half
        it = it + 1
    }
    return fVal
}

/* noncentral */


/// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the noncentral F ratio distribution.
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Parameter lambda: noncentrality
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func paraFRatioDist<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> SSContProbDistParams<FPT> {
    var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
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
    if lambda.isZero {
        do {
            return try paraFRatioDist(numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
    }
    if (df2 > 2) {
        result.mean = df2 * (lambda + df1) / ((df2 - 2) * df1)
    }
    else {
        result.mean = FPT.nan
    }
    var e1, e2, e3, e4, e5, e6, e7: FPT
    if (df2 > 4) {
        e1 = (1 + df1) * (1 + df1)
        e2 = (df2 - 2) * (2 * lambda + df1)
        e3 = 2 * pow1(df2, 2) * (e1 + e2)
        e1 = df2 - 4
        e2 = pow1(df2 - 2, 2) * pow1(df1, 2)
        result.variance = e3 / (e1 * e2)
    }
    else {
        result.variance = FPT.nan
    }
    if (df2 > 6) {
        e1 = 2 * FPT.sqrt2 * sqrt(df2 - 4)
        e2 = df1 * (df1 + df2 - 2)
        e3 = e2 * (2 * df1 + df2 - 1)
        
        e4 = 3 * (df2 + 2 * df1)
        e5 = e4 * (2 * df1 + df2 - 2) * lambda
        
        e6 = 6 * (df1 + df2 - 2) * pow1(lambda, 2)

        e7 = e3 + e5 + e6 + 2 * pow1(lambda, 3)
        
        let d1 = e1 * e7
        
        e1 = df2 - 6
        
        e2 = df1 * (df1 + df2 - 2)
        e3 = e2 + 2 * (df1 + df2 - 2) * lambda
        e4 = e3 + pow1(lambda, 2)
        
        let d2 = e1 * pow1(e4, makeFP(1.5))
        
        result.skewness = (d1 / d2) * e1
    }
    else {
        result.skewness = FPT.nan
    }
    if (df2 > 8) {
        e1 = 3 * (df2 - 4)
        
        e2 = df1 * (-2 + df1 + df2)
        e3 = 4 * pow1(-2 + df2, 2)
        e4 = e3 + pow1(df1, 2) * (10 + df2)
        e5 = e4 + df1 * (-2 + df2) * (10 + df2)
        let d1: FPT = e2 * e5
        
        e2 = 4 * (-2 + df1 + df2)
        e3 = 4 * pow1(-2 + df2, 2)
        e4 = e3 + pow1(df1, 2) * (10 + df2)
        e5 = e4 + df1 * (-2 + df2) * (10 + df2)
        let d2: FPT = e1 * e4 * lambda
        
        e2 = 2 * (10 + df2)
        e3 = e2 * (-2 + df1 + df2)
        e4 = e3 * (-4 + 3 * df1 + 2 * df2)
        let d3: FPT = e4 * pow1(lambda,2)
        
        e2 = 4 * (10 + df2)
        let d4: FPT = e2 * (df1 + df2 - 2) * pow1(lambda, 3)
        
        let d5: FPT = pow1(lambda, 4) * (10 + df2)
        
        let A: FPT = e1 * (d1 + d2 + d3 + d4 + d5)
        
        let d6: FPT = (-8 + df2) * (-8 + df2)
        
        e1 = df1 * (-2 + df1 + df2)
        e2 = e1 + 2 * (-2 + df1 + df2) * lambda
        e3 = e2 + pow1(lambda, 2)
        
        let d7: FPT = pow1(e3, 2)
        
        let B: FPT = d6 * d7
        
        result.kurtosis = A / B
    }
    else {
        result.kurtosis = FPT.nan
    }
    return result
}

/// Returns the pdf of the F-ratio distribution.
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Parameter lambda: Noncentrality
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func pdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
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
    if lambda.isZero {
        do {
            return try pdfFRatioDist(f: f, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
    }
    let y: FPT = f * df1 / df2
    let beta: FPT
    do {
        beta = try pdfBetaDist(x: y / (1 + y), shapeA: df1 / 2, shapeB: df2 / 2, lambda: lambda)
    }
    catch {
        throw error
    }
    let ans: FPT = (df1 / df2) / ((1 + y) * (1 + y)) * beta
    return ans
}

/// Returns the cdf of the noncentral F-ratio distribution. (http://mathworld.wolfram.com/F-Distribution.html)
/// - Parameter f: f-value
/// - Parameter df1: numerator degrees of freedom
/// - Parameter df2: denominator degrees of freedom
/// - Parameter lambda: Noncentrality
/// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
public func cdfFRatioDist<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
    if f <= 0 {
        return 0
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
    if lambda == 0 {
        do {
            return try cdfFRatioDist(f: f, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
    }
    let y: FPT = f * df1 / (df2 + df1 * f)
    var ans: FPT = FPT.nan
    do {
        let ncbeta: FPT = try cdfBetaDist(x: y, shapeA: df1 / 2, shapeB: df2 / 2, lambda: lambda)
        ans = ncbeta
    }
    catch {
        throw error
    }
    return ans
}
