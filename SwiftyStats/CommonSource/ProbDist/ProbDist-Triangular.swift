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
    enum Triangular {
        
        // MARK: TRIANGULAR
        
        /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Parameter c: Mode
        /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
        public static func para<FPT: SSFloatingPoint & Codable>(lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> SSContProbDistParams<FPT> {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= a) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
            result.mean = (a + b + c) / 3
            result.kurtosis =  Helpers.makeFP(2.4)
            let a2: FPT = a * a
            let ab: FPT = a * b
            let b2: FPT = b * b
            let ac: FPT = a * c
            let bc: FPT = b * c
            let c2: FPT = c * c
            let a3: FPT = a2 * a
            let b3: FPT = b2 * b
            let c3: FPT = c2 * c
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            ex1 = a2 - ab
            ex2 = ex1 + b2 - ac
            ex3 = ex2 - bc + c2
            result.variance = ex3 /  Helpers.makeFP(18)
            let s1: FPT = 2 * a3
            let s2: FPT = 3 * a2 * b
            let s3: FPT = 3 * a * b2
            let s4: FPT = 2 * b3
            let s5: FPT = 3 * a3 * c
            let s6: FPT = 12 * ab * c
            let s7: FPT = 3 * b2 * c
            let s8: FPT = 3 * a * c2
            let s9: FPT = 3 * b * c2
            let s10: FPT = 2 * c3
            ex1 = a2 - ab
            ex2 = ex1 + b2 - ac
            ex3 = ex2 - bc + c2
            let s11: FPT = ex3
            let s12: FPT = s1 - s2 - s3 + s4 - s5
            ex1 = s12 + s6
            ex2 = ex1 - s7 - s8
            ex3 = ex2 - s9 + s10
            let ss1: FPT = ex3
            result.skewness = (FPT.sqrt2 * ss1) / (5 * SSMath.pow1(s11,  Helpers.makeFP(1.5)))
            //        result.var skewness:FPT = (SQRTTWO * ( 2.0 * a3 - 3.0 * a2 * b - 3.0 * a * b2 + 2.0 * b3 - 3.0 * a3 * c + 12.0 * a * b * c - 3.0 * b2 * c - 3.0 * a * c2 - 3.0 * b * c2 + 2.0 * c3)) / (5.0 * pow(a2 - a * b + b2 - a * c - b * c + c2, 1.5))
            return result
        }
        
        /// Returns the pdf of the Triangular distribution.
        /// - Parameter x: x
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Parameter c: Mode
        /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= a) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if ((x < a) || (x > b)) {
                return 0
            }
            else if ((x == a) || ((x > a) && (x <= c))) {
                let s1 = (2 * ( x - a))
                let s2 = (a - b - c)
                return s1 / (a * s2 + b * c)
            }
            else {
                let s1 = (2 * (b - x))
                let s2 = (-a + b - c)
                return s1 / (b * s2 + a * c)
            }
        }
        
        /// Returns the cdf of the Triangular distribution.
        /// - Parameter x: x
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Parameter c: Mode
        /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= a) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            var ex4: FPT
            var ex5: FPT
            if (x < a) {
                return 0
            }
            else if (x > b) {
                return 1
            }
            else if ((x > a) || (x == a)) && ((x < c) || (x == c)) {
                ex1 = b - a
                ex2 = c - a
                ex3 = ex1 * ex2
                ex4 = x - a
                return SSMath.pow1(ex4,2) / ex3
                //        return SSMath.pow1(x - a, 2) / ((b - a) * (c - a))
            }
            else {
                ex1 = b - x
                ex2 = b - a
                ex3 = b - c
                ex4 = ex2 * ex3
                ex5 = SSMath.pow1(ex1, 2) / ex4
                return FPT.one - ex5
                //        return 1 - SSMath.pow1(b - x, 2) / ((b - a) * (b - c))
            }
        }
        
        /// Returns the quantile of the Triangular distribution.
        /// - Parameter p: p
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Parameter c: Mode
        /// - Throws: SSSwiftyStatsError if a >= b || c <= a || c >= b || p < 0 || p > 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, lowerBound a: FPT, upperBound b: FPT, mode c: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c <= a) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be greater than lower bound", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if (c >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("mode parameter c is expected to be smaller than upper bound", log: log_stat, type: .error)
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
            let t1 = (-a + c) / (-a + b)
            if p <= t1 {
                let s1:FPT = (-a + b)
                let s2:FPT = (-a + c)
                let s3:FPT = sqrt(s1 * s2 * p)
                return a + s3
            }
            else {
                let s1 = (-a + b)
                let s2 = (b - c)
                let s3 = (1 - p)
                return b - sqrt(s1 * s2 * s3)
            }
        }
        
        // MARK: TRIANGULAR with two params
        
        /// Returns a SSContProbDistParams struct containing mean, variance, kurtosis and skewness of the Triangular distribution.
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Throws: SSSwiftyStatsError if a >= b
        public static func para<FPT: SSFloatingPoint & Codable>(lowerBound a: FPT, upperBound b: FPT) throws -> SSContProbDistParams<FPT> {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var result: SSContProbDistParams<FPT> = SSContProbDistParams<FPT>()
            result.mean = (a + b) / 2
            result.variance = 1 / 24 * (b - a) * (b - a)
            result.kurtosis =  Helpers.makeFP(2.4)
            result.skewness = 0
            return result
        }
        
        /// Returns the pdf of the Triangular distribution.
        /// - Parameter x: x
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Throws: SSSwiftyStatsError if a >= b
        public static func pdf<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            return try! pdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2)
        }
        
        /// Returns the cdf of the Triangular distribution.
        /// - Parameter x: x
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Throws: SSSwiftyStatsError if a >= b
        public static func cdf<FPT: SSFloatingPoint & Codable>(x: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            return try! cdfTriangularDist(x: x, lowerBound: a, upperBound: b, mode: (a + b) / 2)
        }
        
        /// Returns the quantile of the Triangular distribution.
        /// - Parameter p: p
        /// - Parameter a: Lower bound
        /// - Parameter b: Upper bound
        /// - Throws: SSSwiftyStatsError if a >= b || p < 0 || p > 0
        public static func quantile<FPT: SSFloatingPoint & Codable>(p: FPT, lowerBound a: FPT, upperBound b: FPT) throws -> FPT {
            if (a >= b) {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("lower bound a is expected to be greater than upper bound b", log: log_stat, type: .error)
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
            return try! quantileTriangularDist(p: p, lowerBound: a, upperBound: b, mode: (a + b) / 2)
        }
        
    }
}

