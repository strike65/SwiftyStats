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

extension SSProbDist {
    /// F Ratio distribution
    public enum FRatio {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the F ratio distribution.
        /// - Parameter df1: numerator degrees of freedom
        /// - Parameter df2: denominator degrees of freedom
        /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom expected to be > 0", log: .log_stat, type: .error)
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
                let e3: FPT = df1 * SSMath.pow1(df2 - 2, 2)
                let e4: FPT = 2 * SSMath.pow1(df2, 2)
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
                let s1 = SSMath.pow1(df2 - 2,2)
                let s2 = df2 - 4
                let s3 = df1 + df2 - 2
                let s4 = 5 * df2 - 22
                let s5 = df2 - 6
                let s6 = df2 - 8
                let s7 = df1 + df2 - 2
                let ss1 = (s1 * (s2) + df1 * (s3) * (s4))
                let ss2 = df1 * (s5) * (s6) * (s7)
                result.kurtosis = 3 + (12 * ss1) / (ss2)
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
        public static func pdf<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
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
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            if f >= 0 {
                f1 = (df1 + df2) / 2
                f2 = df1 / 2
                f3 = df2 / 2
                lg1 = SSMath.lgamma1(f1)
                lg2 = SSMath.lgamma1(f2)
                lg3 = SSMath.lgamma1(f3)
                f4 = (df1 / 2) * SSMath.log1(df1 / df2)
                f5 = (df1 / 2 - 1) * SSMath.log1(f)
                ex1 = (df1 + df2) / 2
                ex2 = df1 * f / df2
                ex3 = FPT.one + ex2
                f6 = ex1 * SSMath.log1(ex3)
                //        f6 = ((df1 + df2) / 2) * SSMath.log1(1 + df1 * f / df2)
                f7 = lg1 - (lg2 + lg3) + f4
                f8 = f5 - f6
                f9 = f7 + f8
                result = SSMath.exp1(f9)
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
        public static func cdf<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            if f <= 0 {
                return 0
            }
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            ex1 = f * df1
            ex2 = df2 + ex1
            ex3 = ex1 / ex2
            ex4 = df1 * FPT.half
            ex5 = df2 * FPT.half
            let result = SSSpecialFunctions.betaNormalized(x: ex3, a: ex4, b: ex5)
            return result
        }
        
        /// Returns the quantile function of the F-ratio distribution.
        /// - Parameter p: p
        /// - Parameter df1: numerator degrees of freedom
        /// - Parameter df2: denominator degrees of freedom
        /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0 and/or p < 0 and/or p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT,numeratorDF df1: FPT, denominatorDF df2: FPT) throws -> FPT {
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0.0 and <= 1.0", log: .log_stat, type: .error)
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
            let lower: FPT =  Helpers.makeFP(1E-12)
            let half: FPT = FPT.half
            while((maxF - minF) > lower)
            {
                if it == 1000 {
                    break
                }
                do {
                    temp_p = try cdf(f: fVal, numeratorDF: df1, denominatorDF: df2)
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
    }
}

extension SSProbDist {
    /// Non central F Ratio distribution
    public enum NonCentralFRatio {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the noncentral F ratio distribution.
        /// - Parameter df1: numerator degrees of freedom
        /// - Parameter df2: denominator degrees of freedom
        /// - Parameter lambda: noncentrality
        /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> SSProbDistParams<FPT> {
            var e1, e2, e3, e4, e5, e6, e7: FPT
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try SSProbDist.FRatio.para(numeratorDF: df1, denominatorDF: df2)
                }
                catch {
                    throw error
                }
            }
            if (df2 > 2) {
                ex1 = lambda + df1
                ex2 = df2 * ex1
                ex3 = df2 - 2
                ex4 = ex3 * df1
                result.mean = ex2 / ex4
            }
            else {
                result.mean = FPT.nan
            }
            if (df2 > 4) {
                e1 = (1 + df1) * (1 + df1)
                ex1 = df2 - 2
                ex2 = 2 * lambda + df1
                e2 = ex1 * ex2
                e3 = 2 * SSMath.pow1(df2, 2) * (e1 + e2)
                e1 = df2 - 4
                e2 = SSMath.pow1(df2 - 2, 2) * SSMath.pow1(df1, 2)
                result.variance = e3 / (e1 * e2)
            }
            else {
                result.variance = FPT.nan
            }
            if (df2 > 6) {
                e1 = 2 * FPT.sqrt2 * sqrt(df2 - 4)
                e2 = df1 * (df1 + df2 - 2)
                ex1 = 2 * df1
                ex2 = df2 - FPT.one
                ex3 = ex1 + ex2
                e3 = e2 * ex3
                e4 = 3 * (df2 + 2 * df1)
                ex1 = 2 * df1
                ex2 = df2 - 2
                ex3 = ex1 + ex2
                ex4 = ex3 * lambda
                e5 = e4 * ex4
                ex1 = df1 + df2 - 2
                ex2 = 6 * ex1
                e6 = ex2 * SSMath.pow1(lambda,2)
                ex1 = e3 + e5 + e6
                ex2 = ex1 + 2
                e7 = ex2 * SSMath.pow1(lambda, 3)
                let d1 = e1 * e7
                e1 = df2 - 6
                e2 = df1 * (df1 + df2 - 2)
                ex1 = df1 + df2 - 2
                ex2 = 2 * ex1
                ex3 = ex2 * lambda
                e3 = e2 + ex3
                e4 = e3 + SSMath.pow1(lambda, 2)
                
                let d2 = e1 * SSMath.pow1(e4,  Helpers.makeFP(1.5))
                
                result.skewness = (d1 / d2) * e1
            }
            else {
                result.skewness = FPT.nan
            }
            if (df2 > 8) {
                e1 = 3 * (df2 - 4)
                
                e2 = df1 * (-2 + df1 + df2)
                e3 = 4 * SSMath.pow1(-2 + df2, 2)
                e4 = e3 + SSMath.pow1(df1, 2) * (10 + df2)
                ex1 = (df2 - 2)
                ex2 = (10 + df2)
                ex3 = ex1 * ex2
                ex4 = df1 * ex3
                e5 = e4 + ex4
                let d1: FPT = e2 * e5
                e2 = 4 * (-2 + df1 + df2)
                e3 = 4 * SSMath.pow1(-2 + df2, 2)
                e4 = e3 + SSMath.pow1(df1, 2) * (10 + df2)
                ex1 = (df2 - 2)
                ex2 = (10 + df2)
                ex3 = ex1 * ex2
                ex4 = df1 * ex3
                e5 = e4 + ex4
                let d2: FPT = e1 * e4 * lambda
                e2 = 2 * (10 + df2)
                e3 = e2 * (-2 + df1 + df2)
                ex1 = 3 * df1
                ex2 = 2 * df2
                ex3 = ex1 + ex2
                ex4 = ex3 - 4
                e4 = e3 * ex4
                let d3: FPT = e4 * SSMath.pow1(lambda,2)
                e2 = 4 * (10 + df2)
                ex1 = df1 + df2 - 2
                ex2 = ex1 * SSMath.pow1(lambda, 3)
                let d4: FPT = e2 * ex2
                let d5: FPT = SSMath.pow1(lambda, 4) * (10 + df2)
                ex1 = d1 + d2
                ex2 = ex1 + d3
                ex3 = ex2 + d4
                ex5 = ex4 + d5
                let A: FPT = e1 * ex5
                let d6: FPT = (-8 + df2) * (-8 + df2)
                e1 = df1 * (-2 + df1 + df2)
                ex1 = df1 + df2
                ex2 = ex1 - 2
                ex3 = ex2 * lambda
                ex4 = 2 * ex3
                e2 = e1 + ex4
                e3 = e2 + SSMath.pow1(lambda, 2)
                let d7: FPT = SSMath.pow1(e3, 2)
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
        public static func pdf<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try SSProbDist.FRatio.pdf(f: f, numeratorDF: df1, denominatorDF: df2)
                }
                catch {
                    throw error
                }
            }
            let y: FPT = f * df1 / df2
            let beta: FPT
            do {
                ex1 =  y / (FPT.one + y)
                ex2 = df1 / 2
                ex3 = df2 / 2
                beta = try SSProbDist.NoncentralBeta.pdf(x: ex1, shapeA: ex2, shapeB: ex3, lambda: lambda)
            }
            catch {
                throw error
            }
            ex1 = df1 / df2
            ex2 = (1 + y)
            ex3 = ex2 * ex2
            ex4 = ex1 / ex3
            let ans: FPT = ex4 * beta
            return ans
        }
        
        /// Returns the cdf of the noncentral F-ratio distribution. (http://mathworld.wolfram.com/F-Distribution.html)
        /// - Parameter f: f-value
        /// - Parameter df1: numerator degrees of freedom
        /// - Parameter df2: denominator degrees of freedom
        /// - Parameter lambda: Noncentrality
        /// - Throws: SSSwiftyStatsError if df1 <= 0 and/or df2 <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(f: FPT, numeratorDF df1: FPT, denominatorDF df2: FPT, lambda: FPT) throws -> FPT {
            if f <= 0 {
                return 0
            }
            if df1 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("numerator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if df2 <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("denominator degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda == 0 {
                do {
                    return try SSProbDist.FRatio.cdf(f: f, numeratorDF: df1, denominatorDF: df2)
                }
                catch {
                    throw error
                }
            }
            let y: FPT = f * df1 / (df2 + df1 * f)
            var ans: FPT = FPT.nan
            do {
                let ncbeta: FPT = try SSProbDist.NoncentralBeta.cdf(x: y, shapeA: df1 / 2, shapeB: df2 / 2, lambda: lambda)
                ans = ncbeta
            }
            catch {
                throw error
            }
            return ans
        }
    }
}


