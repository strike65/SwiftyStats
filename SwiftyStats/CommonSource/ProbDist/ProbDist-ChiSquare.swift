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
    /// Chi square distribution
    public enum ChiSquare {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            result.mean = df
            result.variance = 2 * df
            result.skewness = sqrt(8 / df)
            result.kurtosis = 3 + 12 / df
            return result
        }
        
        
        /// Returns the pdf of the Chi^2 distribution.
        /// - Parameter chi: Chi
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: FPT = 0
            if chi >= 0 {
                let a: FPT
                let b: FPT
                let c: FPT
                let d: FPT
                a = -df / 2 * FPT.ln2
                b = -chi / 2
                c = (-1 + df / 2) * SSMath.log1(chi)
                d = SSMath.lgamma1(df / 2)
                result = SSMath.exp1(a + b + c - d)
            }
            else {
                result = 0
            }
            return result
        }
        
        /// Returns the cdf of the Chi^2 distribution.
        /// - Parameter chi: Chi
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, tail: SSCDFTail = .lower, rlog: Bool = false) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if chi <= 0 {
                return 0
            }
            var conv: Bool = false
            let cdf1: FPT = SSSpecialFunctions.gammaNormalizedP(x:  Helpers.makeFP(1.0 / 2.0 ) * chi, a:  Helpers.makeFP(1.0 / 2.0 ) * df, converged: &conv)
            if cdf1 < 0 {
                if rlog {
                    return -FPT.infinity
                }
                else {
                    return 0
                }
            }
            else if ((cdf1 > 1) || cdf1.isNaN) {
                if rlog {
                    return 0
                }
                else {
                    return 1
                }
            }
            else {
                if rlog {
                    return SSMath.log1(cdf1)
                }
                else {
                    return cdf1
                }
            }
        }
        
        
        /// Returns the p-quantile of the Chi^2 distribution.
        /// - Parameter p: p
        /// - Parameter df: Degrees of freedom
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
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
            if p < FPT.leastNonzeroMagnitude {
                return 0
            }
            if (1 - p) < FPT.leastNonzeroMagnitude {
                return FPT.infinity
            }
            let eps: FPT =  Helpers.makeFP(1.0E-12)
            var minChi: FPT = 0
            var maxChi: FPT = 9999
            var result: FPT = 0
            var chiVal: FPT = df / sqrt(p)
            var test: FPT
            while (maxChi - minChi) > eps {
                do {
                    test = try cdf(chi: chiVal, degreesOfFreedom: df)
                }
                catch {
                    throw error
                }
                if test > p {
                    maxChi = chiVal
                }
                else {
                    minChi = chiVal
                }
                chiVal = (maxChi + minChi) / 2
            }
            result = chiVal
            return result
        }
    }
}
extension SSProbDist {
    /// Non central Chi Square distribution
    public enum NonCentralChiSquare {
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Chi^2 distribution.
        /// - Parameter df: Degrees of freedom
        /// - Parameter lambda: noncentrality parameter
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(degreesOfFreedom df: FPT, lambda: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            result.mean = df
            result.variance = 2 * df
            result.skewness = sqrt(8 / df)
            result.kurtosis = 3 + 12 / df
            return result
        }
        
        
        /// Returns the pdf of the Chi^2 distribution.
        /// - Parameter chi: Chi
        /// - Parameter df: Degrees of freedom
        /// - Parameter lambda: Noncentrality
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try ChiSquare.pdf(chi: chi, degreesOfFreedom: df)
                }
                catch {
                    throw error
                }
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var result: FPT = 0
            if chi >= 0 {
                let bessel: FPT = SSSpecialFunctions.besselI(order: df / 2 - 1, x: sqrt(lambda * chi))
                ex1 = chi + lambda
                ex2 = ex1 * FPT.half
                let a = FPT.half * SSMath.exp1(-ex2)
                ex1 = df / 4
                ex2 = ex1 - FPT.half
                ex3 = chi / lambda
                let b = SSMath.pow1(ex3, ex2)
                result = a * b * bessel
            }
            else {
                result = 0
            }
            return result
        }
        
        
        private static func integrandChiSquared<FPT: SSFloatingPoint & Codable>(chi: FPT, df: FPT, lambda: FPT, p1: FPT, p2: FPT) -> FPT {
            return try! pdf(chi: chi, degreesOfFreedom: df, lambda: lambda)
        }
        
        /// Returns the cdf of the Chi^2 distribution.
        /// - Parameter chi: Chi
        /// - Parameter df: Degrees of freedom
        /// - Parameter lambda: Noncentrality
        /// - Throws: SSSwiftyStatsError if df <= 0
        /// - Note: Uses an algorithm proposed by Gil, Segura and Temme to compute the Marcum function (2014)
        public static func cdf<FPT: SSFloatingPoint & Codable>(chi: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try ChiSquare.cdf(chi: chi, degreesOfFreedom: df)
                }
                catch {
                    throw error
                }
            }
            if chi <= 0 {
                return 0
            }
            
            let marcumRes: (p: FPT, q: FPT, err: Int, underflow: Bool)
            marcumRes = SSSpecialFunctions.marcum(df / 2, sqrt(lambda), sqrt(chi))
            if marcumRes.err == 0 {
                return marcumRes.p
            }
            else {
                var evals: Int = 0
                var error: FPT = 0
                let integral: FPT = SSMath.integrate(integrand: integrandChiSquared, parameters: [df, lambda, 0, 0], leftLimit: 0, rightLimit: chi, maxAbsError:  Helpers.makeFP(1e-15), numberOfEvaluations: &evals, estimatedError: &error)
                return integral
            }
        }
        
        
        
        
        /// Returns the p-quantile of the Chi^2 distribution.
        /// - Parameter p: p
        /// - Parameter df: Degrees of freedom
        /// - Parameter lambda: Noncentrality
        /// - Throws: SSSwiftyStatsError if df <= 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, degreesOfFreedom df: FPT, lambda: FPT) throws -> FPT {
            if df <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("degrees of freedom are expected to be > 0", log: .log_stat, type: .error)
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
            if lambda < 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if lambda.isZero {
                do {
                    return try ChiSquare.quantile(p: p, degreesOfFreedom: df)
                }
                catch {
                    throw error
                }
            }
            if p < FPT.leastNonzeroMagnitude {
                return 0
            }
            if (1 - p) < FPT.leastNonzeroMagnitude {
                return FPT.infinity
            }
            let eps: FPT =  Helpers.makeFP(1.0E-12)
            var minChi: FPT = 0
            var maxChi: FPT = 10000
            var result: FPT = 0
            var chiVal: FPT = df / sqrt(p)
            var test: FPT
            while (maxChi - minChi) > eps {
                do {
                    test = try cdf(chi: chiVal, degreesOfFreedom: df, lambda: lambda)
                }
                catch {
                    throw error
                }
                if test > p {
                    maxChi = chiVal
                }
                else {
                    minChi = chiVal
                }
                chiVal = (maxChi + minChi) / 2
            }
            result = chiVal
            return result
        }
    }
    
}

