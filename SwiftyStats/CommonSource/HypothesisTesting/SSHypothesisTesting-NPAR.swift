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
#if os(macOS) || os(iOS)
import os.log
#endif


extension SSHypothesisTesting {
    /************************************************************************************************/
    // MARK: NPAR tests
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: Array<Double>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest<FPT: SSFloatingPoint & Codable>(array: Array<FPT>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult<FPT>? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<FPT, FPT>.init(withArray: array, name: nil, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: Array<Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest<FPT: SSFloatingPoint & Codable>(array: Array<FPT>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult<FPT>? {
        if array.count >= 2 {
            do {
                return try ksGoFTest(data: SSExamine<FPT, FPT>.init(withArray: array, name: nil, characterSet: nil), targetDistribution: target)
            }
            catch {
                throw error
            }
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        
    }
    
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// ### Note ###
    /// Calls ksGoFTest(data: SSExamine<Double, Double>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult?
    /// - Parameter data: SSExamine<Double, Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func kolmogorovSmirnovGoFTest<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult<FPT>? {
        do {
            return try ksGoFTest(data: data, targetDistribution: target)
        }
        catch {
            throw error
        }
    }
    
    /// Performs the goodness of fit test according to Kolmogorov and Smirnov.
    /// The K-S distribution is computed according to Richard Simard and Pierre L'Ecuyer (Journal of Statistical Software March 2011, Volume 39, Issue 11.)
    /// - Parameter data: SSExamine<Double, Double>
    /// - Parameter target: Distribution to test for
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func ksGoFTest<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>, targetDistribution target: SSGoFTarget) throws -> SSKSTestResult<FPT>? {
        // error handling
        if data.sampleSize < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let sortedData = data.uniqueElements(sortOrder: .ascending)!
        var dD: FPT = 0
        var dz: FPT
        var dtestCDF: FPT = 0
        var dtemp1: FPT = 0
        var dmax1n: FPT = 0
        var dmax2n: FPT = 0
        var dmax1p: FPT = 0
        var dmax2p: FPT = 0
        var dmaxn: FPT = 0
        var dmaxp: FPT = 0
        var dest1: FPT = 0
        var dest2: FPT = 0
        var dest3: FPT = 0
        var ii: Int = 0
        var ik: Int = 0
        var bok: Bool = false
        var bok1 = true
        var nt: FPT
        var ecdf: Dictionary<FPT, FPT> = Dictionary<FPT,FPT>()
        var lds: FPT = 0
        switch target {
        case .gaussian:
            dest1 = data.arithmeticMean!
            if let test = data.standardDeviation(type: .unbiased) {
                dest2 = test
            }
        case .exponential:
            dest3 = 0
            ik = 0
            for value in sortedData {
                if value <= 0 {
                    ik = ik + data.frequency(value)
                    dest3 = makeFP(ik) * value
                }
            }
            for value in sortedData {
                if value < 0 {
                    lds = 0
                }
                else {
                    lds = lds + makeFP(data.frequency(value)) / makeFP(data.sampleSize - ik)
                }
                ecdf[value] = lds
            }
            if lds == 0 || ik > (data.sampleSize - 2) {
                bok1 = false
            }
            if let tot = data.total {
                dest1 = makeFP(data.sampleSize - ik) / (tot - dest3)
            }
            else {
                dest1 = FPT.nan
            }
        case .uniform:
            dest1 = data.minimum!
            dest2 = data.maximum!
            ik = 0
        case .studentT:
            dest1 = makeFP(data.sampleSize)
            ik = 0
        case .laplace:
            dest1 = data.median!
            dest2 = data.medianAbsoluteDeviation(center: dest1, scaleFactor: 1)!
            ik = 0
        case .none:
            return nil
        }
        ii = 0
        for value in sortedData {
            switch target {
            case .gaussian:
                do {
                    dtestCDF = try cdfNormalDist(x: (value - dest1) / dest2, mean: 0, variance: 1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .exponential:
                do {
                    dtestCDF = try cdfExponentialDist(x: value, lambda: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .uniform:
                do {
                    dtestCDF = try cdfUniformDist(x: value, lowerBound: dest1, upperBound: dest2)
                    bok = true
                }
                catch {
                    throw error
                }
            case .studentT:
                do {
                    dtestCDF = try cdfStudentTDist(t: value, degreesOfFreedom: dest1)
                    bok = true
                }
                catch {
                    throw error
                }
            case .laplace:
                do {
                    dtestCDF = try cdfLaplaceDist(x: value, mean: dest1, scale: dest2)
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
        dmaxn = (abs(dmax1n) > abs(dmax2n)) ? dmax1n : dmax2n
        dmaxp = (dmax1p > dmax2p) ? dmax1p : dmax2p
        dD = (abs(dmaxn) > abs(dmaxp)) ? abs(dmaxn) : abs(dmaxp)
        dz = sqrt(makeFP(data.sampleSize - ik)) * dD
        let dp: FPT = 1 - KScdf(n: data.sampleSize, x: dD)
        var result = SSKSTestResult<FPT>()
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
                result.estimatedMean = 1 / dest1
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
    public class func adNormalityTest<FPT: SSFloatingPoint & Codable>(data: SSExamine<FPT, FPT>, alpha: FPT) throws -> SSADTestResult<FPT>? {
        if !data.isEmpty {
            do {
                return try adNormalityTest(array: data.elementsAsArray(sortOrder: .raw)!, alpha: alpha)
            }
            catch {
                throw error
            }
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
    }
    
    
    /// Performs the Anderson Darling test for normality. Returns a SSADTestResult struct.
    /// Adapts an algorithm originally developed by Marsaglia et al.(Evaluating the Anderson-Darling Distribution. Journal of Statistical Software 9 (2), 1–5. February 2004)
    /// - Parameter data: Data
    /// - Parameter alpha: Alpha
    /// - Throws: SSSwiftyStatsError if data.count < 2
    public class func adNormalityTest<FPT: SSFloatingPoint & Codable>(array: Array<FPT>, alpha: FPT) throws -> SSADTestResult<FPT>? {
        var ad: FPT = 0
        var a2: FPT
        var estMean: FPT
        var estSd: FPT
        var n: Int
        var tempArray: Array<FPT>
        var pValue: FPT
        if array.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be >= 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let _data: SSExamine<FPT, FPT>
        do {
            _data = try SSExamine<FPT, FPT>.init(withObject: array, levelOfMeasurement: .interval, name: nil, characterSet: nil)
        }
        catch {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("unable to create examine object", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        estMean = _data.arithmeticMean!
        estSd = _data.standardDeviation(type: .unbiased)!
        n = _data.sampleSize
        tempArray = _data.elementsAsArray(sortOrder: .ascending)! as Array<FPT>
        var i = 0
        var val: FPT
        var val1: FPT
        while i < n {
            val = tempArray[i]
            tempArray[i] = (val - estMean) / estSd
            i += 1
        }
        i = 0
        var k: FPT
        let NN: FPT = makeFP(n)
        let half: FPT = FPT.half
        var ex1, ex2, ex3, ex4, ex5: FPT
        while i < n {
            val = tempArray[i]
            val1 = tempArray[n - i - 1]
            k = makeFP(i)
            ex1 = ((2 * (k + 1) - 1) / NN)
            ex2 = (1 + erf1(val / FPT.sqrt2))
            ex3 = (1 + erf1(val1 / FPT.sqrt2))
            ex4 = log1(1 - half * ex3)
            ex5 = log1(half * ex2)
            ad += (ex1 * (ex5 + ex4))
            i += 1
        }
        a2 = -1 * NN - ad
        ad = a2
        if n > 8 {
            a2 = a2 * (1 + makeFP(0.75) / NN + makeFP(2.25) / (NN * NN))
        }
        pValue = makeFP(1 - PRIV_AD_Prob(n, makeFP(a2)))
        var result: SSADTestResult<FPT> = SSADTestResult<FPT>()
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
    fileprivate class func cdfMannWhitney<FPT: SSFloatingPoint & Codable>(U: FPT, m: Int!, n: Int!) throws -> FPT {
        // Algorithm AS 62 Applied Statistics (1973) Vol 22, No. 2
        if m <= 0 || n <= 0 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if U > (makeFP(m) * makeFP(n)) {
            return FPT.nan
        }
        var freq: Array<FPT> = Array<FPT>.init(repeating: makeFP(0), count: m * n * 2)
        var work: Array<FPT> = Array<FPT>.init(repeating: makeFP(0), count: m * n * 2)
        var minmn: Int
        var maxmmn: Int
        var mn1: Int
        var n1: Int
        var i: Int
        var _in: Int
        var l: Int
        var k: Int
        var j: Int
        var sum: FPT
        let one: FPT = 1
        let zero: FPT = 0
        minmn = min(m, n)
        if minmn < 1 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("m and n is expected to be > 0", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        mn1 = m * n + 1
        maxmmn = max(m, n)
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
        sum = 0
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
        return freq[integerValue(floor(U))]
    }
    
    /// Returns the sum of i for i = start...end
    fileprivate class func sumUp<FPT: SSFloatingPoint & Codable>(start: Int!, end: Int!) -> FPT {
        var sum: FPT = makeFP(start)
        var i: Int = start
        var comp: FPT = 0
        var oldsum: FPT = 0
        while i < end {
            oldsum = sum
            comp = comp + makeFP(i)
            sum = comp + oldsum
            comp = (oldsum - sum) + comp
//            sum += makeFP(i)
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
    public class func mannWhitneyUTest<T, FPT>(set1: Array<T>, set2: Array<T>)  throws -> SSMannWhitneyUTestResult<FPT> where T: Comparable, T: Hashable, T: Codable, FPT: Codable, FPT: SSFloatingPoint {
        if set1.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try mannWhitneyUTest(set1: SSExamine<T, FPT>.init(withArray: set1, name: nil, characterSet: nil) , set2: SSExamine<T, FPT>.init(withArray: set2, name: nil, characterSet: nil))
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
    public class func mannWhitneyUTest<T, FPT>(set1: SSExamine<T, FPT>, set2: SSExamine<T, FPT>)  throws -> SSMannWhitneyUTestResult<FPT>  where T: Comparable, T: Hashable, T: Codable, FPT: Codable, FPT: SSFloatingPoint {
        if set1.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups:Array<Int> = Array<Int>()
        var ties: Array<FPT> = Array<FPT>()
        var sumRanksSet1: FPT = 0
        var sumRanksSet2: FPT = 0
        groups.append(contentsOf: Array<Int>.init(repeating: 1, count: set1.sampleSize))
        groups.append(contentsOf: Array<Int>.init(repeating: 2, count: set2.sampleSize))
        var tempData = set1.elementsAsArray(sortOrder: .raw)!
        tempData.append(contentsOf: set2.elementsAsArray(sortOrder: .raw)!)
        let sorter = SSDataGroupSorter.init(data: tempData, groups: groups)
        let sorted: (Array<Int>, Array<T>) = sorter.sortedArrays()
        let rr: Rank<T, FPT> = Rank.init(data: sorted.1, groups: sorted.0)
        ties = rr.ties!
        sumRanksSet1 = rr.sumOfRanks[0]
        sumRanksSet2 = rr.sumOfRanks[1]
        let n1: FPT = makeFP(set1.sampleSize)
        let n2: FPT = makeFP(set2.sampleSize)
        let mn = n1 * n2
        let U1 = mn + (n1 * (n1 + 1)) / 2 - sumRanksSet1
        let U2 = mn + (n2 * (n2 + 1)) / 2 - sumRanksSet2
        if (U1 + U2) != mn {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("internal error", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        let S = n1 + n2
        var z: FPT = 0
        var pasymp1: FPT = 0
        var pasymp2: FPT = 0
        var pexact1: FPT = 0
        var pexact2: FPT = 0
        
        z = FPT.nan
        var temp1: FPT = 0
        var denom: FPT = 0
        var num: FPT = 0
        var i: Int = 0
        let U: FPT
        if U1 > (n1 * n2) / 2 {
            U = mn - U1
        }
        else {
            U = U1
        }
        if ties.count > 0 {
            while i < ties.count {
                temp1 += (ties[i] / 12)
                i += 1
            }
            let ex1: FPT = (mn / (S * (S - 1)))
            let ex2: FPT = (pow1(S, 3) - S) / 12
            denom = sqrt(ex1 * (ex2 - temp1))
//            denom = sqrt((mn / (S * (S - 1))) * ((pow1(S, 3) - S) / 12 - temp1))
            num = abs(U - mn / 2)
            z = num / denom
            pasymp1 = min(1 - cdfStandardNormalDist(u: z), cdfStandardNormalDist(u: z))
            pasymp2 = pasymp1 * 2
            pexact1 = FPT.nan
            pexact2 = FPT.nan
        }
        else {
            let e1: FPT = abs(U - mn / 2)
            let e2: FPT = (n1 + n2 + 1)
            let e3: FPT = (mn * e2) / 12
            z = e1 / sqrt(e3)
            if (n1 * n2) <= 400 && ((n1 * n2) + min(n1, n2)) <= 220 {
                do {
                    if U <= (n1 * n2 + 1) / 2 {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                    }
                    else {
                        pexact1 = try cdfMannWhitney(U: U, m: set1.sampleSize, n: set2.sampleSize)
                        pexact1 = 1 - pexact1
                    }
                    pexact2 = 2 * pexact1
                }
                catch {
                    throw error
                }
            }
            else {
                pexact1 = FPT.nan
                pexact2 = FPT.nan
            }
            pasymp1 = min(1 - cdfStandardNormalDist(u: z), cdfStandardNormalDist(u: z))
            pasymp2 = 2 * pasymp1
        }
        let W = sumRanksSet2
        var result: SSMannWhitneyUTestResult<FPT> = SSMannWhitneyUTestResult<FPT>()
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
    public class func wilcoxonMatchedPairs<FPT: SSFloatingPoint & Codable>(set1: Array<FPT>, set2: Array<FPT>) throws -> SSWilcoxonMatchedPairsTestResult<FPT> {
        if set1.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.wilcoxonMatchedPairs(set1: SSExamine<FPT, FPT>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<FPT, FPT>.init(withArray: set2, name: nil, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    
    /// Performs the Wilcoxon signed ranks test for matched pairs with continuity correction (no exact p values!)
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func wilcoxonMatchedPairs<FPT: SSFloatingPoint & Codable>(set1: SSExamine<FPT, FPT>, set2: SSExamine<FPT, FPT>) throws -> SSWilcoxonMatchedPairsTestResult<FPT> {
        if set1.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var i: Int
        //        var np: Int = 0
        //        var nn: Int = 0
        var nties: Int = 0
        var temp: FPT = 0
        var diff:Array<FPT> = Array<FPT>()
        let a1: Array<FPT> = set1.elementsAsArray(sortOrder: .raw)!
        let a2: Array<FPT> = set2.elementsAsArray(sortOrder: .raw)!
        let N = set1.sampleSize
        i = 0
        while i < N {
            temp = a2[i] - a1[i]
            if temp != 0 {
                diff.append(temp)
            }
            i += 1
        }
        var sorted = diff.sorted(by: {abs($0) < abs($1) } )
        var signs: Array<FPT> = Array<FPT>()
        var absDiffSorted:Array<FPT> = Array<FPT>()
        i = 0
        while i < sorted.count {
            signs.append(sorted[i] > 0 ? 1 : -1)
            absDiffSorted.append(abs(sorted[i]))
            i += 1
        }
        var ranks: Array<FPT>
        var ties: Array<FPT>
        let ranking: Rank<FPT, FPT> = Rank.init(data: absDiffSorted, groups: nil)
        ranks = ranking.ranks
        ties = ranking.ties!
        nties = ranking.numberOfTies
        let n = absDiffSorted.count
        var nposranks: Int = 0
        var nnegranks: Int = 0
        var sumposranks: FPT = 0
        var sumnegranks: FPT = 0
        var meanposranks: FPT
        var meannegranks: FPT
        i = 0
        while i < n {
            if signs[i] == 1 {
                nposranks += 1
                sumposranks += ranks[i]
            }
            else {
                nnegranks += 1
                sumnegranks += ranks[i]
            }
            i += 1
        }
        if sumnegranks + sumposranks != (makeFP(n) * (makeFP(n) + 1)) / 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("internal error", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        meannegranks = nnegranks > 0 ? sumnegranks / (makeFP(nnegranks)) : 0
        meanposranks = nposranks > 0 ? sumposranks / (makeFP(nposranks)) : 0
        var z: FPT
        var ts: FPT = 0
        i = 0
        while i < ties.count {
            ts += ties[i] / 48
            i += 1
        }
        let z0: FPT = abs(min(sumnegranks, sumposranks)) - (makeFP(n)) * ((makeFP(n)) + 1) / 4
        let n1n21n1: FPT = (makeFP(n)) * ((makeFP(n)) + 1) * (2 * (makeFP(n)) + 1)
        let sigma: FPT = sqrt(n1n21n1 / 24 - ts)
        let correct: FPT = FPT.half * sign(z0)
//        if z0 < 0.0 {
//            correct = -0.5
//        }
//        else {
//            correct = 0.5
//        }
        z = (z0 - correct) / sigma
//        z = (fabs(max(sumnegranks, sumposranks) - (Double(n) * (Double(n) + 1.0) / 4.0))) / sqrt(Double(n) * (Double(n) + 1.0) * (2.0 * Double(n) + 1.0) / 24.0 - ts)
        let pp: FPT = cdfStandardNormalDist(u: z)
        let p: FPT = 1 - cdfStandardNormalDist(u: z)
        let cohenD: FPT = abs(z) / sqrt(2 * makeFP(N))
        var result = SSWilcoxonMatchedPairsTestResult<FPT>()
        result.p2Value = 2 * min(pp, p)
        result.sampleSize = makeFP(N)
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
    public class func signTest<FPT: SSFloatingPoint & Codable>(set1: Array<FPT>, set2: Array<FPT>) throws -> SSSignTestRestult<FPT> {
        if set1.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.count != set2.count {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try signTest(set1: SSExamine<FPT, FPT>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<FPT, FPT>.init(withArray: set2, name: nil, characterSet: nil))
        }
        catch {
            throw error
        }
    }
    
    /// Performs the sign test
    /// - Parameter set1: Observations 1
    /// - Parameter set2: Observations 2
    /// - Throws: SSSwiftyStatsError iff set1.sampleSize <= 2 || set1.sampleSize <= 2 || set1.sampleSize != set2.sampleSize
    public class func signTest<FPT: SSFloatingPoint & Codable>(set1: SSExamine<FPT, FPT>, set2: SSExamine<FPT, FPT>) throws -> SSSignTestRestult<FPT> {
        if set1.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set1.sampleSize != set2.sampleSize {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be equal to sample size of set2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let a1 = set1.elementsAsArray(sortOrder: .raw)!
        let a2 = set2.elementsAsArray(sortOrder: .raw)!
        var np: Int = 0
        var nn: Int = 0
        var nties: Int = 0
        var temp: FPT = 0
        var i: Int = 0
        while i < a1.count {
            temp = a2[i] - a1[i]
            if temp > 0 {
                np += 1
            }
            else if temp < 0 {
                nn += 1
            }
            else {
                nties += 1
            }
            i += 1
        }
        var pexact1: FPT = 0
        var pexact2: FPT = 0
        var z: FPT
        let nnpnp = nn + np
        let nnpnpf: FPT = makeFP(nnpnp)
        let r = min(np,nn)
        temp = makeFP(max(nn, np))
        if nnpnp <= 1000 {
            if nnpnp == 0 {
                pexact1 = FPT.half
            }
            else {
                i = 0
                while i <= r {
                    pexact1 += binomial2(nnpnpf, makeFP(i)) * pow1(FPT.half, nnpnpf)
                    if i == r - 1 {
                        pexact2 = 1 - pexact1
                    }
                    i += 1
                }
            }
        }
        z = temp - FPT.half * nnpnpf - FPT.half
        z = -z / (FPT.half * sqrt(nnpnpf))
        let pasymp = cdfStandardNormalDist(u: z)
        var result = SSSignTestRestult<FPT>()
        result.pValueExact = min(pexact1, pexact2)
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
    public class func binomialTest<FPT: SSFloatingPoint & Codable>(numberOfSuccess success: Int!, numberOfTrials trials: Int!, probability p0: FPT, alpha: FPT, alternative: SSAlternativeHypotheses) -> FPT {
        if p0.isNaN {
            return FPT.nan
        }
        var pV: FPT = 0
        var pV1: FPT = 0
        let q = 1 - p0
        var i: Int
        switch alternative {
        case .less:
            pV = cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
        case .greater:
            pV = cdfBinomialDistribution(k: trials - success, n: trials, probability: q, tail: .lower)
        case .twoSided:
            // algorithm adapted fropm R function binom.test
            var c1: Int = 0
            let d: FPT = pdfBinomialDistribution(k: success, n: trials, probability: p0)
            let m: FPT = makeFP(trials) * p0
            if success == integerValue(ceil(m)) {
                pV = 1
            }
            else if success < integerValue(ceil(m)) {
                i = integerValue(ceil(m))
                for j in i...trials {
                    if pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * makeFP(1 + 1E-7)) {
                        c1 = j - 1
                        break
                    }
                }
                pV = cdfBinomialDistribution(k: success, n: trials, probability: p0, tail: .lower)
                pV1 = cdfBinomialDistribution(k: c1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
            else {
                i = 0
                for j in 0...integerValue(floor(m)) {
                    if pdfBinomialDistribution(k: j, n: trials, probability: p0) <= (d * makeFP(1 + 1E-7)) {
                        c1 = j + 1
                    }
                }
                pV = cdfBinomialDistribution(k: c1 - 1, n: trials, probability: p0, tail: .lower)
                pV1 = cdfBinomialDistribution(k: success - 1, n: trials, probability: p0, tail: .upper)
                pV = pV + pV1
            }
        }
        return pV
    }
    
    
    fileprivate class func lowerBoundCIBinomial<FPT: SSFloatingPoint & Codable>(success: FPT, trials: FPT, alpha: FPT) throws -> FPT {
        var res: FPT
        if success == 0 {
            res = 0
        }
        else {
            do {
                res = try quantileBetaDist(p: alpha, shapeA: success, shapeB: trials - success + 1)
                //                res = try quantileBetaDist(p: alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
            }
            catch {
                throw error
            }
        }
        return res
    }
    
    fileprivate class func upperBoundCIBinomial<FPT: SSFloatingPoint & Codable>(success: FPT, trials: FPT, alpha: FPT) throws -> FPT {
        var res: FPT
        if success == trials {
            res = 1
        }
        else {
            do {
                res = try quantileBetaDist(p: 1 - alpha, shapeA: success + 1, shapeB: trials - success)
                //                res = try quantileBetaDist(p: 1.0 - alpha, shapeA: success + 0.5, shapeB: trials - success + 0.5)
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
    public class func binomialTest<T, FPT>(data: Array<T>, characterSet: CharacterSet?, testProbability p0: FPT, successCodedAs successID: T,alpha: FPT,  alternative: SSAlternativeHypotheses) throws -> SSBinomialTestResult<T, FPT> where T: Comparable, T: Hashable, T: Codable, FPT: SSFloatingPoint, FPT: Codable {
        if p0.isNaN {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("p0 is NaN", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let examine = SSExamine<T, FPT>.init(withArray: data, name: nil, characterSet: characterSet)
        if (examine.uniqueElements(sortOrder: .none)?.count)! > 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            }
            
            #endif
            
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
    public class func binomialTest<T, FPT>(data: SSExamine<T, FPT>, testProbability p0: FPT, successCodedAs successID: T,alpha: FPT,  alternative: SSAlternativeHypotheses) throws -> SSBinomialTestResult<T, FPT> where  T: Comparable, T: Hashable, T: Codable, FPT: SSFloatingPoint & Codable {
        if p0.isNaN {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("p0 is NaN", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if data.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if (data.uniqueElements(sortOrder: .none)?.count)! > 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("observations are expected to be dichotomous", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        let success: FPT = makeFP(data.frequency(successID))
        let failure: FPT = (makeFP(data.sampleSize)) - success
        let n: FPT = success + failure
        let probSuccess = success / n
        var cintJeffreys: SSConfIntv<FPT> = SSConfIntv<FPT>()
        var cintClopperPearson: SSConfIntv<FPT> = SSConfIntv<FPT>()
        var fQ: FPT
        switch alternative {
        case .less:
            do {
                cintJeffreys.lowerBound = 0
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = abs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                cintClopperPearson.lowerBound = 0
                fQ = try quantileFRatioDist(p: makeFP(1.0 ) - alpha / 2, numeratorDF: 2 * (success + 1), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = makeFP(1.0 ) / (makeFP(1.0 ) + ((n - success) / ((success + makeFP(1.0 )) * fQ)))
                cintClopperPearson.intervalWidth = abs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .greater:
            do {
                cintJeffreys.upperBound = FPT.one
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha)
                cintJeffreys.intervalWidth = abs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try quantileFRatioDist(p: alpha / 2, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1))
                let ex1: FPT = (n - success + FPT.one)
                let ex2: FPT = success * fQ
                let ex3: FPT = FPT.one + (ex1 / ex2)
                cintClopperPearson.lowerBound = FPT.one / ex3
//                cintClopperPearson.lowerBound = 1 / (1 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.upperBound = 1
                cintClopperPearson.intervalWidth = abs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        case .twoSided:
            do {
                cintJeffreys.upperBound = try upperBoundCIBinomial(success: success, trials: n, alpha: alpha / 2)
                cintJeffreys.lowerBound = try lowerBoundCIBinomial(success: success, trials: n, alpha: alpha / 2)
                cintJeffreys.intervalWidth = abs(cintJeffreys.upperBound! - cintJeffreys.lowerBound!)
                fQ = try quantileFRatioDist(p: 1 - alpha / 2, numeratorDF: 2 * (success + 1), denominatorDF: 2 * (n - success))
                cintClopperPearson.upperBound = 1 / (1 + ((n - success) / ((success + 1) * fQ)))
                fQ = try quantileFRatioDist(p: alpha / 2, numeratorDF: 2 * success, denominatorDF: 2 * (n - success + 1))
                let ex1: FPT = (n - success + FPT.one)
                let ex2: FPT = success * fQ
                let ex3: FPT = FPT.one + (ex1 / ex2)
                cintClopperPearson.lowerBound = FPT.one / ex3
//                cintClopperPearson.lowerBound = 1 / (1 + ((n - success + 1) / (success * fQ)))
                cintClopperPearson.intervalWidth = abs(cintClopperPearson.upperBound! - cintClopperPearson.lowerBound!)
            }
            catch {
                throw error
            }
        }
        var result: SSBinomialTestResult<T, FPT> = SSBinomialTestResult<T, FPT>()
        result.confIntJeffreys = cintJeffreys
        result.confIntClopperPearson = cintClopperPearson
        result.nTrials = integerValue(n)
        result.nSuccess = integerValue(success)
        result.nFailure = integerValue(failure)
        result.pValueExact = SSHypothesisTesting.binomialTest(numberOfSuccess: integerValue(success), numberOfTrials: integerValue(n), probability: p0,alpha: alpha,  alternative: alternative)
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
    public class func kolmogorovSmirnovTwoSampleTest<T, FPT>(set1: Array<T>, set2: Array<T>, alpha: FPT) throws -> SSKSTwoSampleTestResult<FPT> where T: Comparable, T: Hashable, T: Codable, FPT: SSFloatingPoint & Codable {
        if set1.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.count <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        do {
            return try SSHypothesisTesting.kolmogorovSmirnovTwoSampleTest(set1: SSExamine<T, FPT>.init(withArray: set1, name: nil, characterSet: nil), set2: SSExamine<T, FPT>.init(withArray: set2, name: nil, characterSet: nil), alpha: alpha)
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
    public class func kolmogorovSmirnovTwoSampleTest<T, FPT>(set1: SSExamine<T, FPT>, set2: SSExamine<T, FPT>, alpha: FPT) throws -> SSKSTwoSampleTestResult<FPT> where FPT: SSFloatingPoint & Codable {
        if set1.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var a1 = set1.elementsAsArray(sortOrder: .ascending)!
        a1.append(contentsOf: set2.elementsAsArray(sortOrder: .ascending)!)
        let n1: FPT = makeFP(set1.sampleSize)
        let n2: FPT = makeFP(set2.sampleSize)
        var dcdf: FPT
        var maxNeg: FPT = 0
        var maxPos: FPT = 0
        if n1 > n2 {
            for element in a1 {
                dcdf = set1.eCDF(element) - set2.eCDF(element)
                if dcdf < 0 {
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
                if dcdf < 0 {
                    maxNeg = dcdf < maxNeg ? dcdf : maxNeg
                }
                else {
                    maxPos = dcdf > maxPos ? dcdf : maxPos
                }
            }
        }
        let maxD: FPT
        maxD = abs(maxNeg) > abs(maxPos) ? abs(maxNeg) : abs(maxPos)
        var z: FPT = 0
        var p: FPT = 0
        var q: FPT = 0
        if !maxD.isNaN {
            z = maxD * sqrt(n1 * n2 / (n1 + n2))
            if ((z >= 0) && (z < makeFP(0.27 ))) {
                p = 1
            }
            else if ((z >= makeFP(0.27 )) && (z < 1)) {
                q = exp1(makeFP(-1.233701 ) * pow1(z, -2))
                p = 1 - ((makeFP(2.506628 ) * (q + pow1(q, 9) + pow1(q, 25))) / z)
            }
            else if ((z >= 1) && (z < makeFP(3.1 ))) {
                q = exp1(-2 * pow1(z, 2))
                p = 2 * (q - pow1(q, 4) + pow1(q, 9) - pow1(q, 16))
            }
            else if (z >= makeFP(3.1 )) {
                p = 0
            }
        }
        var result: SSKSTwoSampleTestResult<FPT> = SSKSTwoSampleTestResult<FPT>()
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
    public class func waldWolfowitzTwoSampleTest<T, FPT>(set1: SSExamine<T, FPT>, set2: SSExamine<T, FPT>) throws -> SSWaldWolfowitzTwoSampleTestResult<FPT> where FPT: SSFloatingPoint & Codable {
        if set1.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 1 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if set2.sampleSize <= 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("sample size of set 2 is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups = Array<Int>.init(repeating: 1, count: set1.sampleSize)
        groups.append(contentsOf: Array<Int>.init(repeating: 2, count: set2.sampleSize))
        var sortedData: Array<T> = Array<T>()
        var data = set1.elementsAsArray(sortOrder: .raw)!
        data.append(contentsOf: set2.elementsAsArray(sortOrder: .raw)!)
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
        var n1: FPT = 0
        var n2: FPT = 0
        for g in groups {
            if g == 1 {
                n1 += 1
            }
            else if g == 2 {
                n2 += 1
            }
        }
        var dtemp: FPT = n1 + n2
        var pAsymp: FPT = FPT.nan
        var pExact: FPT = FPT.nan
        var ex1, ex2, ex3, ex4: FPT
        ex1 = 2 * n1 * n2
        ex2 = (2 * n1 * n2 - n1 - n2)
        ex3 = (n1 + n2) * (n1 + n2)
        ex4 = (n1 + n2 - 1)
        let sigma: FPT = sqrt((ex1 * ex2) / (ex3 * ex4))
        let mean: FPT = (2 * n1 * n2) / dtemp + 1
        var z: FPT = 0
        var sum: FPT = 0
        dtemp = (makeFP(R)) - mean
        z = dtemp / sigma
        pAsymp = 2 * min(1 - cdfStandardNormalDist(u: z), cdfStandardNormalDist(u: z))
        var RR: FPT
        if n1 + n2 <= 30 {
            if !isOdd(Double(R)) {
                var r = 2
                while r <= R {
                    RR = makeFP(r)
                    ex1 = binomial2(n1 - 1, (RR / 2) - 1)
                    ex2 = binomial2(n2 - 1,(RR / 2) - 1)
                    sum +=  ex1 * ex2
                    r += 1
                }
                pExact = 2 * sum / binomial2(n1 + n2, n1)
            }
            else {
                var r = 2
                while r <= R {
                    RR = makeFP(r)
                    ex1 = binomial2(n1 - 1,(RR - 1) / 2)
                    ex2 = binomial2(n2 - 1, (RR - 3) / 2)
                    ex3 = binomial2(n1 - 1, (RR - 3) / 2)
                    ex4 = binomial2(n2 - 1,(RR - 1) / 2)
                    sum += (ex1 * ex2 + ex3 * ex4)
                    r += 1
                }
                pExact = sum / binomial2(n1 + n2, n1)
            }
        }
        var result: SSWaldWolfowitzTwoSampleTestResult<FPT> = SSWaldWolfowitzTwoSampleTestResult<FPT>()
        result.zStat = z
        result.pValueExact = (1 - pExact) / 2
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
    private struct Rank<T, FPT> where T: Comparable, T: Hashable, T: Codable, FPT: SSFloatingPoint & Codable {
        /// The ranks
        public var ranks:Array<FPT>
        /// An Array containing "sample size" times a group identifier
        public var groups:Array<Int>?
        /// An array containing at grou
        public var sumOfRanks:Array<FPT>
        /// An array containg all ties precomputed (pow(t, 3) - t)
        public var ties:Array<FPT>?
        /// The count of ties
        public var numberOfTies: Int!
        /// Mean ranks
        public var meanRanks:Array<FPT>!
        /// Count of groups
        public var numberOfGroups:Int!
        /// Size of sample per group
        public var sampleSizes:Array<FPT>!
        
        private var data:Array<T>
        
        init(data array: Array<T>, groups g: Array<Int>?) {
            ranks = Array<FPT>()
            ties = Array<FPT>()
            sumOfRanks = Array<FPT>()
            if let gg = g {
                groups = gg
            }
            else {
                groups = nil
            }
            numberOfTies = 0
            data = array
            var temp = Array<FPT>()
            var temp1 = Array<FPT>()
            var temp3 = 0
            rank(data: data, ranks: &temp, ties: &temp1, numberOfTies: &temp3)
            ranks = temp
            ties = temp1
            numberOfTies = temp3
            if groups != nil {
                let uniqueGroups = Set<Int>.init(groups!)
                numberOfGroups = uniqueGroups.count
                meanRanks = Array<FPT>.init(repeating: makeFP(0.0), count: uniqueGroups.count)
                sumOfRanks = Array<FPT>.init(repeating: makeFP(0.0), count: uniqueGroups.count)
                sampleSizes = Array<FPT>.init(repeating: makeFP(0.0), count: uniqueGroups.count)
                for i in uniqueGroups {
                    for k in 0..<groups!.count {
                        if i == groups![k] {
                            sumOfRanks[i - 1] += ranks[k]
                            sampleSizes[i - 1] += 1
                        }
                    }
                }
                for i in uniqueGroups {
                    meanRanks[i - 1] = sumOfRanks[i - 1] / sampleSizes[i - 1]
                }
            }
            else {
                numberOfGroups = 1
                meanRanks = Array<FPT>.init(repeating: makeFP(0.0), count: 1)
                sumOfRanks = Array<FPT>.init(repeating: makeFP(0.0), count: 1)
                sampleSizes = Array<FPT>.init(repeating: makeFP(0.0), count: 1)
                for i in 0..<ranks.count {
                    sumOfRanks[0] += ranks[i]
                    sampleSizes[0] += 1
                }
                meanRanks[0] = sumOfRanks[0] / sampleSizes[0]
            }
            
        }
        /// A more general ranking routine
        /// - Paramater data: Array with data to rank
        /// - Parameter inout ranks: Upon return contains the ranks
        /// - Parameter inout ties: Upon return contains the correction terms for ties
        /// - Parameter inout numberOfTies: Upon return contains number of ties
        private func rank<T, FPT>(data: Array<T>, ranks: inout Array<FPT>, ties: inout Array<FPT>, numberOfTies: inout Int) where T: Comparable, T: Hashable, T: Codable, FPT: SSFloatingPoint & Codable {
            var pos: Int
            let examine: SSExamine<T, FPT> = SSExamine<T, FPT>.init(withArray: data, name: nil, characterSet: nil)
            var ptemp: Int
            var freq: Int
            var sum: FPT = 0
            numberOfTies = 0
            pos = 0
            while pos < examine.sampleSize {
                ptemp = pos + 1
                sum = makeFP(ptemp)
                freq = examine.frequency(data[pos])
                if freq == 1 {
                    ranks.append(sum)
                    pos += 1
                }
                else {
                    numberOfTies += 1
                    ties.append(pow1(makeFP(freq), 3) - makeFP(freq))
                    sum = 0
                    for i in 0...(freq - 1) {
                        sum += makeFP(ptemp + i)
                    }
                    for _ in 1...freq {
                        ranks.append(sum / (makeFP(freq)))
                    }
                    pos = ptemp + freq - 1
                }
            }
        }
        
        
    }
    
    public class func kruskalWallisHTest<T, FPT>(data: Array<SSExamine<T, FPT>>, alpha: FPT) throws -> SSKruskalWallisHTestResult<FPT> where T: Codable & Hashable & Comparable, FPT: SSFloatingPoint & Codable {
        if data.count < 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("number of groups is expected to be > 2", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var groups = Array<Int>()
        var a1 = Array<T>()
        var k = 1
        var N: FPT = 0
        for examine in data {
            if examine.sampleSize < 2 {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 10, *) {
                    os_log("sample sizes are expected to be > 2", log: log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            groups.append(contentsOf: Array<Int>.init(repeating: k, count: examine.sampleSize))
            k += 1
            N += makeFP(examine.sampleSize)
            a1.append(contentsOf: examine.elementsAsArray(sortOrder: .raw)!)
        }
        let sorter = SSDataGroupSorter.init(data: a1, groups: groups)
        let sorted = sorter.sortedArrays()
        let ranking: Rank<T, FPT> = Rank<T, FPT>.init(data: sorted.sortedData, groups: sorted.sortedGroups)
//        let ranking = Rank(data: sorted.sortedData, groups: sorted.sortedGroups)
        var sumRanks: FPT = 0
        for rank in ranking.sumOfRanks {
            sumRanks += rank
        }
        if sumRanks != N * (N + 1) / 2 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 10, *) {
                os_log("internal error - contact the developer", log: log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .internalError, file: #file, line: #line, function: #function)
        }
        var sum: FPT = 0
        for i in 0..<ranking.numberOfGroups {
            sum += pow1(ranking.sumOfRanks[i], 2) / ranking.sampleSizes[i]
        }
        var ex1, ex2: FPT
        ex1 = (N * (N + 1))
        ex2 = 3 * (N + 1)
        let H: FPT = 12 / ex1 * sum - ex2
        let df: FPT = (makeFP(ranking.numberOfGroups)) - 1
        var ts: FPT = 0
        for tie in ranking.ties! {
            ts += tie
        }
        ts = 1 - (ts / (pow1(N, 3) - N))
        let Hc: FPT
        if ts != 0 {
            Hc = H / ts
        }
        else {
            Hc = FPT.nan
        }
        var p: FPT
        let cv: FPT
        do {
            p = try cdfChiSquareDist(chi: H, degreesOfFreedom: df)
            cv = try quantileChiSquareDist(p: 1 - alpha, degreesOfFreedom: df)
        }
        catch {
            throw error
        }
        p = 1 - p
        var result: SSKruskalWallisHTestResult<FPT> = SSKruskalWallisHTestResult<FPT>()
        result.nTies = ranking.numberOfTies
        result.Chi2 = H
        result.Chi2corrected = Hc
        result.pValue = p
        result.nGroups = ranking.numberOfGroups
        result.df = integerValue(df)
        result.nObservations = integerValue(N)
        result.meanRanks = ranking.meanRanks
        result.sumRanks = ranking.sumOfRanks
        result.alpha = alpha
        result.cv = cv
        return result
    }
    
    
}
