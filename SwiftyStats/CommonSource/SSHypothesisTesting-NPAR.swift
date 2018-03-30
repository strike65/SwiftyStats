//
//  SSHypothesisTesting-NPAR.swift
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
    /************************************************************************************************/
    // MARK: GoF test
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest(array: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<Double>.init(withArray: array, name: nil, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(array: Array<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<Double>.init(withArray: array, name: nil, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: SSExamine<Double>!
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        do {
            return try ksGoFTest(data: data, targetDistribution: target)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: SSExamine<Double>!
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest(data: SSExamine<Double>!, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        // error handling
        if data.sampleSize < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sortedData = data.uniqueElements(sortOrder: .ascending)!
        var dD: Double = 0.0
        var dz: Double
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
            dest1 = data.arithmeticMean!
            if let test = data.standardDeviation(type: .unbiased) {
                dest2 = test
            }
        case .exponential:
            dest3 = 0.0
            ik = 0
            for value in sortedData {
                if value <= 0 {
                    ik = ik + data.frequency(value)
                    dest3 = Double(ik) * value
                }
            }
            for value in sortedData {
                if value < 0 {
                    lds = 0
                }
                else {
                    lds = lds + Double(data.frequency(value)) / (Double(data.sampleSize) - Double(ik))
                }
                ecdf[value] = lds
            }
            if lds == 0.0 || ik > (data.sampleSize - 2) {
                bok1 = false
            }
            if let tot = data.total {
                dest1 = (Double(data.sampleSize) - Double(ik)) / (tot - dest3)
            }
            else {
                dest1 = Double.nan
            }
        case .uniform:
            dest1 = data.minimum!
            dest2 = data.maximum!
            ik = 0
        case .studentT:
            dest1 = Double(data.sampleSize)
            ik = 0
        case .laplace:
            dest1 = data.median!
            dest2 = data.medianAbsoluteDeviation(center: dest1, scaleFactor: 1.0)!
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
                    dtemp1 = data.eCDF(value) - dtestCDF
                }
                if dtemp1 < dmax1n {
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
                        dtemp1 = data.eCDF(nt) - dtestCDF
                    }
                }
                else {
                    dtemp1 = -dtestCDF
                }
                if dtemp1 < dmax2n {
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
        dD = (fabs(dmaxn) > fabs(dmaxp)) ? fabs(dmaxn) : fabs(dmaxp)
        dz = sqrt(Double(data.sampleSize - ik)) * dD
        let dp: Double = 1.0 - KScdf(n: data.sampleSize, x: dD)
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
            result.sampleSize = data.sampleSize
            
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
            result.sampleSize = data.sampleSize
        case .uniform:
            result.estimatedLowerBound = dest1
            result.estimatedUpperBound = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .studentT:
            result.estimatedDegreesOfFreedom = dest1
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .laplace:
            result.estimatedMean = dest1
            result.estimatedShapeParam = dest2
            result.pValue = dp
            result.maxAbsDifference = dD
            result.maxNegDifference = dmaxn
            result.maxPosDifference = dmaxp
            result.zStatistics = dz
            result.sampleSize = data.sampleSize
        case .none:
            break
        }
        return result
    }
    
    /************************************************************************************************/
    /************************************************************************************************/
    // Marsaglia et al.: Evaluating the Anderson-Darling Distribution. Journal of
    // Statistical Software 9 (2), 1–5. February 2004. http://www.jstatsoft.org/v09/i02
    /************************************************************************************************/
    /************************************************************************************************/
    
    fileprivate class func PRIV_ADf(_ z: Double!, _ j: Int!) -> Double {
        var t: Double
        var f: Double
        var fnew: Double
        var a: Double
        var b: Double
        var c: Double
        var r: Double
        var i: Int
        t = (4.0 * Double(j) + 1.0) * (4.0 * Double(j) + 1.0) * 1.23370055013617 / z
        if t > 150 {
            return 0.0
        }
        a = 2.22144146907918 * exp(-t) / sqrt(t)
        b = 3.93740248643060 * erfc(sqrt(t))
        r = z * 0.125
        f = a + b * r
        // 200
        i = 1
        while i < 500 {
            c = ((Double(i) - 0.5 - t) * b + t * a) / Double(i)
            a = b
            b = c
            r *= z / (8.0 * Double(i) + 8.0)
            if (fabs(r) < 1E-40 || fabs(c) < 1E-40) {
                return f
            }
            fnew = f + c * r
            if (f == fnew) {
                return f
            }
            f = fnew
            i += 1
        }
        return f
    }
    
    fileprivate class func PRIV_ADinf(_ z: Double!) -> Double {
        var j: Int
        var ad: Double
        var adnew: Double
        var r: Double
        if z < 0.01 {
            return 0.0
        }
        r = 1.0 / z
        ad = r * PRIV_ADf(z, 0)
        // 100
        j = 1
        while j < 400 {
            r *= (0.5 - Double(j)) / Double(j)
            adnew = ad + (4.0 * Double(j) + 1.0) * r * PRIV_ADf(z, j)
            if ad == adnew {
                return ad
            }
            ad = adnew
            j += 1
        }
        return ad
    }
    
    fileprivate class func PRIV_AD_Prob(_ n: Int,_ z: Double) -> Double {
        var c: Double
        var v: Double
        var x: Double
        x = PRIV_ADinf(z)
        /* now x=adinf(z). Next, get v=errfix(n,x) and return x+v; */
        if x > 0.8 {
            v = (-130.2137 + (745.2337 - (1705.091 - (1950.646 - (1116.360 - 255.7844 * x) * x) * x) * x) * x) / Double(n)
            return x + v
        }
        c = 0.01265 + 0.1757 / Double(n)
        if x < c {
            v = x / c
            v = sqrt(v) * (1.0 - v) * (49.0 * v - 102.0)
            return x + v * (0.0037 / pow(Double(n), 2.0) + 0.00078 / Double(n) + 0.00006) / Double(n)
        }
        v = (x - c)/(0.8 - c)
        v = -0.00022633 + (6.54034 - (14.6538 - (14.458 - (8.259 - 1.91864 * v) * v) * v) * v) * v
        return x + v * (0.04213 + 0.01365 / Double(n)) / Double(n)
    }
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data as SSExamine object
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest(data: SSExamine<Double>!, alpha: Double!) throws -> SSADTestResult? {
        if !data.isEmpty {
            do {
                return try adNormalityTest(array: data.elementsAsArray(sortOrder: .original)!, alpha: alpha)
            }
            catch {
                throw error
            }
        }
        else {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
    }
    
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest(array: Array<Double>!, alpha: Double!) throws -> SSADTestResult? {
        var ad: Double = 0.0
        var a2: Double
        var estMean: Double
        var estSd: Double
        var n: Int
        var tempArray: Array<Double>
        var pValue: Double
        if array.count < 2 {
            os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<Double>
        do {
            _data = try SSExamine<Double>.init(withObject: array, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        }
        catch {
            os_log("unable to create examine object", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        estMean = _data.arithmeticMean!
        estSd = _data.standardDeviation(type: .unbiased)!
        n = _data.sampleSize
        tempArray = _data.elementsAsArray(sortOrder: .ascending)! as Array<Double>
        var i = 0
        var val: Double
        var val1: Double
        while i < n {
            val = tempArray[i]
            tempArray[i] = (val - estMean) / estSd
            i += 1
        }
        i = 0
        var k: Double
        while i < n {
            val = tempArray[i]
            val1 = tempArray[n - i - 1]
            k = Double(i)
            ad += (((2.0 * (k + 1) - 1.0) / Double(n)) * (log(SSProbabilityDistributions.cdfStandardNormalDist(u: val)) + log(1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: val1))))
            i += 1
        }
        a2 = -1.0 * Double(n) - ad
        ad = a2
        if n > 8 {
            a2 = a2 * (1.0 + 0.75 / Double(n) + 2.25 / (Double(n) * Double(n)))
        }
        pValue = 1.0 - PRIV_AD_Prob(n, a2)
        var result: SSADTestResult = SSADTestResult()
        result.pValue = pValue
        result.AD = ad
        result.ADStar = a2
        result.sampleSize = n
        result.stdDev = estSd
        result.variance = estSd * estSd
        result.mean = estMean
        result.isNormal = (pValue >= alpha)
        return result
    }
    /// Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
    fileprivate class func cdfMannWhitney(U: Double!, m: Int!, n: Int!) throws -> Double {
        // Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
        if m <= 0 || n <= 0 {
            os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if U > (Double(m) * Double(n)) {
            return Double.nan
        }
        var freq: Array<Double> = Array<Double>.init(repeating: 0.0, count: m * n * 2)
        var work: Array<Double> = Array<Double>.init(repeating: 0.0, count: m * n * 2)
        var minmn: Int
        var maxmmn: Int
        var mn1: Int
        var n1: Int
        var i: Int
        var _in: Int
        var l: Int
        var k: Int
        var j: Int
        var sum: Double
        let one = 1.0
        let zero = 0.0
        minmn = minimum(m, n)
        if minmn < 1 {
            os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        mn1 = m * n + 1
        maxmmn = maximum(m, n)
        n1 = maxmmn + 1
        i = 1
        while i <= n1 {
            freq[i - 1] = one
            i += 1
        }
        if minmn > 1 {
            n1 = n1 + 1
            i = n1
            while i <= mn1 {
                freq[i - 1] = zero
                i += 1
            }
            work[0] = zero
            _in = maxmmn
            i = 2
            while i <= minmn {
                work[i - 1] = zero
                _in = _in + maxmmn
                n1 = _in + 2
                l = 1 + _in / 2
                k = i
                j = 1
                
                while j <= l {
                    k = k + 1
                    n1 = n1 - 1
                    sum = freq[j - 1] + work[j - 1]
                    freq[j - 1] = sum
                    work[k - 1] = sum - freq[n1 - 1]
                    freq[n1 - 1] = sum
                    j += 1
                }
                i += 1
            }
        }
        sum = 0.0
        i = 1
        while i <= mn1 {
            sum = sum + freq[i - 1]
            freq[i - 1] = sum
            i += 1
        }
        i = 1
        while i <= mn1 {
            freq[i - 1] = freq[i - 1] / sum
            i += 1
        }
        return freq[Int(floor(U))]
    }
    
    /// Returns the sum of i for i = start...end
    fileprivate class func sumUp(start: Int!, end: Int!) -> Double {
        var sum = Double(start)
        var i: Int = start
        while i < end {
            sum += Double(i)
            i += 1
        }
        return sum
    }
    
    /// Perform the Mann-Whitney U test for independent samples.
    /// ### Note ###
    /// If there are ties between the sets, only an asymptotic p-value is returned. Exact p-values are computed using the Algorithm by Dineen and Blakesley (1973)
    /// - Parameter set1: Observations of group1 as Array<T>
    /// - Parameter set2: Observations of group2 as Array<T>
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func mannWhitneyUTest<T>(set1: Array<T>!, set2: Array<T>!)  throws -> SSMannWhitneyUTestResult where T: Comparable, T: Hashable, T: Codable {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try mannWhitneyUTest(set1: SSExamine<T>.init(withArray: set1, name: nil, characterSet: nil) , set2: SSExamine<T>.init(withArray: set2, name: nil, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    /// Perform the Mann-Whitney U test for independent samples.
    /// ### Note ###
    /// If there are ties between the sets, only an asymptotic p-value is returned. Exact p-values are computed using the Algorithm by Dineen and Blakesley (1973)
    /// - Parameter set1: Observations of group1
    /// - Parameter set2: Observations of group2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func mannWhitneyUTest<T>(set1: SSExamine<T>!, set2: SSExamine<T>!)  throws -> SSMannWhitneyUTestResult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups:Array<Int> = Array<Int>()
        var ties: Array<Double> = Array<Double>()
        var sumRanksSet1: Double = 0.0
        var sumRanksSet2: Double = 0.0
        groups.append(contentsOf: Array<Int>.init(repeating: 1, count: set1.sampleSize))
        groups.append(contentsOf: Array<Int>.init(repeating: 2, count: set2.sampleSize))
        var tempData = set1.elementsAsArray(sortOrder: .original)!
        tempData.append(contentsOf: set2.elementsAsArray(sortOrder: .original)!)
        let sorter = SSDataGroupSorter.init(data: tempData, groups: groups)
        let sorted = sorter.sortedArrays()
        let rr = rank.init(data: sorted.sortedData, groups: sorted.sortedGroups)
        ties = rr.ties!
        sumRanksSet1 = rr.sumOfRanks[0]
        sumRanksSet2 = rr.sumOfRanks[1]
        let U1 = (Double(set1.sampleSize) * Double(set2.sampleSize)) + (Double(set1.sampleSize) * (Double(set1.sampleSize) + 1)) / 2.0 - sumRanksSet1
        let U2 = (Double(set1.sampleSize) * Double(set2.sampleSize)) + (Double(set2.sampleSize) * (Double(set2.sampleSize) + 1)) / 2.0 - sumRanksSet2
        let nm = Double(set1.sampleSize) * Double(set2.sampleSize)
        let n1 = Double(set1.sampleSize)
        let n2 = Double(set2.sampleSize)
        if (U1 + U2) != nm {
            os_log("internal error", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        let S = n1 + n2
        var z: Double = 0.0
        var pasymp1: Double = 0.0
        var pasymp2: Double = 0.0
        var pexact1: Double = 0.0
        var pexact2: Double = 0.0
        
        z = Double.nan
        var temp1: Double = 0.0
        var denom: Double = 0.0
        var num: Double = 0.0
        var i: Int = 0
        let U: Double
        if U1 > (n1 * n2) / 2.0 {
            U = nm - U1
        }
        else {
            U = U1
        }
        if ties.count > 0 {
            while i < ties.count {
                temp1 += (ties[i] / 12.0)
                i += 1
            }
            denom = sqrt((nm / (S * (S - 1.0))) * ((pow(S, 3.0) - S) / 12.0 - temp1))
            num = fabs(U - nm / 2.0)
            z = num / denom
            pasymp1 = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
            pasymp2 = pasymp1 * 2.0
            pexact1 = Double.nan
            pexact2 = Double.nan
        }
        else {
            z = fabs(U - nm / 2.0) / sqrt((nm * (n1 + n2 + 1)) / 12.0)
            if (n1 * n2) <= 400 && ((n1 * n2) + minimum(n1, n2)) <= 220 {
                do {
                    if U <= (n1 * n2 + 1) / 2.0 {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                    }
                    else {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                        pexact1 = 1.0 - pexact1
                    }
                    pexact2 = 2.0 * pexact1
                }
                catch {
                    throw error
                }
            }
            else {
                pexact1 = Double.nan
                pexact2 = Double.nan
            }
            pasymp1 = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
            pasymp2 = 2.0 * pasymp1
        }
        let W = sumRanksSet2
        var result = SSMannWhitneyUTestResult()
        result.sumRanks1 = sumRanksSet1
        result.sumRanks2 = sumRanksSet2
        result.meanRank1 = sumRanksSet1 / n1
        result.meanRank2 = sumRanksSet2 / n2
        result.UMannWhitney = U
        result.WilcoxonW = W
        result.zStat = z
        result.p2Approx = pasymp2
        result.p2Exact = pexact2
        result.p1Approx = pasymp1
        result.p1Exact = pexact1
        result.effectSize = z / sqrt(n1 + n2)
        return result
    }
    
    /// Performs the Wilcoxon signed ranks test for matched pairs
    /// - Parameter set1: Observations 1 as Array<Double>
    /// - Parameter set2: Observations 2 as Array<Double>
    /// - Throws: SSSwiftyStatsError iff set1.count <= 2 || set1.count <= 2 || set1.count != set2.count
    public class func wilcoxonMatchedPairs(set1: Array<Double>!, set2: Array<Double>!) throws -> SSWilcoxonMatchedPairsTestResult {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.wilcoxonMatchedPairs(set1: SSExamine<Double>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<Double>.init(withArray: set2, name: nil, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Wilcoxon signed ranks test for matched pairs
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func wilcoxonMatchedPairs(set1: SSExamine<Double>!, set2: SSExamine<Double>!) throws -> SSWilcoxonMatchedPairsTestResult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var i: Int
        //        var np: Int = 0
        //        var nn: Int = 0
        var nties: Int = 0
        var temp: Double = 0.0
        var diff:Array<Double> = Array<Double>()
        let a1: Array<Double> = set1.elementsAsArray(sortOrder: .original)!
        let a2: Array<Double> = set2.elementsAsArray(sortOrder: .original)!
        let N = set1.sampleSize
        i = 0
        while i < N {
            temp = a2[i] - a1[i]
            if temp != 0.0 {
                diff.append(temp)
            }
            i += 1
        }
        var sorted = diff.sorted(by: {fabs($0) < fabs($1) } )
        var signs: Array<Double> = Array<Double>()
        var absDiffSorted:Array<Double> = Array<Double>()
        i = 0
        while i < sorted.count {
            signs.append(sorted[i] > 0.0 ? 1.0 : -1.0)
            absDiffSorted.append(fabs(sorted[i]))
            i += 1
        }
        var ranks: Array<Double>
        var ties: Array<Double>
        let ranking = rank.init(data: absDiffSorted, groups: nil)
        ranks = ranking.ranks
        ties = ranking.ties!
        nties = ranking.numberOfTies
        let n = absDiffSorted.count
        var nposranks: Int = 0
        var nnegranks: Int = 0
        var sumposranks: Double = 0.0
        var sumnegranks: Double = 0.0
        var meanposranks: Double
        var meannegranks: Double
        i = 0
        while i < n {
            if signs[i] == 1.0 {
                nposranks += 1
                sumposranks += ranks[i]
            }
            else {
                nnegranks += 1
                sumnegranks += ranks[i]
            }
            i += 1
        }
        if sumnegranks + sumposranks != (Double(n) * (Double(n) + 1.0)) / 2.0 {
            os_log("internal error", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        meannegranks = nnegranks > 0 ? sumnegranks / Double(nnegranks) : 0.0
        meanposranks = nposranks > 0 ? sumposranks / Double(nposranks) : 0.0
        var z: Double
        var ts: Double = 0.0
        i = 0
        while i < ties.count {
            ts += ties[i] / 48.0
            i += 1
        }
        z = (fabs(min(sumnegranks, sumposranks) - (Double(n) * (Double(n) + 1.0) / 4.0))) / sqrt(Double(n) * (Double(n) + 1.0) * (2.0 * Double(n) + 1.0) / 24.0 - ts)
        let p = 1.0 - SSProbabilityDistributions.cdfStandardNormalDist(u: fabs(z))
        let cohenD = fabs(z) / sqrt(2.0 * Double(N))
        var result = SSWilcoxonMatchedPairsTestResult()
        result.p2Value = 2.0 * p
        result.sampleSize = Double(N)
        result.nPosRanks = nposranks
        result.nNegRanks = nnegranks
        result.nTies = nties
        result.nZeroDiff = N - nposranks - nnegranks
        result.sumNegRanks = sumnegranks
        result.sumPosRanks = sumposranks
        result.meanPosRanks = meanposranks
        result.meanNegRanks = meannegranks
        result.zStat = z
        result.dCohen = cohenD
        return result
    }
    
    
    /// Performs the sign test
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.count <= 2 || set1.count <= 2 || set1.count != set2.count
    public class func signTest(set1: Array<Double>, set2: Array<Double>) throws -> SSSignTestRestult {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try signTest(set1: SSExamine<Double>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<Double>.init(withArray: set2, name: nil, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    /// Performs the sign test
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func signTest(set1: SSExamine<Double>, set2: SSExamine<Double>) throws -> SSSignTestRestult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let a1 = set1.elementsAsArray(sortOrder: .original)!
        let a2 = set2.elementsAsArray(sortOrder: .original)!
        var np: Int = 0
        var nn: Int = 0
        var nties: Int = 0
        var temp: Double = 0.0
        var i: Int = 0
        while i < a1.count {
            temp = a2[i] - a1[i]
            if temp > 0.0 {
                np += 1
            }
            else if temp < 0.0 {
                nn += 1
            }
            else {
                nties += 1
            }
            i += 1
        }
        var pexact: Double = 0.0
        var z: Double
        let nnpnp = nn + np
        let r = min(np,nn)
        temp = Double(max(nn, np))
        if nnpnp <= 1000 {
            i = 0
            while i <= r {
                pexact += binomial2(Double(nnpnp), Double(i)) * pow(0.5, Double(nnpnp))
                i += 1
            }
        }
        z = (temp - 0.5 * Double(nnpnp) - 0.5)
        z = -1.0 * z / (0.5 * sqrt(Double(nnpnp)))
        let pasymp = SSProbabilityDistributions.cdfStandardNormalDist(u: z)
        var result = SSSignTestRestult()
        result.pValueExact = pexact
        result.pValueApprox = pasymp
        result.nPosDiff = np
        result.nNegDiff = nn
        result.nTies = nties
        result.total = set1.sampleSize
        result.zStat = z
        return result
    }
    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    ///
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2
    public class func binomialTest(numberOfSuccess success: Int!, numberOfTrials trials: Int!, probability p0: Double!, alpha: Double!, alternative: SSAlternativeHypotheses) -> Double {
        if p0.isNaN {
            return Double.nan
        }
        var pV: Double = 0.0
        var pV1: Double = 0.0
        let q = 1.0 - p0
        var i: Int
        switch alternative {
        case .less:
            pV = SSProbabilityDistributions.cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
        case .greater:
            pV = SSProbabilityDistributions.cdfBinomialDistribution(k: trials - success, n: trials, probability: q, tail: .lower)
        case .twoSided:
            // algorithm adapted fropm R function binom.test
            var c1: Int = 0
            let d = SSProbabilityDistributions.pdfBinomialDistribution(k: success, n: trials, probability: p0)
            let m = Double(trials) * p0
            if success == Int(ceil(m)) {
                pV = 1.0
            }
            else if success < Int(ceil(m)) {
                i = Int(ceil(m))
                for j in i...trials {
                    if SSProbabilityDistributions.pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * (1.0 + 1E-7)) {
                        c1 = j - 1
                        break
                    }
                }
                pV = SSProbabilityDistributions.cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
                pV1 = SSProbabilityDistributions.cdfBinomialDistribution(k: c1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
            else {
                i = 0
                for j in 0...Int(floor(m)) {
                    if SSProbabilityDistributions.pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * (1.0 + 1E-7)) {
                        c1 = j + 1
                    }
                }
                pV = SSProbabilityDistributions.cdfBinomialDistribution(k: c1 - 1, n: trials, probability: p0, tail: .lower)
                pV1 = SSProbabilityDistributions.cdfBinomialDistribution(k: success - 1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
        }
        return pV
    }
    
    
    fileprivate class func lowerBoundCIBinomial(success: Double!, trials: Double!, alpha: Double) throws -> Double {
        var res: Double
        if success == 0 {
            res = 0.0
        }
        else {
            do {
                res = try SSProbabilityDistributions.quantileBetaDist(p: alpha, shapeA: success, shapeB: trials - success + 1)
                //                res = try SSProbabilityDistributions.quantileBetaDist(p: alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
            }
            catch {
                throw error
            }
        }
        return res
    }
    
    fileprivate class func upperBoundCIBinomial(success: Double!, trials: Double!, alpha: Double) throws -> Double {
        var res: Double
        if success == trials {
            res = 1.0
        }
        else {
            do {
                res = try SSProbabilityDistributions.quantileBetaDist(p: 1.0 - alpha, shapeA: success + 1, shapeB: trials - success)
                //                res = try SSProbabilityDistributions.quantileBetaDist(p: 1.0 - alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
            }
            catch {
                throw error
            }
        }
        return res
    }
    
    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Parameter alpha: alpha
    /// - Parameter alternative: .less, .greater or .twoSided
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2 || p0.isNaN
    public class func binomialTest<T>(data: Array<T>, characterSet: CharacterSet?, testProbability p0: Double!, successCodedAs successID: T,alpha: Double!,  alternative: SSAlternativeHypotheses) throws ->SSBinomialTestResult<T> where T: Comparable, T: Hashable, T: Codable {
        if p0.isNaN {
            os_log("p0 is NaN", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.count <= 2 {
            os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<T>.init(withArray: data, name: nil, characterSet: characterSet)
        if (examine.uniqueElements(sortOrder: .none)?.count)! > 2 {
            os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.binomialTest(data: examine, testProbability: p0, successCodedAs: successID, alpha: alpha, alternative: alternative)
        }
        catch {
            throw error
        }
    }
    
    
    
    /// Performs the binomial test
    /// ### Note ###
    /// - H<sub>0</sub>: The probability of success is equal to p0
    /// - H<sub>a1</sub>: the probability of success is not equal to p0 (two sided)
    /// - H<sub>a2</sub>: the probability of success is less than p0 (one sided)
    /// - H<sub>a3</sub>: the probability of success is greater than p0 (one sided)
    /// - Parameter data: Dichotomous data
    /// - Parameter p0: Probability
    /// - Parameter alpha: alpha
    /// - Parameter alternative: .less, .greater or .twoSided
    /// - Throws: SSSwiftyStatsError iff data.sampleSize <= 2 || data.uniqueElements(sortOrder: .none)?.count)! > 2 || p0.isNaN
    public class func binomialTest<T>(data: SSExamine<T>, testProbability p0: Double!, successCodedAs successID: T,alpha: Double!,  alternative: SSAlternativeHypotheses) throws ->SSBinomialTestResult<T>  {
        if p0.isNaN {
            os_log("p0 is NaN", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.sampleSize <= 2 {
            os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if (data.uniqueElements(sortOrder: .none)?.count)! > 2 {
            os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let success: Double = Double(data.frequency(successID))
        let failure: Double = Double(data.sampleSize) - success
        let n = success + failure
        let probSuccess = success / n
        var cintJeffreys = SSConfIntv()
        var cintClopperPearson = SSConfIntv()
        var fQ: Double
        switch alternative {
        case .less:
            do {
                cintJeffreys.lowerBound = 0.0
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                cintClopperPearson.lowerBound = 0.0
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha / 2.0, numeratorDF: 2 * (success + 1.0), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = 1.0 / (1.0 + ((n - success) / ((success + 1.0) * fQ)))
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .greater:
            do {
                cintJeffreys.upperBound = 1.0
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1.0))
                cintClopperPearson.lowerBound = 1.0 / (1.0 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.upperBound = 1.0
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .twoSided:
            do {
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha / 2.0)
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha / 2.0)
                cintJeffreys.intervalWidth = fabs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: 1.0 - alpha / 2.0, numeratorDF: 2 * (success + 1.0), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = 1.0 / (1.0 + ((n - success) / ((success + 1.0) * fQ)))
                fQ = try SSProbabilityDistributions.quantileFRatioDist(p: alpha / 2.0, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1.0))
                cintClopperPearson.lowerBound = 1.0 / (1.0 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.intervalWidth = fabs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        }
        var result = SSBinomialTestResult<T>()
        result.confIntJeffreys = cintJeffreys
        result.confIntClopperPearson = cintClopperPearson
        result.nTrials = Int(n)
        result.nSuccess = Int(success)
        result.nFailure = Int(failure)
        result.pValueExact = SSHypothesisTesting.binomialTest(numberOfSuccess: Int(success), numberOfTrials: Int(n), probability: p0,alpha: alpha,  alternative: alternative)
        result.probFailure = failure / n
        result.probSuccess = probSuccess
        result.probTest = p0
        result.successCode = successID
        return result
    }
    
    
    ///  Performs a two sample Kolmogorov-Smirnov test.
    /// ### Note ###
    /// H<sub>0</sub>: The two samples are from populations with same distribution function (F<sub>1</sub>(x) = F<sub>2</sub>(x))
    ///
    /// H<sub>a1</sub>:(F<sub>1</sub>(x) > F<sub>2</sub>(x))
    ///
    /// H<sub>a2</sub>:(F<sub>1</sub>(x) < F<sub>2</sub>(x))
    /// - Parameter set1: A Array object containg data for set 1
    /// - Parameter set2: A Array object containg data for set 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func kolmogorovSmirnovTwoSampleTest<T>(set1: Array<T>, set2: Array<T>, alpha: Double!) throws -> SSKSTwoSampleTestResult where T: Comparable, T: Hashable, T: Codable {
        if set1.count <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: SSExamine<T>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<T>.init(withArray: set2, name: nil, characterSet: nil), alpha: alpha)
        }
        catch {
            throw error
        }
    }
    
    
    ///  Performs a two sample Kolmogorov-Smirnov test.
    /// ### Note ###
    /// H<sub>0</sub>: The two samples are from populations with same distribution function (F<sub>1</sub>(x) = F<sub>2</sub>(x))
    ///
    /// H<sub>a1</sub>:(F<sub>1</sub>(x) > F<sub>2</sub>(x))
    ///
    /// H<sub>a2</sub>:(F<sub>1</sub>(x) < F<sub>2</sub>(x))
    /// - Parameter set1: A SSExamine object containg data for set 1
    /// - Parameter set2: A SSExamine object containg data for set 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func kolmogorovSmirnovTwoSampleTest<T>(set1: SSExamine<T>, set2: SSExamine<T>, alpha: Double!) throws -> SSKSTwoSampleTestResult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var a1 = set1.elementsAsArray(sortOrder: .ascending)!
        a1.append(contentsOf: set2.elementsAsArray(sortOrder: .ascending)!)
        let n1 = Double(set1.sampleSize)
        let n2 = Double(set2.sampleSize)
        var dcdf: Double
        var maxNeg: Double = 0.0
        var maxPos: Double = 0.0
        if n1 > n2 {
            for element in a1 {
                dcdf = set1.eCDF(element) - set2.eCDF(element)
                if dcdf < 0.0 {
                    maxNeg = dcdf < maxNeg ? dcdf : maxNeg
                }
                else {
                    maxPos = dcdf > maxPos ? dcdf : maxPos
                }
            }
        }
        else {
            for element in a1 {
                dcdf = set2.eCDF(element) - set1.eCDF(element)
                if dcdf < 0.0 {
                    maxNeg = dcdf < maxNeg ? dcdf : maxNeg
                }
                else {
                    maxPos = dcdf > maxPos ? dcdf : maxPos
                }
            }
        }
        let maxD: Double
        maxD = fabs(maxNeg) > fabs(maxPos) ? fabs(maxNeg) : fabs(maxPos)
        var z: Double = 0.0
        var p: Double = 0.0
        var q: Double = 0.0
        if !maxD.isNaN {
            z = maxD * sqrt(n1 * n2 / (n1 + n2))
            if ((z >= 0) && (z < 0.27)) {
                p = 1.0
            }
            else if ((z >= 0.27) && (z < 1.0)) {
                q = exp(-1.233701 * pow(z, -2.0))
                p = 1.0 - ((2.506628 * (q + pow(q, 9.0) + pow(q, 25.0))) / z)
            }
            else if ((z >= 1.0) && (z < 3.1)) {
                q = exp(-2.0 * pow(z, 2.0))
                p = 2.0 * (q - pow(q, 4.0) + pow(q, 9.0) - pow(q, 16.0))
            }
            else if (z >= 3.1) {
                p = 0.0
            }
        }
        var result = SSKSTwoSampleTestResult()
        result.dMaxAbs = maxD
        result.dMaxNeg = maxNeg
        result.dMaxPos = maxPos
        result.zStatistic = z
        result.p2Value = p
        result.sampleSize1 = set1.sampleSize
        result.sampleSize2 = set2.sampleSize
        return result
    }
    
    
    /// Performs the two-sided Wald Wolfowitz test for two samples
    /// - Parameter set1: Observations in group 1
    /// - Parameter set2: Observations in group 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set2.sampleSize <= 2
    public class func waldWolfowitzTwoSampleTest<T>(set1: SSExamine<T>!, set2: SSExamine<T>!) throws -> SSWaldWolfowitzTwoSampleTestResult {
        if set1.sampleSize <= 2 {
            os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups = Array<Int>.init(repeating: 1, count: set1.sampleSize)
        groups.append(contentsOf: Array<Int>.init(repeating: 2, count: set2.sampleSize))
        var sortedData: Array<T> = Array<T>()
        var data = set1.elementsAsArray(sortOrder: .original)!
        data.append(contentsOf: set2.elementsAsArray(sortOrder: .original)!)
        let sorter = SSDataGroupSorter.init(data: data, groups: groups)
        let sorted = sorter.sortedArrays()
        groups = sorted.sortedGroups
        sortedData = sorted.sortedData
        var temp = groups[0]
        var R: Int = 0
        var i: Int = 1
        while i < groups.count {
            if temp != groups[i] {
                R += 1
                temp = groups[i]
            }
            i += 1
        }
        var tempObject: T = sortedData[0]
        var nties: Int = 0
        var ntiedcases: Int = 0
        var ntiesintergroup: Int = 0
        var f1: Int
        var f2: Int
        f1 = set1.frequency(tempObject)
        f2 = set2.frequency(tempObject)
        if f1 > 0 && f2 > 0 {
            ntiedcases += f1 + f2
            ntiesintergroup += 1
        }
        i = 1
        while i < sortedData.count {
            if tempObject == sortedData[i] {
                nties += 1
            }
            else {
                f1 = set1.frequency(sortedData[i])
                f2 = set2.frequency(sortedData[i])
                if f1 > 0 && f2 > 0 {
                    ntiedcases += 1
                    ntiesintergroup += 1
                }
                tempObject = sortedData[i]
            }
            i += 1
        }
        R += 1
        var n1: Double = 0.0
        var n2: Double = 0.0
        for g in groups {
            if g == 1 {
                n1 += 1.0
            }
            else if g == 2 {
                n2 += 1.0
            }
        }
        var dtemp = n1 + n2
        var pAsymp = Double.nan
        var pExact = Double.nan
        let sigma = sqrt(2.0 * n1 * n2 * (2.0 * n1 * n2 - n1 - n2) / ((n1 + n2) * (n1 + n2) * (n1 + n2 - 1.0)))
        let mean = (2.0 * n1 * n2) / dtemp + 1.0
        var z = 0.0
        var sum = 0.0
        dtemp = Double(R) - mean
        z = dtemp / sigma
        pAsymp = 2.0 * SSProbabilityDistributions.cdfStandardNormalDist(u: -fabs(z))
        if n1 + n2 <= 30 {
            if !isOdd(Double(R)) {
                var r = 2
                var RR: Double
                while r <= R {
                    RR = Double(r)
                    sum += binomial2(n1 - 1.0, (RR / 2.0) - 1.0) * binomial2(n2 - 1.0,(RR / 2.0) - 1.0);
                    r += 1
                }
                pExact = 2.0 * sum / binomial2(n1 + n2, n1)
            }
            else {
                var r = 2
                var RR: Double
                while r <= R {
                    RR = Double(r)
                    sum += (binomial2(n1 - 1.0,(RR - 1.0) / 2.0) * binomial2(n2 - 1.0, (RR - 3.0) / 2.0) + binomial2(n1 - 1.0, (RR - 3.0) / 2.0) * binomial2(n2 - 1.0,(RR - 1.0) / 2.0))
                    r += 1
                }
                pExact = sum / binomial2(n1 + n2, n1)
            }
        }
        var result = SSWaldWolfowitzTwoSampleTestResult()
        result.zStat = z
        result.pValueExact = (1.0 - pExact) / 2.0
        result.pValueAsymp = pAsymp
        result.mean = mean
        result.variance = sigma
        result.nRuns = R
        result.nTiesIntergroup = ntiesintergroup
        result.nTiedCases = ntiedcases
        result.sampleSize1 = set1.sampleSize
        result.sampleSize2 = set2.sampleSize
        return result
    }
    /// Ranks the data
    /// ### Note ###
    /// Groups must be coded as an integer value starting at 1. The arrays sumOfRanks, meanRanks and sampleSizes contains [numberOfGroups] values. For group 1 the associated value has index 0!
    private struct rank<T> where T: Comparable, T: Hashable, T: Codable {
        /// The ranks
        public var ranks:Array<Double>!
        /// An Array containing "sample size" times a group identifier
        public var groups:Array<Int>?
        /// An array containing at grou
        public var sumOfRanks:Array<Double>!
        /// An array containg all ties precomputed (pow(t, 3) - t)
        public var ties:Array<Double>?
        /// The count of ties
        public var numberOfTies: Int!
        /// Mean ranks
        public var meanRanks:Array<Double>!
        /// Count of groups
        public var numberOfGroups:Int!
        /// Size of sample per group
        public var sampleSizes:Array<Double>!
        
        private var data:Array<T>!
        
        init(data array: Array<T>!,groups g: Array<Int>?) {
            ranks = Array<Double>()
            ties = Array<Double>()
            sumOfRanks = Array<Double>()
            if let gg = g {
                groups = gg
            }
            else {
                groups = nil
            }
            numberOfTies = 0
            data = array
            var temp = Array<Double>()
            var temp1 = Array<Double>()
            var temp3 = 0
            rank(data: data, ranks: &temp, ties: &temp1, numberOfTies: &temp3)
            ranks = temp
            ties = temp1
            numberOfTies = temp3
            if groups != nil {
                let uniqueGroups = Set<Int>.init(groups!)
                numberOfGroups = uniqueGroups.count
                meanRanks = Array<Double>.init(repeating: 0.0, count: uniqueGroups.count)
                sumOfRanks = Array<Double>.init(repeating: 0.0, count: uniqueGroups.count)
                sampleSizes = Array<Double>.init(repeating: 0.0, count: uniqueGroups.count)
                for i in uniqueGroups {
                    for k in 0..<groups!.count {
                        if i == groups![k] {
                            sumOfRanks[i - 1] += ranks[k]
                            sampleSizes[i - 1] += 1.0
                        }
                    }
                }
                for i in uniqueGroups {
                    meanRanks[i - 1] = sumOfRanks[i - 1] / sampleSizes[i - 1]
                }
            }
            else {
                numberOfGroups = 1
                meanRanks = Array<Double>.init(repeating: 0.0, count: 1)
                sumOfRanks = Array<Double>.init(repeating: 0.0, count: 1)
                sampleSizes = Array<Double>.init(repeating: 0.0, count: 1)
                for i in 0..<ranks.count {
                    sumOfRanks[0] += ranks[i]
                    sampleSizes[0] += 1.0
                }
                meanRanks[0] = sumOfRanks[0] / sampleSizes[0]
            }
            
        }
        /// A more general ranking routine
        /// - Paramater data: Array with data to rank
        /// - Parameter inout ranks: Upon return contains the ranks
        /// - Parameter inout ties: Upon return contains the correction terms for ties
        /// - Parameter inout numberOfTies: Upon return contains number of ties
        private func rank<T>(data: Array<T>, ranks: inout Array<Double>, ties: inout Array<Double>, numberOfTies: inout Int) where T: Comparable, T: Hashable, T: Codable {
            var pos: Int
            let examine: SSExamine<T> = SSExamine<T>.init(withArray: data, name: nil, characterSet: nil)
            var ptemp: Int
            var freq: Int
            var sum = 0.0
            numberOfTies = 0
            pos = 0
            while pos < examine.sampleSize {
                ptemp = pos + 1
                sum = Double(ptemp)
                freq = examine.frequency(data[pos])
                if freq == 1 {
                    ranks.append(sum)
                    pos += 1
                }
                else {
                    numberOfTies += 1
                    ties.append(pow(Double(freq), 3.0) - Double(freq))
                    sum = 0.0
                    for i in 0...(freq - 1) {
                        sum += Double(ptemp + i)
                    }
                    for _ in 1...freq {
                        ranks.append(sum / Double(freq))
                    }
                    pos = ptemp + freq - 1
                }
            }
        }
        
        
    }
    
    public class func kruskalWallisHTest<T>(data: Array<SSExamine<T>>, alpha: Double!) throws -> SSKruskalWallisHTestResult  {
        if data.count < 2 {
            os_log("number of groups is expected to be > 2", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups = Array<Int>()
        var a1 = Array<T>()
        var k = 1
        var N: Double = 0.0
        for examine in data {
            if examine.sampleSize < 2 {
                os_log("sample sizes are expected to be > 2", log: log_stat, type: .error)
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            groups.append(contentsOf: Array<Int>.init(repeating: k, count: examine.sampleSize))
            k += 1
            N += Double(examine.sampleSize)
            a1.append(contentsOf: examine.elementsAsArray(sortOrder: .original)!)
        }
        let sorter = SSDataGroupSorter.init(data: a1, groups: groups)
        let sorted = sorter.sortedArrays()
        let ranking = rank(data: sorted.sortedData, groups: sorted.sortedGroups)
        var sumRanks: Double = 0.0
        for rank in ranking.sumOfRanks {
            sumRanks += rank
        }
        if sumRanks != N * (N + 1) / 2.0 {
            os_log("internal error - contact the developer", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        var sum = 0.0
        for i in 0..<ranking.numberOfGroups {
            sum += pow(ranking.sumOfRanks[i], 2.0) / ranking.sampleSizes[i]
        }
        let H = 12.0 / (N * (N + 1)) * sum - 3 * (N + 1.0)
        let df = Double(ranking.numberOfGroups) - 1.0
        var ts: Double = 0.0
        for tie in ranking.ties! {
            ts += tie
        }
        ts = 1.0 - (ts / (pow(N, 3.0) - N))
        let Hc: Double
        if ts != 0.0 {
            Hc = H / ts
        }
        else {
            Hc = Double.nan
        }
        var p: Double
        let cv: Double
        do {
            p = try SSProbabilityDistributions.cdfChiSquareDist(chi: H, degreesOfFreedom: df)
            cv = try SSProbabilityDistributions.quantileChiSquareDist(p: 1.0 - alpha, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
        p = 1.0 - p
        var result = SSKruskalWallisHTestResult()
        result.nTies = ranking.numberOfTies
        result.Chi2 = H
        result.Chi2corrected = Hc
        result.pValue = p
        result.nGroups = ranking.numberOfGroups
        result.df = Int(df)
        result.nObservations = Int(N)
        result.meanRanks = ranking.meanRanks
        result.sumRanks = ranking.sumOfRanks
        result.alpha = alpha
        result.cv = cv
        return result
    }
    

}
