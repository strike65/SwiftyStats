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
    /// von Mises (circular) distribution
    public enum VonMises {

        /// Returns a SSProbDistParams struct containing mean, variance, kurtosis and skewness of the the von Mises distribution.
        /// - Parameter x: x
        /// - Parameter m: mean
        /// - Parameter c: direction
        /// - Throws: SSSwiftyStatsError if c <= 0
        public static func para<FPT: SSFloatingPoint & Codable>(mean m: FPT, concentration c: FPT) throws -> SSProbDistParams<FPT> {
            var result: SSProbDistParams<FPT> = SSProbDistParams<FPT>()
            if c <= 0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Concentration parameter is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            result.mean = m
            result.variance = 1 - SSSpecialFunctions.besselI1(x: c) / SSSpecialFunctions.besselI0(x: c)
            result.skewness = FPT.nan
            result.kurtosis = FPT.nan
            return result
        }
        
        /// Returns the pdf of the von Mises distribution
        /// - Parameter x: x
        /// - Parameter m: mean
        /// - Parameter c: direction
        /// - Throws: SSSwiftyStatsError if c <= 0
        public static func pdf(x: Double!, mean m: Double!, concentration c: Double!) throws -> Double {
            if c <= 0.0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Concentration parameter is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var xx: Double
            xx = x - m + Double.pi
            let mm = Double.pi
            var _res: Double
            if xx >= 0 && xx <= 2.0 * Double.pi {
                if ((fabs(c) <= Double.leastNonzeroMagnitude || fabs(c) <= Double.ulpOfOne)) {
                    return Double.oopi
                }
                _res = exp(c * cos(mm - xx)) / (Double.twopi * SSSpecialFunctions.besselI0(x: c))
            }
            else {
                _res = 0.0
            }
            return _res
        }
        
        
        fileprivate static func d_modp(x: Double, y: Double) -> Double {
            var value: Double
            if y.isZero {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("d_modp: second argument expected to be > 0", log: .log_stat, type: .error)
                }
                #endif
                printError("d_modp: second argument expected to be > 0")
                return Double.nan
            }
            value = x - Double(Int(x / y)) * y
            if value < 0.0 {
                value = fabs(y) + value
            }
            return value
        }
        
        
        private static func integrandVonMises(x: Double!, mean: Double!, concentration: Double!, pß: Double!, p1: Double!) -> Double {
            return try! pdf(x: x, mean: mean, concentration: concentration)
        }
        
        /// Returns the cdf of the von Mises distribution
        /// - Parameter x: x
        /// - Parameter m: mean
        /// - Parameter c: direction
        /// - Parameter useExpIntegration: If true, use the double exponential rule to integrate the pdf
        /// - Throws: SSSwiftyStatsError if c <= 0
        public static func cdf(x: Double!, mean m: Double!, concentration c: Double!, useExpIntegration: Bool = false) throws -> Double {
            if c <= 0.0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Concentration parameter is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            var _result, xx, aa: Double
            // map to [0;2 Pi]
            xx = x - m + Double.pi
            aa = Double.pi
            
            if ( xx < 0 ) {
                _result = 0.0
            }
            else if ( xx > (2.0 * Double.pi) ) {
                _result = 1.0
            }
            else {
                if useExpIntegration {
                    var eval: Int = 0
                    var error: Double = 0.0
                    _result = SSMath.integrate(integrand: integrandVonMises, parameters: [aa, c, 0.0, 0.0], leftLimit: 0, rightLimit: xx, maxAbsError: 1E-14, numberOfEvaluations: &eval, estimatedError: &error)
                    print("error: \(error)")
                }
                else {
                    let a1 = 12.0
                    let a2 = 0.8
                    let a3 = 8.0
                    let a4 = 1.0
                    let c1 = 56.0
                    let ck = 10.5
                    var cdf, arg, cc, cn, erfx, p, r, s, sn, u, v, y, z: Double
                    var ip: Int
                    //
                    //  We expect -PI <= X - A <= PI.
                    //
                    if ( xx - aa <= -Double.pi ) {
                        cdf = 0.0
                        return cdf
                    }
                    
                    if ( Double.pi <= xx - aa ) {
                        cdf = 1.0
                        return cdf
                    }
                    //
                    //  Convert the angle (X - A) modulo 2 PI to the range ( 0, 2 * PI ).
                    //
                    z = c
                    
                    u = d_modp(x: xx - aa + Double.pi, y: 2.0 * Double.pi)
                    
                    if ( u < 0.0 ) {
                        u = u + 2.0 * Double.pi
                    }
                    
                    y = u - Double.pi
                    //
                    //  For small B, sum IP terms by backwards recursion.
                    //
                    if ( z <= ck ) {
                        v = 0.0
                        
                        if ( 0.0 < z ) {
                            ip = Int( z * a2 - a3 / ( z + a4 ) + a1 )
                            p = Double( ip )
                            s = sin( y )
                            cc = cos( y )
                            y = p * y
                            sn = sin( y )
                            cn = cos( y )
                            r = 0.0
                            z = 2.0 / z
                            for _ in stride(from: 2, through: ip, by: 1) {
                                p = p - 1.0
                                y = sn
                                sn = sn * cc - cn * s
                                cn = cn * cc + y * s
                                r = 1.0 / ( p * z + r )
                                v = ( sn / p + v ) * r
                            }
                        }
                        cdf = ( u * 0.5 + v ) / Double.pi
                    }
                        //
                        //  For large B, compute the normal approximation and left tail.
                        //
                    else
                    {
                        cc = 24.0 * z
                        v = cc - c1
                        r = sqrt( ( 54.0 / ( 347.0 / v + 26.0 - cc ) - 6.0 + cc ) / 12.0 )
                        z = sin( 0.5 * y ) * r
                        s = 2.0 * z * z
                        v = v - s + 3.0
                        y = ( cc - s - s - 16.0 ) / 3.0
                        y = ( ( s + 1.75 ) * s + 83.5 ) / v - y
                        arg = z * ( 1.0 - s / y / y )
                        erfx = erf( arg )
                        cdf = 0.5 * erfx + 0.5
                    }
                    
                    cdf = max( cdf, 0.0 )
                    cdf = min( cdf, 1.0 )
                    _result = cdf
                }
            }
            return _result
        }
        
        /// Returns the quantile function of the von Mises distribution
        ///  adapted from: http://rapidq.phatcode.net/examples/Math
        /// - Parameter p: p
        /// - Parameter m: Mean
        /// - Parameter c: concentration
        /// - Throws: SSSwiftyStatsError if c <= 0 or/and p < 0 or p > 1.0
        public static func quantile(p: Double!, mean m: Double!, concentration c: Double!) throws -> Double {
            if c <= 0.0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Concentration parameter is expected to be > 0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            if p < 0.0 || p > 1.0 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("p is expected to be >= 0.0 and <= 1.0", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
            }
            /* adapted from: http://rapidq.phatcode.net/examples/Math/ProbDists.rqb
             * coded in C by Gary Perlman
             * coded in Basic by Michaek Zito 2003
             * coded in C# by strike65 2005
             */
            let eps: Double = 2.0 * Double.ulpOfOne
            var mVal, MaxM, MinM, _test: Double
            MaxM = Double.twopi
            MinM = 0
            if(p < 0) {
                return(0.0)
            }
            if (p == 0) {
                return m - Double.pi
            }
            if(p == 1.0) {
                return m + Double.pi
            }
            mVal = m - Double.pi
            while((MaxM - MinM) > eps)
            {
                do {
                    _test = try cdf(x: mVal, mean: m, concentration: c)
                }
                catch {
                    throw error
                }
                if(_test > p) {
                    MaxM = mVal
                }
                else {
                    MinM = mVal
                }
                mVal = (MaxM + MinM) * 0.5
            }
            return(mVal);
        }
    }
    
}
