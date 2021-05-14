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
    /// Exponential distribution
    public enum Exponential {
        
        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the Exponential distribution.
        /// - Parameter l: Lambda
        /// - Throws: SSSwiftyStatsError if l <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(lambda l: FPT) throws -> SSProbDistParams<FPT> {
            if (l <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            result.mean = 1 / l
            result.variance = 1 / (l * l)
            result.kurtosis = 9
            result.skewness = 2
            return result
        }
        
        /// Returns the pdf of the Exponential distribution.
        /// - Parameter x: x
        /// - Parameter l: Lambda
        /// - Throws: SSSwiftyStatsError if l <= 0
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, lambda l: FPT) throws -> FPT {
            if (l <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x < 0 {
                return 0
            }
            else if x == 1 {
                return l
            }
            else {
                return l * SSMath.exp1(-l * x)
            }
        }
        
        /// Returns the cdf of the Exponential distribution.
        /// - Parameter x: x
        /// - Parameter l: Lambda
        /// - Throws: SSSwiftyStatsError if l <= 0
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, lambda l: FPT) throws -> FPT {
            if (l <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter lambda is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if x <= 0 {
                return 0
            }
            else {
                return 1 - SSMath.exp1(-l * x)
            }
        }
        
        /// Returns the quantile of the Exponential distribution.
        /// - Parameter p: p
        /// - Parameter l: Lambda
        /// - Throws: SSSwiftyStatsError if l <= 0 || p < 0 || p > 1
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, lambda l: FPT) throws -> FPT {
            if (l <= 0) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("parameter lambda is expected to be > 0", log: .log_stat, type: .error)
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
            else if p == 1 {
                return FPT.infinity
            }
            else {
                return -SSMath.log1(1 - p) / l
            }
        }
        
    }
}

