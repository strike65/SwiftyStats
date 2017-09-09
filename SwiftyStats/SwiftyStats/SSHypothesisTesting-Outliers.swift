//
//  SSHypothesisTesting-Outliers.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 20.07.17.
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
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public class func grubbsTest<T>(array: Array<T>!, alpha: Double!) throws -> SSGrubbsTestResult? where T: Comparable, T: Hashable {
        if array.count == 3 {
            os_log("sample size is expected to be >= 3", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if alpha <= 0 || alpha >= 1.0 {
            os_log("Alpha must be > 0.0 and < 1.0", log: log_stat, type: .error)
            return nil
        }
        if !isNumber(array[0]) {
            os_log("expected numerical type", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            let examine = SSExamine<T>.init(withArray: array, name: nil, characterSet: nil)
            return try SSHypothesisTesting.grubbsTest(data: examine, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /************************************************************************************************/
    // MARK: Grubbs test
    
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public class func grubbsTest<T>(data: SSExamine<T>!, alpha: Double!) throws -> SSGrubbsTestResult where T: Comparable, T: Hashable {
        if data.sampleSize <= 3 {
            os_log("sample size is expected to be >= 3", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if alpha <= 0 || alpha >= 1.0 {
            os_log("Alpha must be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !data.isNumeric {
            os_log("expected numerical type", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        //        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        var g: Double
        var maxDiff = 0.0
        let mean = data.arithmeticMean!
        let quantile: Double
        var mi: Double, ma: Double
        if let s = data.standardDeviation(type: .unbiased) {
            ma = castValueToDouble(data.maximum!)!
            mi = castValueToDouble(data.minimum!)!
            maxDiff = maximum(fabs(ma - mean), fabs(mi - mean))
            g = maxDiff / s
            do {
                quantile = try SSProbabilityDistributions.quantileStudentTDist(p: alpha / (2.0 * Double(data.sampleSize)), degreesOfFreedom: Double(data.sampleSize) - 2.0)
            }
            catch {
                throw error
            }
            let t2 = pow(quantile, 2.0)
            let t = ( Double(data.sampleSize) - 1.0 ) * sqrt(t2 / (Double(data.sampleSize) - 2.0 + t2)) / sqrt(Double(data.sampleSize))
            var res:SSGrubbsTestResult = SSGrubbsTestResult()
            res.sampleSize = data.sampleSize
            res.maxDiff = maxDiff
            res.largest = castValueToDouble(data.maximum!)
            res.smallest = castValueToDouble(data.minimum!)
            res.criticalValue = t
            res.mean = mean
            res.G = g
            res.stdDev = s
            res.hasOutliers = g > t
            return res
        }
        else {
            return SSGrubbsTestResult()
        }
    }
    
    /************************************************************************************************/
    // MARK: ESD test
    
    /// Returns p for run i
    fileprivate class func rosnerP(alpha: Double!, sampleSize: Int!, run i: Int!) -> Double! {
        return 1.0 - ( alpha / ( 2.0 * (Double(sampleSize) - Double(i) + 1.0 ) ) )
    }
    
    fileprivate class func rosnerLambdaRun(alpha: Double!, sampleSize: Int!, run i: Int!) -> Double! {
        let p = rosnerP(alpha: alpha, sampleSize: sampleSize, run: i)
        let df = Double(sampleSize - i) - 1.0
        let cdfStudentT: Double
        do {
            cdfStudentT = try SSProbabilityDistributions.quantileStudentTDist(p: p, degreesOfFreedom: df)
        }
        catch {
            return Double.nan
        }
        let num = Double(sampleSize - i) * cdfStudentT
        let denom = sqrt((Double(sampleSize - i) - 1.0 + pow(cdfStudentT, 2.0 ) ) * ( df + 2.0 ) )
        return num / denom
    }
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test is more accurate than the Grubbs test (for Grubbs test the suspected number of outliers must be specified exactly.)
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public class func esdOutlierTest(array: Array<Double>, alpha: Double!, maxOutliers: Int!, testType: SSESDTestType) -> SSESDTestResult? {
        if array.count == 0 {
            return nil
        }
        if maxOutliers >= array.count {
            return nil
        }
        let examine: SSExamine<Double> = SSExamine<Double>.init(withArray: array, name: nil, characterSet: nil)
        return SSHypothesisTesting.esdOutlierTest(data: examine, alpha: alpha, maxOutliers: maxOutliers, testType: testType)
    }
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test is more accurate than the Grubbs test (for Grubbs test the suspected number of outliers must be specified exactly.)
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public class func esdOutlierTest(data: SSExamine<Double>, alpha: Double!, maxOutliers: Int!, testType: SSESDTestType) -> SSESDTestResult? {
        if data.sampleSize == 0 {
            return nil
        }
        if maxOutliers >= data.sampleSize {
            return nil
        }
        let examine = data
        var sortedData = examine.elementsAsArray(sortOrder: .ascending)!
        // var dataRed: Array<Double> = Array<Double>()
        let orgMean: Double = examine.arithmeticMean!
        let sd: Double = examine.standardDeviation(type: .unbiased)!
        var maxDiff: Double = 0.0
        var difference: Double = 0.0
        var currentMean = orgMean
        var currentSd = sd
        var currentTestStat = 0.0
        var currentLambda: Double
        var itemToRemove: Double
        var itemsRemoved: Array<Double> = Array<Double>()
        var means: Array<Double> = Array<Double>()
        var stdDevs: Array<Double> = Array<Double>()
        let currentData: SSExamine<Double> = SSExamine<Double>()
        var currentIndex: Int = 0
        var testStats: Array<Double> = Array<Double>()
        var lambdas: Array<Double> = Array<Double>()
        currentData.append(contentOf: sortedData)
        var i: Int = 0
        var k: Int = 1
        var t: Double
        while k <= maxOutliers {
            i = 0
            while i <= (sortedData.count - 1) {
                t = sortedData[i]
                currentMean = currentData.arithmeticMean!
                difference = fabs(t - currentMean)
                if difference > maxDiff {
                    switch testType {
                    case .bothTails:
                        maxDiff = difference
                        currentIndex = i
                    case .lowerTail:
                        if t < currentMean {
                            maxDiff = difference
                            currentIndex = i
                        }
                    case .upperTail:
                        if t > currentMean {
                            maxDiff = difference
                            currentIndex = i
                        }
                    }
                }
                i = i + 1
            }
            itemToRemove = sortedData[currentIndex]
            currentSd = currentData.standardDeviation(type: .unbiased)!
            currentMean = currentData.arithmeticMean!
            currentTestStat = maxDiff / currentSd
            currentLambda = rosnerLambdaRun(alpha: alpha, sampleSize: examine.sampleSize, run: k)
            sortedData.remove(at: currentIndex)
            currentData.removeAll()
            currentData.append(contentOf: sortedData)
            testStats.append(currentTestStat)
            lambdas.append(currentLambda)
            itemsRemoved.append(itemToRemove)
            means.append(currentMean)
            stdDevs.append(currentSd)
            maxDiff = 0.0
            difference = 0.0
            k = k + 1
        }
        var countOfOL = 0
        var outliers: Array<Double> = Array<Double>()
        i = maxOutliers
        for i in stride(from: maxOutliers - 1, to: 0, by: -1) {
            if testStats[i] > lambdas[i] {
                countOfOL = i + 1
                break
            }
        }
        i = 0
        while i < countOfOL {
            outliers.append(itemsRemoved[i])
            i = i + 1
        }
        var res = SSESDTestResult()
        res.alpha = alpha
        res.countOfOutliers = countOfOL
        res.itemsRemoved = itemsRemoved
        res.lambdas = lambdas
        res.maxOutliers = maxOutliers
        res.means = means
        res.outliers = outliers
        res.stdDeviations = stdDevs
        res.testStatistics = testStats
        res.testType = testType
        return res
    }
}
