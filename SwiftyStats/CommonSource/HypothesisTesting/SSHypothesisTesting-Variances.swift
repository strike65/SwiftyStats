//
//  SSHypothesisTesting-Variances.swift
//  SwiftyStats
//
//  Created by strike65 on 20.07.17.
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
    
    /// Performs the Bartlett test for two or more samples
    /// - Parameter data: Array containing samples as SSExamine objects
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2 or no variances are obtainable
    public static func bartlettTest<T, FPT: SSFloatingPoint & Codable>(data: Array<SSExamine<T, FPT>>, alpha: FPT) throws -> SSVarianceEqualityTestResult<FPT>? where T: Hashable & Comparable & Codable {
        if data.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 1", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<T>> = Array<Array<T>>()
        for examine in data {
            if examine.isNotEmptyAndNumeric {
                array.append(examine.elementsAsArray(sortOrder: .raw)!)
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    if examine.isEmpty {
                        os_log("sample size is expected to be > 2", log: .log_stat, type: .error)
                    }
                    else {
                        os_log("Data are expected to be numeric", log: .log_stat, type: .error)
                    }
                }
                
                #endif
                
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
    public static func bartlettTest<T, FPT: SSFloatingPoint & Codable>(array: Array<Array<T>>, alpha: FPT) throws -> SSVarianceEqualityTestResult<FPT>? where T: Hashable & Comparable & Codable {
        var _N: FPT = 0
        var _pS: FPT = 0
        var _s1: FPT = 0
        var _s2: FPT = 0
        var _k: FPT = 0
        var _df: FPT = 0
        var ssize: FPT = 0
        var _testStatisticValue: FPT = 0
        var _cdfChiSquare: FPT = 0
        var _cutoff90Percent: FPT = 0
        var _cutoff95Percent: FPT = 0
        var _cutoff99Percent: FPT = 0
        var _cutoffAlpha: FPT = 0
        var _data:Array<SSExamine<T, FPT>> = Array<SSExamine<T, FPT>>()
        var result: SSVarianceEqualityTestResult<FPT>
        var sumVars: [(sampleSize: FPT, variance: FPT)] = [(sampleSize: FPT, variance: FPT)]()
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 1", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            _data.append(SSExamine<T, FPT>.init(withArray: a, name: nil, characterSet: nil))
            if !_data.last!.isNotEmptyAndNumeric {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    if _data.last!.isEmpty {
                        os_log("sample size is expected to be > 2", log: .log_stat, type: .error)
                    }
                    else {
                        os_log("Data are expected to be numeric", log: .log_stat, type: .error)
                    }
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        _k =  Helpers.makeFP(_data.count)
        for examine in _data {
            ssize = Helpers.makeFP(examine.sampleSize)
            _N +=  ssize
            if let v = examine.variance(type: .unbiased) {
                sumVars.append((ssize, v))
                _s1 += ( Helpers.makeFP(examine.sampleSize) - 1) * SSMath.log1(v)
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("for at least one sample a variance is not obtainable", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        ex1 = _N - _k
        for (sampleSize, variance) in sumVars {
            ex2 = sampleSize - FPT.one
            ex3 = ex2 * variance
            ex4 = ex3 / ex1
            _pS += ex4
            _s2 += 1 /  (sampleSize - FPT.one)
        }
        ex1 = ((_N - _k) * SSMath.log1(_pS) - _s1)
        ex2 = (1 / (3 * (_k - 1)))
        ex3 = (_s2 - 1 / (_N - _k))
        _testStatisticValue = ex1 / (1 + ex2 * ex3)
        do {
            _cdfChiSquare = try SSProbDist.ChiSquare.cdf(chi: _testStatisticValue, degreesOfFreedom: _k - 1)
            _cutoff90Percent = try SSProbDist.ChiSquare.quantile(p:  Helpers.makeFP(0.9), degreesOfFreedom: _k - 1)
            _cutoff95Percent = try SSProbDist.ChiSquare.quantile(p:  Helpers.makeFP(0.95), degreesOfFreedom: _k - 1)
            _cutoff99Percent = try SSProbDist.ChiSquare.quantile(p:  Helpers.makeFP(0.99), degreesOfFreedom: _k - 1)
            _cutoffAlpha = try SSProbDist.ChiSquare.quantile(p: 1 - alpha, degreesOfFreedom: _k - 1)
            _df = _k - 1
            result = SSVarianceEqualityTestResult<FPT>()
            result.testStatistic = _testStatisticValue
            result.pValue = 1 - _cdfChiSquare
            result.cv90Pct = _cutoff90Percent
            result.cv95Pct = _cutoff95Percent
            result.cv99Pct = _cutoff99Percent
            result.cvAlpha = _cutoffAlpha
            result.df = _df
            result.equality = !(_cdfChiSquare > (1 - alpha))
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
    public static func leveneTest<T, FPT: SSFloatingPoint & Codable>(data: Array<SSExamine<T, FPT>>!, testType: SSLeveneTestType, alpha: FPT) throws -> SSVarianceEqualityTestResult<FPT>? where T: Hashable & Comparable & Codable  {
        if data.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 1", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var array: Array<Array<T>> = Array<Array<T>>()
        for examine in data {
            if examine.isNotEmptyAndNumeric {
                array.append(examine.elementsAsArray(sortOrder: .raw)!)
            }
            else {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    if examine.isEmpty {
                        os_log("sample size is expected to be > 2", log: .log_stat, type: .error)
                    }
                    else {
                        os_log("Data are expected to be numeric", log: .log_stat, type: .error)
                    }
                }
                #endif
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
    public static func leveneTest<T, FPT: SSFloatingPoint & Codable>(array: Array<Array<T>>!, testType: SSLeveneTestType, alpha: FPT) throws -> SSVarianceEqualityTestResult<FPT>? where T: Hashable & Comparable & Codable {
        var _N: FPT = 0
        var _s1: FPT = 0
        var _s2: FPT = 0
        var _t: FPT = 0
        var _zMean: FPT = 0
        var _cutoff90Percent: FPT
        var _cutoff95Percent: FPT
        var _cutoff99Percent: FPT
        var _cdfFRatio: FPT
        var _cutoffAlpha: FPT
        var _testStatisticValue: FPT
        var _variancesAreEqual = false
        var _ntemp: FPT
        var _k: FPT
        var _data: Array<SSExamine<T, FPT>> = Array<SSExamine<T, FPT>>()
        var _zi: Array<FPT>
        var _zij: Array<Array<FPT>>
        var _ni: Array<FPT>
        var _y: Array<Array<T>>
        var _means: Array<FPT>
        var _temp: Array<FPT>
        var i: Int
        var j: Int
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("number of samples is expected to be > 1", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        for a in array {
            if array.count >= 2 {
                _data.append(SSExamine<T, FPT>.init(withArray: a, name: nil, characterSet: nil))
                if !_data.last!.isNotEmptyAndNumeric {
                    #if os(macOS) || os(iOS)
                    if #available(macOS 10.12, iOS 13, *) {
                        if _data.last!.isEmpty {
                            os_log("sample size is expected to be > 2", log: .log_stat, type: .error)
                        }
                        else {
                            os_log("Data are expected to be numeric", log: .log_stat, type: .error)
                        }
                    }
                    #endif
                    throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
                }
            }
            else {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
        }
        _k =  Helpers.makeFP(_data.count)
        _ni = Array<FPT>()
        _y = Array<Array<T>>()
        _means = Array<FPT>()
        do {
            for examine in _data {
                _ntemp =  Helpers.makeFP(examine.sampleSize)
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
                    if let m = try examine.trimmedMean(alpha:  Helpers.makeFP(0.1)) {
                        _means.append(m)
                    }
                    else {
                        return nil
                    }
                }
            }
            _zi = Array<FPT>()
            _zij = Array<Array<FPT>>()
            _s2 = 0
            i = 0
            _temp = Array<FPT>()
            while i < Helpers.integerValue(_k) {
                _s1 = 0
                _temp.removeAll()
                j = 0
                while j < Helpers.integerValue(_ni[i]) {
                    _t = abs( Helpers.makeFP(_y[i][j]) - _means[i])
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
            _s1 = 0
            _s2 = 0
            i = 0
            while i < Helpers.integerValue(_k) {
                ex1 = _zi[i] - _zMean
                ex2 = ex1 * ex1
                _s1 += _ni[i] * (ex2)
                i += 1
            }
            i = 0
            while i < Helpers.integerValue(_k) {
                j = 0
                while j < Helpers.integerValue(_ni[i]) {
                    let zij = _zij[i][j]
                    let zi = _zi[i]
                    ex1 = _s2 + SSMath.pow1(zij, 2)
                    ex2 = (2 * zi * zij)
                    _s2 = ex1 - ex2 + SSMath.pow1(zi, 2)
//                    _s2 = _s2 + SSMath.pow1(zij, 2) - (2 * zi * zij) + SSMath.pow1(zi, 2)
                    j += 1
                }
                i += 1
            }
            ex1 = _N - _k
            ex2 = ex1 * _s1
            ex3 = _k - FPT.one
            ex4 = ex3 * _s2
            _testStatisticValue = ex2 / ex4
            _cdfFRatio = try SSProbDist.FRatio.cdf(f: _testStatisticValue, numeratorDF: _k - 1, denominatorDF: _N - _k)
            _cutoffAlpha = try SSProbDist.FRatio.quantile(p: 1 - alpha, numeratorDF: _k - 1, denominatorDF: _N - _k)
            _cutoff90Percent = try SSProbDist.FRatio.quantile(p:  Helpers.makeFP(0.9), numeratorDF: _k - 1, denominatorDF: _N - _k)
            _cutoff95Percent = try SSProbDist.FRatio.quantile(p:  Helpers.makeFP(0.95), numeratorDF: _k - 1, denominatorDF: _N - _k)
            _cutoff99Percent = try SSProbDist.FRatio.quantile(p:  Helpers.makeFP(0.99), numeratorDF: _k - 1, denominatorDF: _N - _k)
            _variancesAreEqual = !(_testStatisticValue > _cutoffAlpha)
            var result = SSVarianceEqualityTestResult<FPT>()
            result.cv90Pct = _cutoff90Percent
            result.cv99Pct = _cutoff99Percent
            result.cv95Pct = _cutoff95Percent
            result.pValue = 1 - _cdfFRatio
            result.cvAlpha = _cutoffAlpha
            result.testStatistic = _testStatisticValue
            result.equality = _variancesAreEqual
            result.df = FPT.nan
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
    /// - Parameter data: Data as Array<Numeric>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.sampleSize < 2 || s0 <= 0
    public static func chiSquareVarianceTest<T, FPT: SSFloatingPoint & Codable>(array: Array<T>, nominalVariance s0: FPT, alpha: FPT) throws -> SSChiSquareVarianceTestResult<FPT>? where T: Hashable & Comparable & Codable {
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("nominal variance is expected to be > 0", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try chiSquareVarianceTest(sample: SSExamine<T, FPT>.init(withArray: array, name: nil, characterSet: nil), nominalVariance: s0, alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the Chi^2 variance equality test
    /// - Parameter sample: Data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter s0: nominal variance
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if sample.sampleSize < 2 || s0 <= 0
    public static func chiSquareVarianceTest<T, FPT: SSFloatingPoint & Codable>(sample: SSExamine<T, FPT>, nominalVariance s0: FPT, alpha: FPT) throws -> SSChiSquareVarianceTestResult<FPT>? where T: Hashable & Comparable & Codable {
        if sample.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !sample.isNotEmptyAndNumeric {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
               os_log("Data are expected to be numeric", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if s0 <= 0 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("nominal variance is expected to be > 0", log: .log_stat, type: .error)
            }
            
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            let df: FPT =  Helpers.makeFP(sample.sampleSize - 1)
            let ratio: FPT = sample.variance(type: .unbiased)! / s0
            let testStatisticValue: FPT = df * ratio
            let cdfChiSquare: FPT = try SSProbDist.ChiSquare.cdf(chi: testStatisticValue, degreesOfFreedom: df)
            let twoTailed: FPT
            let oneTailed: FPT
            if cdfChiSquare > FPT.half {
                twoTailed = (1 - cdfChiSquare) * 2
                oneTailed = 1 - cdfChiSquare
            }
            else {
                twoTailed = cdfChiSquare * 2
                oneTailed = cdfChiSquare
            }
            var result: SSChiSquareVarianceTestResult<FPT> = SSChiSquareVarianceTestResult<FPT>()
            result.df = df
            result.ratio = ratio
            result.testStatisticValue = testStatisticValue
            result.p1Value = oneTailed
            result.p2Value = twoTailed
            result.sampleSize =  Helpers.makeFP(sample.sampleSize)
            result.sigmaUEQs0 = (cdfChiSquare < alpha || cdfChiSquare > (1 - alpha)) ? true : false
            result.sigmaLTEs0 = (cdfChiSquare < alpha) ? true : false
            result.sigmaGTEs0 = (cdfChiSquare > (1 - alpha)) ? true : false
            result.sd = sample.standardDeviation(type: .unbiased)
            return result
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter data1: Data as Array<Numeric>
    /// - Parameter data1: Data as Array<Numeric>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff data1.sampleSize < 2 || data1.sampleSize < 2
    public static func fTestVarianceEquality<T, FPT: SSFloatingPoint & Codable>(data1: Array<T>, data2: Array<T>, alpha: FPT) throws -> SSFTestResult<FPT> where T: Hashable & Comparable & Codable {
        if data1.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample1 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data2.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample2 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.fTestVarianceEquality(sample1: SSExamine<T, FPT>.init(withArray: data1, name: nil, characterSet: nil), sample2: SSExamine<T, FPT>.init(withArray: data2, name: nil, characterSet: nil), alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the F ratio test for variance equality
    /// - Parameter sample1: Data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter sample2: Data as SSExamine<Numeric, SSFloatingPoint>
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError iff sample1.sampleSize < 2 || sample1.sampleSize < 2
    public static func fTestVarianceEquality<T, FPT: SSFloatingPoint & Codable>(sample1: SSExamine<T, FPT>, sample2: SSExamine<T, FPT>, alpha: FPT) throws -> SSFTestResult<FPT> where T: Hashable & Comparable & Codable {
        if sample1.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample1 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if sample2.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("sample2 size is expected to be >= 2", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !sample1.isNotEmptyAndNumeric || !sample2.isNotEmptyAndNumeric {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Data are expected to be numeric", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }

        let s1: FPT
        let s2: FPT
        let testStat: FPT
        if let a = sample1.variance(type: .unbiased), let b = sample2.variance(type: .unbiased) {
            s1 = a
            s2 = b
            testStat = s1 / s2
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("error in obtaining the f ratio", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let df1: FPT =  Helpers.makeFP(sample1.sampleSize - 1)
        let df2: FPT =  Helpers.makeFP(sample2.sampleSize - 1)
        let cdfTestStat: FPT
        do {
            cdfTestStat = try SSProbDist.FRatio.cdf(f: testStat, numeratorDF: df1, denominatorDF: df2)
        }
        catch {
            throw error
        }
        var pVVarEqual: FPT
        if cdfTestStat > FPT.half {
            pVVarEqual = 2 * (1 - cdfTestStat)
        }
        else {
            pVVarEqual = 2 * cdfTestStat
        }
        let pVVar1LTEVar2 = 1 - cdfTestStat
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
        var ciTwoSidedAlphaLower: FPT
        var ciTwoSidedAlphaUpper: FPT
        var ciLessAlphaLower: FPT
        var ciLessAlphaUpper: FPT
        var ciGreaterAlphaLower: FPT
        var ciGreaterAlphaUpper: FPT
        do {
            ciTwoSidedAlphaUpper = try (testStat / SSProbDist.FRatio.quantile(p: alpha / 2, numeratorDF: df1, denominatorDF: df2))
            ciTwoSidedAlphaLower = try (testStat * SSProbDist.FRatio.quantile(p: alpha / 2, numeratorDF: df2, denominatorDF: df1))
            ciLessAlphaLower = 0
            ciLessAlphaUpper = try (testStat / SSProbDist.FRatio.quantile(p: alpha, numeratorDF: df1, denominatorDF: df2))
            ciGreaterAlphaLower = try (testStat * SSProbDist.FRatio.quantile(p: alpha, numeratorDF: df2, denominatorDF: df1))
            ciGreaterAlphaUpper = FPT.infinity
        }
        catch {
            throw error
        }
        var result: SSFTestResult<FPT> = SSFTestResult<FPT>()
        result.sampleSize1 =  Helpers.makeFP(sample1.sampleSize)
        result.sampleSize2 =  Helpers.makeFP(sample2.sampleSize)
        result.dfNumerator = df1
        result.dfDenominator = df2
        result.variance1 = s1
        result.variance2 = s2
        result.FRatio = testStat
        result.p2Value = pVVarEqual
        result.p1Value = pVVarEqual / 2
        result.FRatioEQ1 = var1EQvar2
        result.FRatioGTE1 = var1GTEvar2
        result.FRatioLTE1 = var1LTEvar2
        var cieq: SSConfIntv<FPT> = SSConfIntv<FPT>()
        cieq.lowerBound = ciTwoSidedAlphaLower
        cieq.upperBound = ciTwoSidedAlphaUpper
        cieq.intervalWidth = ciTwoSidedAlphaUpper - ciTwoSidedAlphaLower
        var cilt: SSConfIntv<FPT> = SSConfIntv<FPT>()
        cilt.intervalWidth = ciLessAlphaUpper - ciLessAlphaLower
        cilt.lowerBound = ciLessAlphaLower
        cilt.upperBound = ciLessAlphaUpper
        var cigt: SSConfIntv<FPT> = SSConfIntv<FPT>()
        cigt.intervalWidth = ciGreaterAlphaUpper - ciGreaterAlphaLower
        cigt.lowerBound = ciGreaterAlphaLower
        cigt.upperBound = ciGreaterAlphaUpper
        result.ciRatioEQ1 = cieq
        result.ciRatioGTE1 = cigt
        result.ciRatioLTE1 = cilt
        return result
    }
    
}
