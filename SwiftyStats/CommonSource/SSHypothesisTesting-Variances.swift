//
//  SSHypothesisTesting-Variances.swift
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
    
    /************************************************************************************************/
    // MARK: Equality of variances
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples as SSExamine objects
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func bartlettTest(data: Array<SSExamine<Double>>!, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        if data.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .raw)!)
            }
            else {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try bartlettTest(array: array, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func bartlettTest(array: Array<Array<Double>>!, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        var _N = 0.0
        var _pS = 0.0
        var _s1 = 0.0
        var _s2 = 0.0
        var _k = 0.0
        var _df = 0.0
        var _testStatisticValue = 0.0
        var _cdfChiSquare = 0.0
        var _cutoff90Percent = 0.0
        var _cutoff95Percent = 0.0
        var _cutoff99Percent = 0.0
        var _cutoffAlpha = 0.0
        var _data:Array<SSExamine<Double>> = Array<SSExamine<Double>>()
        var result: SSVarianceEqualityTestResult
        if array.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            _data.append(SSExamine<Double>.init(withArray: a, name: nil, characterSet: nil))
        }
        _k = Double(_data.count)
        for examine in _data {
            _N += Double(examine.sampleSize)
            if let v = examine.variance(type: .unbiased) {
                _s1 += (Double(examine.sampleSize) - 1.0) * log(v)
            }
            else {
                os_log("for at least one sample a variance is not obtainable", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        for examine in _data {
            _pS += (Double(examine.sampleSize) - 1.0) * examine.variance(type: .unbiased)! / (_N - _k)
            _s2 += 1.0 / (Double(examine.sampleSize) - 1.0)
        }
        _testStatisticValue = ((_N - _k) * log(_pS) - _s1) / (1.0 + (1.0 / (3.0 * (_k - 1.0))) * (_s2 - 1.0 / (_N - _k)))
        do {
            _cdfChiSquare = try SSProbabilityDistributions.cdfChiSquareDist(chi: _testStatisticValue, degreesOfFreedom: _k - 1.0)
            _cutoff90Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.9, degreesOfFreedom: _k - 1.0)
            _cutoff95Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.95, degreesOfFreedom: _k - 1.0)
            _cutoff99Percent = try SSProbabilityDistributions.quantileChiSquareDist(p: 0.99, degreesOfFreedom: _k - 1.0)
            _cutoffAlpha = try SSProbabilityDistributions.quantileChiSquareDist(p: 1.0 - alpha, degreesOfFreedom: _k - 1.0)
            _df = _k - 1.0
            result = SSVarianceEqualityTestResult()
            result.testStatistic = _testStatisticValue
            result.pValue = 1.0 - _cdfChiSquare
            result.cv90Pct = _cutoff90Percent
            result.cv95Pct = _cutoff95Percent
            result.cv99Pct = _cutoff99Percent
            result.cvAlpha = _cutoffAlpha
            result.df = _df
            result.equality = !(_cdfChiSquare > (1.0 - alpha))
            result.testType = .bartlett
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Levene / Brown-Forsythe test for two or more samples
    /// - Parameter data: Array containing SSExamine objects
    /// - Parameter testType: .median (Brown-Forsythe test), .mean (Levene test), .trimmedMean (10% trimmed mean)
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func leveneTest(data: Array<SSExamine<Double>>!, testType: SSLeveneTestType, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        if data.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<Double>> = Array<Array<Double>>()
        for examine in data {
            if !examine.isEmpty {
                array.append(examine.elementsAsArray(sortOrder: .raw)!)
            }
            else {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        do {
            return try leveneTest(array: array, testType: testType, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Levene / Brown-Forsythe test for two or more samples
    /// - Parameter data: Array containing samples
    /// - Parameter testType: .median (Brown-Forsythe test), .mean (Levene test), .trimmedMean (10% trimmed mean)
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public class func leveneTest(array: Array<Array<Double>>!, testType: SSLeveneTestType, alpha: Double!) throws -> SSVarianceEqualityTestResult? {
        var _N = 0.0
        var _s1: Double = 0.0
        var _s2: Double = 0.0
        var _t = 0.0
        var _zMean = 0.0
        var _cutoff90Percent: Double
        var _cutoff95Percent: Double
        var _cutoff99Percent: Double
        var _cdfFRatio: Double
        var _cutoffAlpha: Double
        var _testStatisticValue: Double
        var _variancesAreEqual = false
        var _ntemp: Double
        var _k: Double
        var _data: Array<SSExamine<Double>> = Array<SSExamine<Double>>()
        if array.count < 2 {
            os_log("number of samples is expected to be > 1", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            if array.count >= 2 {
                _data.append(SSExamine<Double>.init(withArray: a, name: nil, characterSet: nil))
            }
            else {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        _k = Double(_data.count)
        var _zi: Array<Double>
        var _zij: Array<Array<Double>>
        var _ni: Array<Double>
        var _y: Array<Array<Double>>
        var _means: Array<Double>
        var _temp: Array<Double>
        var i: Int
        var j: Int
        _ni = Array<Double>()
        _y = Array<Array<Double>>()
        _means = Array<Double>()
        do {
            for examine in _data {
                _ntemp = Double(examine.sampleSize)
                _N += _ntemp
                _ni.append(_ntemp)
                _y.append(examine.elementsAsArray(sortOrder: .raw)!)
                switch testType {
                case .mean:
                    if let m = examine.arithmeticMean {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                case .median:
                    if let m = examine.median {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                case .trimmedMean:
                    if let m = try examine.trimmedMean(alpha: 0.1) {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                }
            }
            _zi = Array<Double>()
            _zij = Array<Array<Double>>()
            _s2 = 0.0
            i = 0
            _temp = Array<Double>()
            while i < Int(_k) {
                _s1 = 0.0
                _temp.removeAll()
                j = 0
                while j < Int(_ni[i]) {
                    _t = fabs(_y[i][j] - _means[i])
                    _temp.append(_t)
                    _s1 += _t
                    _s2 += _t
                    j += 1
                }
                _zi.append(_s1 / _ni[i])
                _zij.append(_temp)
                i += 1
            }
            _zMean = _s2 / _N
            _s1 = 0.0
            _s2 = 0.0
            i = 0
            while i < Int(_k) {
                _s1 += _ni[i] * ((_zi[i] - _zMean) * (_zi[i] - _zMean))
                i += 1
            }
            i = 0
            while i < Int(_k) {
                j = 0
                while j < Int(_ni[i]) {
                    let zij = _zij[i][j]
                    let zi = _zi[i]
                    _s2 = _s2 + pow(zij, 2.0) - (2.0 * zi * zij) + pow(zi, 2.0)
//                    _s2 = _s2 + p1 * p1
//                    _s2 += (_zij[i][j] - _zi[i]) * (_zij[i][j] - _zi[i])
                    j += 1
                }
                i += 1
            }
            _testStatisticValue = ((_N - _k) * _s1) / ((_k - 1.0) * _s2)
            _cdfFRatio = try SSProbabilityDistributions.cdfFRatio(f: _testStatisticValue, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoffAlpha = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff90Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.9, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff95Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.95, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _cutoff99Percent = try SSProbabilityDistributions.quantileFRatioDist(p: 0.99, numeratorDF: _k - 1.0, denominatorDF: _N - _k)
            _variancesAreEqual = !(_testStatisticValue > _cutoffAlpha)
            var result = SSVarianceEqualityTestResult()
            result.cv90Pct = _cutoff90Percent
            result.cv99Pct = _cutoff99Percent
            result.cv95Pct = _cutoff95Percent
            result.pValue = 1.0 - _cdfFRatio
            result.cvAlpha = _cutoffAlpha
            result.testStatistic = _testStatisticValue
            result.equality = _variancesAreEqual
            result.df = Double.nan
            switch testType {
            case .mean:
                result.testType = .levene(.mean)
            case .median:
                result.testType = .levene(.median)
            case .trimmedMean:
                result.testType = .levene(.trimmedMean)
            }
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Chi^2 variance equality test
    /// - Parameter data: Data as Array<Double>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.sampleSize < 2 || s0 <= 0
    public class func chiSquareVarianceTest(array: Array<Double>, nominalVariance s0: Double!, alpha: Double!) throws -> SSChiSquareVarianceTestResult? {
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try chiSquareVarianceTest(sample: SSExamine<Double>.init(withArray: array, name: nil, characterSet: nil), nominalVariance: s0, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Chi^2 variance equality test
    /// - Parameter sample: Data as SSExamine<Double>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if sample.sampleSize < 2 || s0 <= 0
    public class func chiSquareVarianceTest(sample: SSExamine<Double>, nominalVariance s0: Double!, alpha: Double!) throws -> SSChiSquareVarianceTestResult {
        if sample.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            os_log("nominal variance is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            let df = Double(sample.sampleSize) - 1.0
            let ratio = sample.variance(type: .unbiased)! / s0
            let testStatisticValue = df * ratio
            let cdfChiSquare = try SSProbabilityDistributions.cdfChiSquareDist(chi: testStatisticValue, degreesOfFreedom: df)
            let twoTailed: Double
            let oneTailed: Double
            if cdfChiSquare > 0.5 {
                twoTailed = (1.0 - cdfChiSquare) * 2.0
                oneTailed = 1.0 - cdfChiSquare
            }
            else {
                twoTailed = cdfChiSquare * 2.0
                oneTailed = cdfChiSquare
            }
            var result = SSChiSquareVarianceTestResult()
            result.df = df
            result.ratio = ratio
            result.testStatisticValue = testStatisticValue
            result.p1Value = oneTailed
            result.p2Value = twoTailed
            result.sampleSize = Double(sample.sampleSize)
            result.sigmaUEQs0 = (cdfChiSquare < alpha || cdfChiSquare > (1.0 - alpha)) ? true : false
            result.sigmaLTEs0 = (cdfChiSquare < alpha) ? true : false
            result.sigmaGTEs0 = (cdfChiSquare > (1.0 - alpha)) ? true : false
            result.sd = sample.standardDeviation(type: .unbiased)
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter data1: Data as Array<Double>
    /// - Parameter data1: Data as Array<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data1.sampleSize < 2 || data1.sampleSize < 2
    public class func fTestVarianceEquality(data1: Array<Double>!, data2: Array<Double>!, alpha: Double!) throws -> SSFTestResult {
        if data1.count < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.fTestVarianceEquality(sample1: SSExamine<Double>.init(withArray: data1, name: nil, characterSet: nil), sample2: SSExamine<Double>.init(withArray: data2, name: nil, characterSet: nil), alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter sample1: Data as SSExamine<Double>
    /// - Parameter sample2: Data as SSExamine<Double>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample1.sampleSize < 2
    public class func fTestVarianceEquality(sample1: SSExamine<Double>!, sample2: SSExamine<Double>!, alpha: Double!) throws -> SSFTestResult {
        if sample1.sampleSize < 2 {
            os_log("sample1 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            os_log("sample2 size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let s1: Double
        let s2: Double
        let testStat: Double
        if let a = sample1.variance(type: .unbiased), let b = sample2.variance(type: .unbiased) {
            s1 = a
            s2 = b
            testStat = s1 / s2
        }
        else {
            os_log("error in obtaining the f ratio", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let df1 = Double(sample1.sampleSize) - 1.0
        let df2 = Double(sample2.sampleSize) - 1.0
        let cdfTestStat: Double
        do {
            cdfTestStat = try SSProbabilityDistributions.cdfFRatio(f: testStat, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
        var pVVarEqual: Double
        if cdfTestStat > 0.5 {
            pVVarEqual = 2.0 * (1.0 - cdfTestStat)
        }
        else {
            pVVarEqual = 2.0 * cdfTestStat
        }
        let pVVar1LTEVar2 = 1.0 - cdfTestStat
        let pVVar1GTEVar2 = cdfTestStat
        var var1EQvar2: Bool
        var var1GTEvar2: Bool
        var var1LTEvar2: Bool
        if pVVarEqual < alpha {
            var1EQvar2 = false
        }
        else {
            var1EQvar2 = true
        }
        if pVVar1LTEVar2 < alpha {
            var1LTEvar2 = false
        }
        else {
            var1LTEvar2 = true
        }
        if pVVar1GTEVar2 < alpha {
            var1GTEvar2 = false
        }
        else {
            var1GTEvar2 = true
        }
        var ciTwoSidedAlphaLower: Double
        var ciTwoSidedAlphaUpper: Double
        var ciLessAlphaLower: Double
        var ciLessAlphaUpper: Double
        var ciGreaterAlphaLower: Double
        var ciGreaterAlphaUpper: Double
        do {
            ciTwoSidedAlphaUpper = try (testStat / SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: df1, denominatorDF: df2))
            ciTwoSidedAlphaLower = try (testStat * SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: df2, denominatorDF: df1))
            ciLessAlphaLower = 0.0
            ciLessAlphaUpper = try (testStat / SSProbabilityDistributions.quantileFRatioDist(p: alpha, numeratorDF: df1, denominatorDF: df2))
            ciGreaterAlphaLower = try (testStat * SSProbabilityDistributions.quantileFRatioDist(p: alpha, numeratorDF: df2, denominatorDF: df1))
            ciGreaterAlphaUpper = Double.infinity
        }
        catch {
            throw error
        }
        var result = SSFTestResult()
        result.sampleSize1 = Double(sample1.sampleSize)
        result.sampleSize2 = Double(sample2.sampleSize)
        result.dfNumerator = df1
        result.dfDenominator = df2
        result.variance1 = s1;
        result.variance2 = s2;
        result.FRatio = testStat;
        result.p2Value = pVVarEqual;
        result.p1Value = pVVarEqual / 2.0;
        result.FRatioEQ1 = var1EQvar2;
        result.FRatioGTE1 = var1GTEvar2;
        result.FRatioLTE1 = var1LTEvar2;
        var cieq = SSConfIntv()
        cieq.lowerBound = ciTwoSidedAlphaLower
        cieq.upperBound = ciTwoSidedAlphaUpper
        cieq.intervalWidth = ciTwoSidedAlphaUpper - ciTwoSidedAlphaLower
        var cilt = SSConfIntv()
        cilt.intervalWidth = ciLessAlphaUpper - ciLessAlphaLower;
        cilt.lowerBound = ciLessAlphaLower;
        cilt.upperBound = ciLessAlphaUpper;
        var cigt = SSConfIntv()
        cigt.intervalWidth = ciGreaterAlphaUpper - ciGreaterAlphaLower;
        cigt.lowerBound = ciGreaterAlphaLower;
        cigt.upperBound = ciGreaterAlphaUpper;
        result.ciRatioEQ1 = cieq
        result.ciRatioGTE1 = cigt
        result.ciRatioLTE1 = cilt
        return result
    }

}
