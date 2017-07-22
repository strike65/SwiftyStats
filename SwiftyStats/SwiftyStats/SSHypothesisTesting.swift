//
//  SSSSHypothesisTesting.swift
//  SwiftyStats
//
//  Created by volker on 20.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

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
        if let s = examine.standardDeviation(type: .unbiased) {
            maxDiff = maximum(t1: fabs(examine.maximum! - mean), t2: fabs(examine.minimum! - mean))
            g = maxDiff / s
            let t2 = pow(SSProbabilityDistributions.quantileStudentTDist(p: alpha / (2.0 * Double(examine.sampleSize)), degreesOfFreedom: Double(examine.sampleSize) - 2.0), 2.0)
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
        let cdfStudent = SSProbabilityDistributions.quantileStudentTDist(p: p, degreesOfFreedom: df)
        let num = Double(sampleSize - i) * cdfStudent
        let denom = sqrt((Double(sampleSize - i) - 1.0 + pow( cdfStudent, 2.0 ) ) * ( df + 2.0 ) )
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
    
}
