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
    /// Gamma distribution
    public enum Gamma {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Gamma distribution.
        /// - Parameter a: Shape parameter
        /// - Parameter b: Scale parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(shape a: FPT, scale b: FPT) throws -> SSProbDistParams<FPT> {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
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
            result.mean = a * b
            result.variance = a * b * b
            result.kurtosis = 3 + 6 / a
            result.skewness = 2 / sqrt(a)
            return result
        }
        
        
        /// Returns the pdf of the Gamma distribution.
        /// - Parameter x: x
        /// - Parameter a: Shape parameter
        /// - Parameter b: Scale parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
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
            if x <= 0 {
                return 0
            }
            else {
                let a1: FPT = -a * SSMath.log1(b)
                let a2: FPT = -x / b
                let a3: FPT = -1 + a
                ex1 = a1 + a2
                ex2 = ex1 + a3 * SSMath.log1(x)
                let a4: FPT = ex2 - SSMath.lgamma1(a)
                let result = SSMath.exp1(a4)
                return result
            }
        }
        
        /// Returns the cdf of the Gamma distribution.
        /// - Parameter x: x
        /// - Parameter a: Shape parameter
        /// - Parameter b: Scale parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
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
            if x < 0 {
                return 0
            }
            var cv: Bool = false
            let result = SSSpecialFunctions.gammaNormalizedP(x: x / b, a: a, converged: &cv)
            if cv {
                return result
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("unable to retrieve a result", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .maxNumberOfIterationReached, file: #file, line: #line, function: #function)
            }
        }
        
        /// Returns the quantile of the Gamma distribution.
        /// - Parameter p: p
        /// - Parameter a: Shape parameter
        /// - Parameter b: Scale parameter
        /// - Throws: SSSwiftyStatsError if a <= 0 || b <= 0 || p < 0 || p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, shape a: FPT, scale b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("scale parameter a is expected to be > 0", log: .log_stat, type: .error)
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
            if p == 0 {
                return 0
            }
            if p == 1 {
                return FPT.infinity
            }
            var gVal: FPT = 0
            var maxG: FPT = 0
            var minG: FPT = 0
            maxG = a * b + 4000
            minG = 0
            gVal = a * b
            var test: FPT
            var i = 1
            while((maxG - minG) >  Helpers.makeFP(1.0E-14)) {
                test = try! cdf(x: gVal, shape: a, scale: b)
                if test > p {
                    maxG = gVal
                }
                else {
                    minG = gVal
                }
                gVal = (maxG + minG) *  Helpers.makeFP(0.5 )
                i = i + 1
                if i >= 7500 {
                    break
                }
            }
            if((a * b) > 10000) {
                let t1: FPT = gVal *  Helpers.makeFP(1E07)
                let ri: FPT = floor(t1)
                let rd: FPT = ri /  Helpers.makeFP(1E07)
                return rd
            }
            else {
                return gVal
            }
        }
        
    }
}

