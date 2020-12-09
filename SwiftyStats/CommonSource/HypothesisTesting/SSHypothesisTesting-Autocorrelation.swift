//
//  SSHypothesisTesting-Autocorrelation.swift
//  SwiftyStats
//

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


extension SSHypothesisTesting {
    
    /// Autocorrelation coefficient
    ///
    /// - Parameters:
    ///   - array: Data
    ///   - lag: Lag
    /// - Returns: The autocorrelation coefficient for Lag `lag`
    /// - Throws: Throws SSSwiftyStatsError.invalidArgument if `array.count` < 2
    public static func autocorrelationCoefficient<FPT: SSFloatingPoint & Codable>(array: Array<FPT>, lag: Int) throws -> FPT {
        if array.count < 2 {
            #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
                }
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try autocorrelationCoefficient(data: SSExamine<FPT, FPT>.init(withArray: array, name: nil,  characterSet: nil), lag: lag)
        }
        catch {
            throw error
        }
    }
    
    
    /// Returns the autocorrelation coefficient for a particular lag
    /// - Parameter data: SSExamine object
    /// - Parameter lag: Lag
    /// - Returns: Autocorrelation coefficient for Lag `lag`
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public static func autocorrelationCoefficient<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>, lag: Int) throws -> FPT {
        if data.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var r: FPT
        var num: FPT = 0
        var den: FPT = 0
        let mean: FPT = data.arithmeticMean!
        var i: Int = 0
        let n = data.sampleSize
        let elements = data.elementsAsArray(sortOrder: .raw)!
        while i < n - 1 {
            num += (elements[i] - mean) * (elements[i + 1] - mean)
            i += 1
        }
        i = 0
        while i < n {
            den += SSMath.pow1(elements[i] - mean, 2)
            i += 1
        }
        r = num / den
        return r
    }
    
    
    /// Performs the Box-Ljung test for autocorrelation for all possible lags
    ///
    /// ### Usage ###
    ///
    ///     let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    ///     let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lew1)
    ///
    /// - Parameter data: Array<Double>
    /// - Returns: SSBoxLjungResult struct
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public static func autocorrelation<FPT: SSFloatingPoint & Codable>(array: Array<FPT>) throws -> SSBoxLjungResult<FPT> {
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<FPT, FPT>.init(withArray: array, name: nil,  characterSet: nil)
        do {
            return try autocorrelation(data: examine)
        }
        catch {
            throw error
        }
    }
    
    /// Performs a Box-Ljung test for autocorrelation for all possible lags
    ///
    /// ### Usage ###
    ///
    ///     let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    ///     let lewdat = SSExamine<Numeric, SSFloatingPoint>.init(withArray: lew1, characterSet: nil)
    ///     let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lewdat)
    ///
    /// - Parameter data: SSExamine object
    /// - Returns: SSBoxLjungResult struct
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public static func autocorrelation<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>) throws -> SSBoxLjungResult<FPT> {
        if data.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var acr: Array<FPT> = Array<FPT>()
        var serWhiteNoise: Array<FPT> = Array<FPT>()
        var serBartlett: Array<FPT> = Array<FPT>()
        var statBoxLjung: Array<FPT> = Array<FPT>()
        var sig: Array<FPT> = Array<FPT>()
        var r: FPT
        var num: FPT = 0
        var den: FPT = 0
        let mean: FPT = data.arithmeticMean!
        var i: Int = 0
        var k: Int = 0
        let n = data.sampleSize
        let nn: FPT =  Helpers.makeFP(n)
        let elements = data.elementsAsArray(sortOrder: .raw)!
        while i < n {
            den += SSMath.pow1(elements[i] - mean, 2)
            i += 1
        }
        var l = 0
        while l <= n - 2 {
            i = 0
            while i < n - l {
                num += (elements[i] - mean) * (elements[i + l] - mean)
                i += 1
            }
            r = num / den
            acr.append(r)
            num = 0
            l += 1
        }
        var sum: FPT = 0
        var comp: FPT = 0
        var oldsum: FPT = 0
        let nr: FPT = 1 / nn
        k = 0
        while k < acr.count {
            l = 1
            while l < k {
                oldsum = sum
                comp = comp + SSMath.pow1(acr[l], 2)
                sum = comp + oldsum
                comp = (oldsum - sum) + comp
                l += 1
            }
            serBartlett.append(nr * (1 + 2 * sum))
            sum = 0
            comp = 0
            oldsum = 0
            k += 1
        }
        serBartlett[0] = 0
        serWhiteNoise.append(0)
        statBoxLjung.append(FPT.infinity)
        sig.append(0)
        sum = 0
        comp = 0
        oldsum = 0
        let f = nn * (nn * 2)
        k = 1
        var kk: FPT = 0
        var ll: FPT = 0
        var ex1, ex2, ex3: FPT
        
        while k < acr.count {
            kk =  Helpers.makeFP(k)
            ex1 = nn - kk
            ex2 = ex1 / (nn + 2)
            ex3 = nr * ex2
            serWhiteNoise.append(ex3.squareRoot())
            l = 1
            while l <= k {
                ll =  Helpers.makeFP(l)
                ex1 = nn - ll
                oldsum = sum
                comp = comp + (SSMath.pow1(acr[l], 2) / ex1)
                sum = comp + oldsum
                comp = (oldsum - sum) + comp
                l += 1
            }
            statBoxLjung.append(f * sum)
            do {
                try sig.append(1 - SSProbDist.ChiSquare.cdf(chi: statBoxLjung[k], degreesOfFreedom: kk))
            }
            catch {
                throw error
            }
            sum = 0
            comp = 0
            oldsum = 0
            k += 1
        }
        var coeff: Dictionary<String, FPT> = Dictionary<String, FPT>()
        var bartlettStandardError: Dictionary<String, FPT> = Dictionary<String, FPT>()
        var pValues: Dictionary<String, FPT> = Dictionary<String, FPT>()
        var boxLjungStatistics: Dictionary<String, FPT> = Dictionary<String, FPT>()
        var whiteNoiseStandardError: Dictionary<String, FPT> = Dictionary<String, FPT>()
        i = 0
        while i < acr.count {
            coeff["\(i)"] = acr[i]
            i += 1
        }
        i = 0
        while i < serBartlett.count {
            bartlettStandardError["\(i)"] = serBartlett[i]
            i += 1
        }
        i = 0
        while i < sig.count {
            pValues["\(i)"] = sig[i]
            i += 1
        }
        i = 0
        while i < statBoxLjung.count {
            boxLjungStatistics["\(i)"] = statBoxLjung[i]
            i += 1
        }
        i = 0
        while i < serWhiteNoise.count {
            whiteNoiseStandardError["\(i)"] = serWhiteNoise[i]
            i += 1
        }
        var result = SSBoxLjungResult<FPT>()
        result.coefficients = acr
        result.seBartlett = serBartlett
        result.seWN = serWhiteNoise
        result.pValues = sig
        result.testStatistic = statBoxLjung
        return result
    }
    
}
