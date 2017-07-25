//
//  SSSSHypothesisTesting.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 20.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
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

public class SSHypothesisTesting {
    
    // MARK: Grubbs test
    
    /// Performs the Grubbs outlier test
    /// - Parameter data: An Array<Double> containing the data
    /// - Parameter alpha: Alpha
    /// - Returns: SSGrubbsTestResult
    public class func grubbsTest(data: Array<Double>, alpha: Double!) -> SSGrubbsTestResult? {
        if data.count == 0 {
            return nil
        }
        if alpha <= 0 || alpha >= 1.0 {
            os_log("Alpha must be > 0.0 and < 1.0", log: log_stat, type: .error)
            return nil
        }
        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        var g: Double
        var maxDiff = 0.0
        let mean = examine.arithmeticMean
        let quantile: Double
        if let s = examine.standardDeviation(type: .unbiased) {
            maxDiff = maximum(t1: fabs(examine.maximum! - mean), t2: fabs(examine.minimum! - mean))
            g = maxDiff / s
            do {
                quantile = try SSProbabilityDistributions.quantileStudentTDist(p: alpha / (2.0 * Double(examine.sampleSize)), degreesOfFreedom: Double(examine.sampleSize) - 2.0)
            }
            catch {
                return nil
            }
            let t2 = pow(quantile, 2.0)
            let t = ( Double(examine.sampleSize) - 1.0 ) * sqrt(t2 / (Double(examine.sampleSize) - 2.0 + t2)) / sqrt(Double(examine.sampleSize))
            var res:SSGrubbsTestResult = SSGrubbsTestResult()
            res.sampleSize = examine.sampleSize
            res.maxDiff = maxDiff
            res.largest = examine.maximum!
            res.smallest = examine.minimum!
            res.criticalValue = t
            res.mean = mean
            res.G = g
            res.stdDev = s
            res.hasOutliers = g > t
            return res
        }
        else {
            return nil
        }
    }

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
    
    
    /// Uses the Rosner test (generalized extreme Studentized deviate = ESD test) to detect up to maxOutliers outliers. This test ist more accurate than the Grubbs test (For Grubbs test the suspected number of outliers must be specified exactly.)
    /// - Parameter data: Array<Double>
    /// - Parameter alpha: Alpha
    /// - Parameter maxOutliers: Upper bound for the number of outliers to detect
    /// - Parameter testType: SSESDTestType.lowerTail or SSESDTestType.upperTail or SSESDTestType.bothTailes (This should be default.)
    public class func esdOutlierTest(data: Array<Double>, alpha: Double!, maxOutliers: Int!, testType: SSESDTestType) -> SSESDTestResult? {
        if data.count == 0 {
            return nil
        }
        if maxOutliers >= data.count {
            return nil
        }
        let examine = SSExamine<Double>.init(withArray: data, characterSet: nil)
        var sortedData = examine.elementsAsArray(sortOrder: .ascending)!
        // var dataRed: Array<Double> = Array<Double>()
        let orgMean: Double = examine.arithmeticMean
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
        currentData.append(fromArray: sortedData)
        var i: Int = 0
        var k: Int = 1
        var t: Double
        while k <= maxOutliers {
            i = 0
            while i <= (sortedData.count - 1) {
                t = sortedData[i]
                currentMean = currentData.arithmeticMean
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
            currentMean = currentData.arithmeticMean
            currentTestStat = maxDiff / currentSd
            currentLambda = rosnerLambdaRun(alpha: alpha, sampleSize: examine.sampleSize, run: k)
            sortedData.remove(at: currentIndex)
            currentData.removeAll()
            currentData.append(fromArray: sortedData)
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
        i = 0
        while i < testStats.count {
            if testStats[i] > lambdas[i] {
                countOfOL = countOfOL + 1
                break
            }
            countOfOL = countOfOL + 1
            i = i + 1
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
        res.name = "ESD outlier Test"
        res.outliers = outliers
        res.stdDeviations = stdDevs
        res.testStatistics = testStats
        res.testType = testType
        return res
    }
    
    // MARK: GoF test

    /// Performs the goodnes of fit test according to Kolmogorov and Smirnov
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    public class func ksGoFTest(data: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        // error handling
        if data.count < 2 {
            os_log("sample size is exptected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<Double>
        do {
            _data = try SSExamine<Double>.init(withObject: data, levelOfMeasurement: .interval, characterSet: nil)
        }
        catch {
            os_log("unable to create examine object", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sortedData = _data.uniqueElements(sortOrder: .ascending)! 
        var dz: Double = 0.0
        var dD: Double = 0.0
        var dtestCDF: Double = 0.0
        var dtemp1: Double = 0.0
        var dmax1n: Double = 0.0
        var dmax2n: Double = 0.0
        var dmax1p: Double = 0.0
        var dmax2p: Double = 0.0
        var dmaxn: Double = 0.0
        var dmaxp: Double = 0.0
        var dest1: Double = 0.0
        var dest2: Double = 0.0
        var dest3: Double = 0.0
        var ii: Int = 0
        var ik: Int = 0
        var bok: Bool = false
        var bok1 = true
        var nt: Double
        var ecdf: Dictionary<Double, Double> = Dictionary<Double,Double>()
        var lds: Double = 0.0
        switch target {
        case .gaussian:
            dest1 = _data.arithmeticMean
            if let test = _data.standardDeviation(type: .unbiased) {
                dest2 = test
            }
        case .exponential:
            dest3 = 0.0
            ik = 0
            for value in sortedData {
                if value <= 0 {
                    ik = ik + _data.frequency(item: value)
                    dest3 = Double(ik) * value
                }
            }
            for value in sortedData {
                if value < 0 {
                    lds = 0
                }
                else {
                    lds = lds + Double(_data.frequency(item: value)) / (Double(_data.sampleSize) - Double(ik))
                }
                ecdf[value] = lds
            }
            if lds == 0.0 || ik > (_data.sampleSize - 2) {
                bok1 = false
            }
            dest1 = (Double(_data.sampleSize) - Double(ik)) / (_data.total - dest3)
        case .uniform:
            dest1 = _data.minimum!
            dest2 = _data.maximum!
            ik = 0
        case .studentT:
            dest1 = Double(_data.sampleSize)
            ik = 0
        case .laplace:
            dest1 = _data.median!
            dest2 = _data.meanDeviation(fromReferencePoint: dest1)!
            ik = 0
        case .none:
            return nil
        }
        ii = 0
        for value in sortedData {
            switch target {
            case .gaussian:
                do {
                   dtestCDF = try SSProbabilityDistributions.cdfNormalDist(x: (value - dest1) / dest2, mean: 0, variance: 1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .exponential:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfExponentialDist(x: value, lambda: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .uniform:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfUniformDist(x: value, lowerBound: dest1, upperBound: dest2)
                    bok = true
                }
                catch {
                    throw error
                }
            case .studentT:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfStudentTDist(t: value, degreesOfFreedom: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .laplace:
                do {
                    dtestCDF = try SSProbabilityDistributions.cdfLaplaceDist(x: value, mean: dest1, scale: dest2)
                    bok = true
                }
                catch {
                    throw error
                }
            case .none:
                return nil
            }
            if bok {
                if target == .exponential {
                    dtemp1 = ecdf[value]! - dtestCDF
                }
                else {
//                    dtemp1 = _data.empiricalCDF(of: value) - dtestCDF
                    dtemp1 = _data.cumulativeRelativeFrequencies[value]! - dtestCDF
                }
                if dtemp1 > dmax1n {
                    dmax1n = dtemp1
                }
                if dtemp1 > dmax1p {
                    dmax1p = dtemp1
                }
                if ii > 0 {
                    nt = sortedData[ii - 1]
                    if target == .exponential {
                        dtemp1 = ecdf[nt]! - dtestCDF
                    }
                    else {
                        dtemp1 = _data.cumulativeRelativeFrequencies[value]! - dtestCDF
                    }
                }
                else {
                    dtemp1 = -dtestCDF
                }
                if dtemp1 > dmax2n {
                    dmax2n = dtemp1
                }
                if dtemp1 > dmax2p {
                    dmax2p = dtemp1
                }
            }
            ii = ii + 1
        }
        dmaxn = (fabs(dmax1n) > fabs(dmax2n)) ? dmax1n : dmax2n
        dmaxp = (dmax1p > dmax2p) ? dmax1p : dmax2p
        dD = (fabs(dmaxn) > fabs(dmaxp)) ? dmaxn : dmaxp
//        dD = maximum(t1: fabs(dmaxn), t2: fabs(dmaxp))
/*
 var dp: Double
        var dq: Double
        // according to Smirnov, not as accurate as possible but simple
        if (!dD.isNaN)
        {
            dz = sqrt(Double(_data.sampleSize - ik)) * dD
            dp = 0.0
            if ((dz >= 0) && (dz < 0.27)) {
                dp = 1.0
            }
            else if ((dz >= 0.27) && (dz < 1.0)) {
                dq = exp(-1.233701 * pow(dz, -2.0))
                dp = 1.0 - ((2.506628 * (dq + pow(dq, 9.0) + pow(dq, 25.0))) / dz)
            }
            else if ((dz >= 1.0) && (dz < 3.1)) {
                dq = exp(-2.0 * pow(dz, 2.0))
                dp = 2.0 * (dq - pow(dq, 4.0) + pow(dq, 9.0) - pow(dq, 16.0))
            } else if (dz > 3.1) {
                dp = 0.0
            }
        }
        else {
            dp = Double.nan
        }
 */
        var dp: Double = 1.0 - KScdf(n: _data.sampleSize, x: dD)
        var result = SSKSTestResult()
        switch target {
        case .gaussian:
            result.targetDistribution = .gaussian
            result.estimatedMean = dest1
            result.estimatedSd = dest2
            result.estimatedVar = dest2 * dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize

        case .exponential:
            result.targetDistribution = .exponential
            if bok1 {
                result.estimatedMean = 1.0 / dest1
            }
            if ik > 0 {
                result.infoString = "\(ik) elements skipped. User result with care!"
            }
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .uniform:
            result.estimatedLowerBound = dest1
            result.estimatedUpperBound = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .studentT:
            result.estimatedDegreesOfFreedom = dest1
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .laplace:
            result.estimatedMean = dest1
            result.estimatedShapeParam = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = _data.sampleSize
        case .none:
            break
        }
        return result
    }
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
