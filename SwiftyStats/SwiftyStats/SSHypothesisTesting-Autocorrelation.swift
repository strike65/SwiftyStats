//
//  SSHypothesisTesting-Autocorrelation.swift
//  SwiftyStats
//
//
//  Created by Volker Thieme on 19.08.17.
//

/*
 Copyright (c) 2017 Volker Thieme
 
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
import os.log

extension SSHypothesisTesting {
    /// Returns the autocorrelation coefficient for a particular lag
    /// - Parameter data: Array<Double> object
    /// - Parameter lag: Lag
    /// - Throws: SSSwiftyStatsError iff data.count < 2
    public class func autocorrelationCoefficient(array: Array<Double>!, lag: Int!) throws -> Double {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try autocorrelationCoefficient(data: SSExamine<Double>.init(withArray: array, name: nil,  characterSet: nil), lag: lag)
        }
        catch {
            throw error
        }
    }
    
    
    /// Returns the autocorrelation coefficient for a particular lag
    /// - Parameter data: SSExamine<Double> object
    /// - Parameter lag: Lag
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelationCoefficient(data: SSExamine<Double>!, lag: Int!) throws -> Double {
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var r: Double
        var num: Double = 0.0
        var den: Double = 0.0
        let mean: Double = data.arithmeticMean!
        var i: Int = 0
        let n = data.sampleSize
        let elements = data.elementsAsArray(sortOrder: .original)!
        while i < n - 1 {
            num += (elements[i] - mean) * (elements[i + 1] - mean)
            i += 1
        }
        i = 0
        while i < n {
            den += pow(elements[i] - mean, 2.0)
            i += 1
        }
        r = num / den
        return r
    }
    
    
    /// Performs a Box-Ljung test for autocorrelation for all possible lags
    ///
    /// ### Usage ###
    /// ````
    /// let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    /// let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lew1)
    /// ````
    /// - Parameter data: Array<Double>
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelation(array: Array<Double>!) throws -> SSBoxLjungResult {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<Double>.init(withArray: array, name: nil,  characterSet: nil)
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
    /// ````
    /// let lew1: Array<Double> = [-213,-564,-35,-15,141,115,-420]
    /// let lewdat = SSExamine<Double>.init(withArray: lew1, characterSet: nil)
    /// let result: SSBoxLjungResult = try! SSHypothesisTesting.autocorrelation(data:lewdat)
    /// ````
    /// - Parameter data: SSExamine object
    /// - Throws: SSSwiftyStatsError iff data.sampleSize < 2
    public class func autocorrelation(data: SSExamine<Double>!) throws -> SSBoxLjungResult {
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var acr = Array<Double>()
        var serWhiteNoise = Array<Double>()
        var serBartlett = Array<Double>()
        var statBoxLjung = Array<Double>()
        var sig = Array<Double>()
        var r: Double
        var num: Double = 0.0
        var den: Double = 0.0
        let mean: Double = data.arithmeticMean!
        var i: Int = 0
        var k: Int = 0
        let n = data.sampleSize
        let elements = data.elementsAsArray(sortOrder: .original)!
        while i < n {
            den += pow(elements[i] - mean, 2.0)
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
            num = 0.0
            l += 1
        }
        var sum = 0.0
        let nr = 1.0 / Double(n)
        k = 0
        while k < acr.count {
            l = 1
            while l < k {
                sum += pow(acr[l], 2.0)
                l += 1
            }
            serBartlett.append(nr * (1.0 + 2.0 * sum))
            sum = 0.0
            k += 1
        }
        serBartlett[0] = 0.0
        serWhiteNoise.append(0.0)
        statBoxLjung.append(Double.infinity)
        sig.append(0.0)
        sum = 0.0
        let f = Double(n) * (Double(n) * 2.0)
        k = 1
        while k < acr.count {
            serWhiteNoise.append(sqrt(nr * ((Double(n) - Double(k)) / (Double(n) + 2.0))))
            l = 1
            while l <= k {
                sum += sum + (pow(acr[l], 2.0) / (Double(n) - Double(l)))
                l += 1
            }
            statBoxLjung.append(f * sum)
            do {
                try sig.append(1.0 - SSProbabilityDistributions.cdfChiSquareDist(chi: statBoxLjung[k], degreesOfFreedom: Double(k)))
            }
            catch {
                throw error
            }
            sum = 0.0
            k += 1
        }
        var coeff: Dictionary<String, Double> = Dictionary<String, Double>()
        var bartlettStandardError: Dictionary<String, Double> = Dictionary<String, Double>()
        var pValues: Dictionary<String, Double> = Dictionary<String, Double>()
        var boxLjungStatistics: Dictionary<String, Double> = Dictionary<String, Double>()
        var whiteNoiseStandardError: Dictionary<String, Double> = Dictionary<String, Double>()
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
        var result = SSBoxLjungResult()
        result.coefficients = acr
        result.seBartlett = serBartlett
        result.seWN = serWhiteNoise
        result.pValues = sig
        result.testStatistic = statBoxLjung
        return result
    }

}
