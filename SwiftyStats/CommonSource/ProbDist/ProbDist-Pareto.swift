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
    /// Pareto distribution
    public enum Pareto {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Pareto distribution.
        /// - Parameter a: minimum
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(minimum a: FPT, shape b: FPT) throws -> SSProbDistParams<FPT> {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("minimum parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if b > 1 {
                result.mean = (a * b) / (b - 1)
            }
            else {
                result.mean = FPT.nan
            }
            if b > 2 {
                let v1 = (a * a * b )
                let v2 = (b - 2)
                let v3 = (b - 1)
                let v4 = (b - 1)
                result.variance = v1 / ( v2 * v3 * v4 )
            }
            else {
                result.variance = FPT.nan
            }
            if b > 4 {
                let b2: FPT = b * b
                let b3: FPT = (-15 + 9 * b)
                let b4: FPT = (-4 + b) * (-3 + b)
                let temp: FPT = (-12 + b2 * b3 ) / (b4 * b)
                result.kurtosis = temp
            }
            else {
                result.kurtosis = FPT.nan
            }
            if b > 3 {
                let s1: FPT = sqrt((-2 + b) / b)
                let s2: FPT = (1 + b)
                let s3: FPT = (b - 3)
                result.skewness = (2 * s1 * s2) / s3
            }
            else {
                result.skewness = FPT.nan
            }
            return result
        }
        
        /// Returns the pdf of the Pareto distribution.
        /// - Parameter x: x
        /// - Parameter a: minimum
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("minimum parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x < a {
                return 0
            }
            let a1: FPT = SSMath.pow1(a, b)
            let a2: FPT = a1 * b
            let result: FPT = a2 * SSMath.pow1(x, -1 - b)
            return result
        }
        
        /// Returns the cdf of the Pareto distribution.
        /// - Parameter x: x
        /// - Parameter a: minimum
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("minimum parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x <= a {
                return 0
            }
            else {
                return 1 - SSMath.pow1(a / x, b)
            }
        }
        
        
        /// Returns the quantile of the Pareto distribution.
        /// - Parameter p: p
        /// - Parameter a: minimum
        /// - Parameter b: Shape parameter b
        /// - Throws: SSSwiftyStatsError if b <= 0 || a <= 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, minimum a: FPT, shape b: FPT) throws -> FPT {
            if (a <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("minimum parameter a is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (b <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("shape parameter b is expected to be > 0", log: .log_stat, type: .error)
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
            if p.isZero {
                return a
            }
            else if p == 1 {
                return FPT.infinity
            }
            else {
                return a * SSMath.pow1(1 - p, -1 / b)
            }
        }
    }
}

