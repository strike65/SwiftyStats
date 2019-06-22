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
    public enum Weibull {
        // MARK: Weibull
        
        /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Weibull distribution.
        /// - Parameter a: Location parameter
        /// - Parameter b: Scale parameter
        /// - Parameter c: Shape parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(location loc: FPT, scale: FPT, shape: FPT) throws -> SSContProbDistParams<FPT> {
            if (scale <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (shape <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
            result.mean = loc + scale * SSMath.tgamma1(1 + (1 / shape))
            var a: FPT = SSMath.tgamma1(FPT.one + 2 / shape)
            var b: FPT = SSMath.tgamma1(FPT.one + FPT.one / shape)
            var c: FPT = SSMath.pow1(b, 2)
            result.variance = SSMath.pow1(scale, 2) * (a - SSMath.pow1(b, 2))
            //    result.variance = SSMath.pow1(scale, 2) * (SSMath.tgamma1(1 + 2 / shape) - SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 2))
            a = -3 * SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 4)
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            var ex6: FPT
            ex1 = FPT.one + SSMath.reciprocal(shape)
            ex2 = SSMath.tgamma1(ex1)
            ex3 = SSMath.pow1(ex2, 2)
            ex4 = 2 * SSMath.reciprocal(shape)
            ex5 = FPT.one + ex4
            ex6 = SSMath.tgamma1(ex5)
            b = 6 * ex3 * ex6
            //    b = 6 * SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 2) * SSMath.tgamma1(1 + 2 / shape)
            ex4 = 3 * SSMath.reciprocal(shape)
            ex5 = FPT.one + ex4
            ex6 = SSMath.tgamma1(ex5)
            c = -4 * ex2 * ex6
            //    c = -4 * SSMath.tgamma1(1 + 1 / shape) * SSMath.tgamma1(1 + 3 / shape)
            var d: FPT = SSMath.tgamma1(1 + 4 / shape)
            ex1 = SSMath.tgamma1(FPT.one + 2 / shape)
            ex2 = SSMath.tgamma1(FPT.one + SSMath.reciprocal(shape))
            let e: FPT = ex1 - SSMath.pow1(ex2, 2)
            //    let e: FPT = SSMath.tgamma1(1 + 2 / shape) - SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 2)
            result.kurtosis = (a + b + c + d) / SSMath.pow1(e, 2)
            
            a = 2 * SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 3)
            ex4 = 2 * SSMath.reciprocal(shape)
            ex5 = FPT.one + ex4
            ex6 = SSMath.tgamma1(ex5)
            b = -3 * ex2 * ex6
            //    b = -3 * SSMath.tgamma1(1 + 1 / shape) * SSMath.tgamma1(1 + 2 / shape)
            c = SSMath.tgamma1(1 + 3 / shape)
            d = ex6 - ex3
            //    d = SSMath.tgamma1(1 + 2 / shape) - SSMath.pow1(SSMath.tgamma1(1 + 1 / shape), 2)
            result.skewness = (a + b + c) / SSMath.pow1(d,  Helpers.makeFP(1.5))
            return result
        }
        
        /// Returns the pdf of the Weibull distribution.
        /// - Parameter x: x
        /// - Parameter a: Location parameter
        /// - Parameter b: Scale parameter
        /// - Parameter c: Shape parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x < a {
                return 0
            }
            let ex1: FPT = (x - a) / b
            let ex2: FPT = SSMath.pow1(ex1, c - FPT.one)
            let ex3: FPT = FPT.minusOne * SSMath.pow1(ex1, c)
            let ex4: FPT = c / b
            let result = ex4 * ex2 * SSMath.exp1(ex3)
            //    let result = c / b * SSMath.pow1((x - a) / b, c - 1) * SSMath.exp1(-SSMath.pow1((x - a) / b, c))
            return result
        }
        
        /// Returns the cdf of the Weibull distribution.
        /// - Parameter x: x
        /// - Parameter a: Location parameter
        /// - Parameter b: Scale parameter
        /// - Parameter c: Shape parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x < a {
                return 0
            }
            let result = 1 - SSMath.exp1(-SSMath.pow1((x - a) / b, c))
            return result
        }
        
        /// Returns the quantile of the Weibull distribution.
        /// - Parameter p: p
        /// - Parameter a: Location parameter
        /// - Parameter b: Scale parameter
        /// - Parameter c: Shape parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, location a: FPT, scale b: FPT, shape c: FPT) throws -> FPT {
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("scale parameter b is expected to be > 0", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("shape parameter c is expected to be > 0", log: log_stat, type: .error)
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
                return a
            }
            if p == 1 {
                return FPT.infinity
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = -SSMath.log1p1((FPT.one - p) - FPT.one)
            ex2 = SSMath.pow1(ex1, SSMath.reciprocal(c))
            ex3 = b * ex2
            let result = a + ex3
            return result
        }
        
    }
}

