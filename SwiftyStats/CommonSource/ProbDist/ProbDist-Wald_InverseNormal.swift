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
    /// Wald (inverse normal) distribution
    public enum InverseNormal {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Wald (inverse normal) distribution.
        /// - Parameter a: mean
        /// - Parameter b: Scale
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(mean a: FPT, lambda b: FPT) throws -> SSProbDistParams<FPT> {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter mean is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = a
            result.variance = (a * a * a) / b
            result.kurtosis = 3 + 15 * a / b
            result.skewness = 3 * sqrt(a / b)
            return result
        }
        
        /// Returns the pdf of the Wald (inverse normal) distribution.
        /// - Parameter x: x
        /// - Parameter a: mean
        /// - Parameter b: Scale
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter mean is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x <= 0 {
                return 0
            }
            else {
                let expr1: FPT = 2 * FPT.pi * x * x * x
                let expr2: FPT = (b * x) / (2 * a * a)
                let expr3: FPT = b / (x + x)
                let expr4: FPT = b / a
                return sqrt(b / expr1) * SSMath.exp1(expr4 - expr3 - expr2 )
            }
        }
        
        /// Returns the cdf of the Wald (inverse normal) distribution.
        /// - Parameter x: x
        /// - Parameter a: mean
        /// - Parameter b: Scale
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter mean is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            ex1 = b / x
            ex2 = x / a
            ex3 = sqrt(ex1) * (ex2 - FPT.one)
            let n1: FPT = SSProbDist.StandardNormal.cdf(u: ex3)
            ex4 = sqrt(ex1) * (ex2 + FPT.one)
            let n2: FPT = SSProbDist.StandardNormal.cdf(u: -ex4)
            let result: FPT = n1 + SSMath.exp1(2 * b / a) * n2
            return result
        }
        
        /// Returns the quantile of the Wald (inverse normal) distribution.
        /// - Parameter p: p
        /// - Parameter a: mean
        /// - Parameter b: Scale
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, mean a: FPT, lambda b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter mean is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0 || p > 1 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0 and <= 1 ", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            
            if abs(p - 1) <= FPT.ulpOfOne {
                return FPT.infinity
            }
            if (abs(p) <= FPT.leastNormalMagnitude) {
                return 0
            }
            var wVal: FPT
            var MaxW: FPT
            var MinW: FPT
            MaxW = 99999
            MinW = 0
            wVal = p * a * b
            var pVal: FPT
            var i: Int = 0
            while (MaxW - MinW) >  Helpers.makeFP(1.0E-16) {
                do {
                    pVal = try cdf(x: wVal, mean: a, lambda: b)
                }
                catch {
                    return FPT.nan
                }
                if pVal > p {
                    MaxW = wVal
                }
                else {
                    MinW = wVal
                }
                wVal = (MaxW + MinW) *  Helpers.makeFP(0.5 )
                i = i + 1
                if  i >= 500 {
                    break
                }
            }
            return wVal
        }
    }
}
