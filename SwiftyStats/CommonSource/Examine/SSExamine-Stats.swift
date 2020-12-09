//
//  SSExamine-Stats.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
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


// Definition of statistics
extension SSExamine {
    
    internal var isNotEmptyAndNumeric: Bool {
        get {
            return (!self.isEmpty && self.isNumeric)
        }
    }
    
    /// Sum over all squared elements. Returns Double.nan iff data are non-numeric.
    public var squareTotal: FPT  {
        if isNotEmptyAndNumeric {
            var s: FPT = 0
            var temp: FPT
            for (item, freq) in self.elements {
                temp =  Helpers.makeFP(item)
                if !temp.isNaN {
                    s = s + SSMath.pow1(temp , 2) *  Helpers.makeFP(freq)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s
        }
        else {
            return FPT.nan
        }
    }
    
    /// Sum of all elements raised to power p
    /// - Parameter p: Power
    public func poweredTotal(power p: FPT) -> FPT? {
        if isNotEmptyAndNumeric {
            var s: FPT = 0
            var temp: FPT
            for (item, freq) in self.elements {
                temp =  Helpers.makeFP(item)
                if !temp.isNaN {
                    s = s + SSMath.pow1(temp, p) *  Helpers.makeFP(freq)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s
        }
        else {
            return nil
        }
    }
    
    /// Total of all elements. Returns Double.nan iff data are non-numeric.
    public var total: FPT? {
        if isNotEmptyAndNumeric {
            var s: FPT = 0
            var temp: FPT
            for (item, freq) in self.elements {
                temp =  Helpers.makeFP(item)
                if !temp.isNaN {
                    s = s + temp *  Helpers.makeFP(freq)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s
        }
        else {
            return nil
        }
    }
    
    /// Returns the sum of all inverted elements
    public var inverseTotal: FPT? {
        if isNotEmptyAndNumeric {
            var s: FPT = 0
            var temp: FPT
            for (item, freq) in self.elements {
                temp =  Helpers.makeFP(item)
                if !temp.isNaN {
                    if !temp.isZero {
                        s = s + (1 / temp) *  Helpers.makeFP(freq)
                    }
                    else {
                        return FPT.infinity
                    }
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s
        }
        else {
            return nil
        }
    }
    
    /// Returns the total of squares about the mean. If a user defined `value` is supplied, that value will be used.
    /// - Parameter value: value
    ///
    /// ### Note ###
    /// If `value` is nil, `self.arithmeticMean` will be used.
    public func tss(value: FPT? = nil) -> FPT? {
        if isNotEmptyAndNumeric && self.sampleSize >= 2 {
            var diff: FPT = 0
            var sum: FPT = 0
            var temp: FPT
            if let m = value {
                for (item, freq) in self.elements {
                    temp =  Helpers.makeFP(item)
                    if !temp.isNaN {
                        diff = temp - m
                        sum = sum + diff * diff *  Helpers.makeFP(freq)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return sum
            }
            else {
                let m = self.arithmeticMean!
                for (item, freq) in self.elements {
                    temp =  Helpers.makeFP(item)
                    if !temp.isNaN {
                        diff = temp - m
                        sum = sum + diff * diff *  Helpers.makeFP(freq)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return sum
            }
        }
        else {
            return nil
        }
    }

    // MARK: Location

    // MARK: TODO --> recursive mean/sd??
    
    internal func updateDescriptives(withElement x: FPT) {
        if self.isNotEmptyAndNumeric {
            var currMean: FPT = FPT.zero
            if let m = aMean {
                currMean = m
            }
            else {
                currMean = FPT.zero
            }
            let n =  Helpers.makeFP(self.sampleSize) + FPT.one
            let newMean = currMean + (x - currMean) / n
            aMean = newMean
        }
    }
    
    
    /// Arithemtic mean. Will be Double.nan for non-numeric data.
    public var arithmeticMean: FPT? {
        if isNotEmptyAndNumeric {
            return self.total! /  Helpers.makeFP(self.sampleSize)
        }
        else {
            return nil
        }
    }

    /// The mode. Can contain more than one item. Can be nil for empty tables.
    public var mode: Array<SSElement>? {
        get {
            if !isEmpty {
                var result: Array<SSElement> = Array<SSElement>()
                let ft = self.frequencyTable(sortOrder: .frequencyDescending)
                let freq = ft.first?.frequency
                for tableItem in ft {
                    if tableItem.frequency >= freq! {
                        result.append(tableItem.item)
                    }
                    else {
                        break
                    }
                }
                return result
            }
            else {
                return nil
            }
        }
    }
    
    /// An arrayof the most common item(s). Same as mode. nil for empty tables.
    public var commonest: Array<SSElement>? {
        return mode
    }
    
    
    /// An array containing scarcest element(s). nil for empty tables.
    public var scarcest: Array<SSElement>? {
        if !isEmpty {
            var result: Array<SSElement> = Array<SSElement>()
            let ft = self.frequencyTable(sortOrder: .frequencyAscending)
            let freq = ft.first?.frequency
            for tableItem in ft {
                if tableItem.frequency <= freq! {
                    result.append(tableItem.item)
                }
                else {
                    break
                }
            }
            return result.sorted(by: <)
        }
        else {
            return nil
        }
    }
    
    /// Returns the q-quantile.
    /// - Throws: SSSwiftyStatsError.invalidArgument if data are non-numeric and/or if 0 < q >=1
    public func quantile(q: FPT) throws -> FPT? {
        if q.isZero || q < 0 || q >= 1 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("p has to be > 0.0 and < 1.0", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isNumeric {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Quantile is not defined for non-numeric data.", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var result: FPT = 0
        if !isEmpty && self.sampleSize >= 2 {
            let k: FPT =  Helpers.makeFP(self.sampleSize) * q
            let a = self.elementsAsArray(sortOrder: .ascending)!
            var temp3: SSElement
            if Helpers.isInteger(k) {
                temp3 = a [Helpers.integerValue(k) - 1]
                let temp1: FPT =  Helpers.makeFP(temp3)
                if !temp1.isNaN {
                    temp3 = a [Helpers.integerValue(k)]
                    let temp2: FPT =  Helpers.makeFP(temp3)
                    if !temp2.isNaN {
                        result = (temp1 + temp2) / 2
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                temp3 = a [Helpers.integerValue(ceil(k - FPT.one))]
                let temp1: FPT =  Helpers.makeFP(temp3)
                if !temp1.isNaN {
                    result = temp1
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return result
        }
        else {
            return nil
        }
    }
    
    /// Returns a SSQuartile struct or nil for empty or non-numeric tables.
    public var quartile: SSQuartile<FPT>? {
        get {
            if isNotEmptyAndNumeric {
                var res = SSQuartile<FPT>()
                do {
                    res.q25 = try self.quantile(q:  Helpers.makeFP(0.25))!
                    res.q75 = try self.quantile(q:  Helpers.makeFP(0.75))!
                    res.q50 = try self.quantile(q: FPT.half)!
                }
                catch {
                    return nil
                }
                return res
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the geometric mean.
    public var geometricMean: FPT? {
        get {
            if isNotEmptyAndNumeric {
                let a: FPT = self.logProduct!
                let b: FPT =  Helpers.makeFP(self.sampleSize)
                let c: FPT = SSMath.exp1(a / b)
                return c
            }
            else {
                return nil
            }
        }
    }
    
    /// Harmonic mean. Can be nil for non-numeric data.
    public var harmonicMean: FPT? {
        get {
            if isNotEmptyAndNumeric {
                return  Helpers.makeFP(self.sampleSize) / self.inverseTotal!
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns the contraharmonic mean (== (mean of squared elements) / (arithmetic mean))
    public var contraHarmonicMean: FPT? {
        if isNotEmptyAndNumeric {
            let st: FPT = self.squareTotal
            let sqM: FPT = st /  Helpers.makeFP(self.sampleSize)
            let m = self.arithmeticMean!
            if !m.isZero {
                return sqM / m
            }
            else {
                return -FPT.infinity
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the powered mean of order n
    /// - Parameter n: The order of the powered mean
    /// - Returns: The powered mean, nil if the receiver contains non-numerical data.
    public func poweredMean(order: FPT) -> FPT? {
        if order <= 0 {
            return nil
        }
        if isNotEmptyAndNumeric {
            if let sum: FPT = self.poweredTotal(power: order) {
                let n: FPT =  Helpers.makeFP(self.sampleSize)
                let result: FPT = SSMath.pow1(sum / n, 1 / order)
                return result
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the trimmed mean of all elements after dropping a fraction of alpha of the smallest and largest elements.
    /// - Parameter alpha: Fraction to drop
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func trimmedMean(alpha: FPT) throws -> FPT? {
        if alpha <= 0 || alpha >=  Helpers.makeFP(0.5 ) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("alpha has to be greater than zero and smaller than 0.5", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if isNotEmptyAndNumeric {
            let a = self.elementsAsArray(sortOrder: .ascending)!
            let l = a.count
            let v: FPT = floor( Helpers.makeFP(l) * alpha)
            var s: FPT = 0
            var k: FPT = 0
            for i in Helpers.integerValue(v)...l - Helpers.integerValue(v) - 1  {
                let temp: FPT =  Helpers.makeFP(a[i])
                if !temp.isNaN  {
                    s = s + temp
                    k = k + 1
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s / k
        }
        else {
            return nil
        }
    }
    
    /// Returns the mean after replacing a given fraction (alpha) at the high and low end with the most extreme remaining values.
    /// - Parameter alpha: Fraction
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func winsorizedMean(alpha: FPT) throws -> FPT? {
        if alpha <= 0 || alpha >=  Helpers.makeFP(0.5 ) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("alpha has to be greater than zero and smaller than 0.5", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if isNotEmptyAndNumeric {
            let a = self.elementsAsArray(sortOrder: .ascending)!
            let l = a.count
            let ll: FPT =  Helpers.makeFP(l)
            let v: FPT = floor( Helpers.makeFP(l) * alpha)
            var s: FPT = 0
            for i in Helpers.integerValue(v)...l - Helpers.integerValue(v) - 1  {
                let temp: FPT =  Helpers.makeFP(a[i])
                if !temp.isNaN {
                    s = s + temp
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            let temp: FPT =  Helpers.makeFP(a [Helpers.integerValue(v)])
            let temp1: FPT =  Helpers.makeFP(a [Helpers.integerValue(ll - Helpers.integerPart(v) - 1)])
            if !temp.isNaN && !temp1.isNaN {
                s = s + v * (temp + temp1)
            }
            else {
                fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
            }
            return s /  Helpers.makeFP(self.sampleSize)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the Gastwirth estimator (https://www.r-bloggers.com/gastwirths-location-estimator/)
    public var gastwirth: FPT? {
        get {
            if !self.isNotEmptyAndNumeric {
                return nil
            }
            else {
                let q_13: FPT? = try! self.quantile(q:  Helpers.makeFP(1.0 / 3.0 ))
                let q_5: FPT? = self.median
                let q_23: FPT? = try! self.quantile(q:  Helpers.makeFP(2.0 / 3.0 ))
                return  Helpers.makeFP(0.3 ) * q_13! +  Helpers.makeFP(0.4 ) * q_5! +  Helpers.makeFP(0.3 ) * q_23!
            }
        }
    }
    
    
    /// The median. Can be nil for non-numeric data.
    public var median: FPT? {
        get {
            var res: FPT
            if isNotEmptyAndNumeric {
                do {
                    res = try self.quantile(q: FPT.half)!
                }
                catch {
                    return nil
                }
                return res
            }
            else {
                return nil
            }
        }
    }
    
    // MARK: Products
    
    /// Product of all elements. Will be Double.nan for non-numeric data.
    public var product: FPT? {
        if isNotEmptyAndNumeric {
            var p: FPT = 1
            for (item, freq) in self.elements {
                let temp: FPT =  Helpers.makeFP(item)
                if !temp.isNaN {
                    if temp.isZero {
                        return 0
                    }
                    else {
                        p = p * SSMath.pow1(temp,  Helpers.makeFP(freq))
                    }
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return p
        }
        else {
            return nil
        }
    }
    
    /// The log-Product. Will be Double.nan for non-numeric data or if there is at least one item lower than zero. Returns -inf if there is at least one item equals to zero.
    public var logProduct: FPT? {
        var sp : FPT = 0
        if isNotEmptyAndNumeric {
            for (item, freq) in self.elements {
                let temp: FPT =  Helpers.makeFP(item)
                if !temp.isNaN {
                    if temp > 0 {
                        sp = sp + SSMath.log1(temp) *  Helpers.makeFP(freq)
                    }
                    else if temp.isZero {
                        return -FPT.infinity
                    }
                    else {
                        return FPT.nan
                    }
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return sp
        }
        else {
            return nil
        }
    }
    
    // MARK: Dispersion
    
    /// The largest item. Can be nil for empty tables.
    public var maximum: SSElement? {
        get {
            if !isEmpty {
                let a = self.elementsAsArray(sortOrder: .ascending)!
                return a.last
            }
            else {
                return nil
            }
        }
    }
    
    /// The smallest item. Can be nil for empty tables.
    public var minimum: SSElement? {
        get {
            if !isEmpty {
                let a = self.elementsAsArray(sortOrder: .ascending)!
                return a.first
            }
            else {
                return nil
            }
        }
    }
    
    /// The difference between maximum and minimum. Can be nil for empty tables.
    public var range: FPT? {
        get {
            if isNotEmptyAndNumeric {
                let tempMax: FPT =  Helpers.makeFP(self.maximum)
                let tempMin: FPT =  Helpers.makeFP(self.minimum)
                if !tempMax.isNaN && !tempMin.isNaN {
                    return tempMax - tempMin
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns the quartile devation (interquartile range / 2.0)
    public var quartileDeviation: FPT? {
        if let iqr: FPT = self.interquartileRange {
            return iqr / 2
        }
        else {
            return nil
        }
    }
    
    /// Returns the relative quartile distance
    public var relativeQuartileDistance: FPT? {
        if let q: SSQuartile = self.quartile {
            return (q.q75 - q.q25) / q.q50
        }
        else {
            return nil
        }
    }
    
    /// Returns the mid-range
    public var midRange: FPT? {
        if isNotEmptyAndNumeric {
            let tempMax: FPT =  Helpers.makeFP(self.maximum)
            let tempMin: FPT =  Helpers.makeFP(self.minimum)
            if !tempMax.isNaN && !tempMin.isNaN {
                return (tempMax + tempMin) / 2
            }
            else {
                fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
            }
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the interquartile range
    public var interquartileRange: FPT? {
        get {
            if isNotEmptyAndNumeric {
                do {
                    return try interquantileRange(lowerQuantile:  Helpers.makeFP(0.25), upperQuantile:  Helpers.makeFP(0.75))!
                }
                catch {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the interquartile range between two quantiles
    /// - Parameter lower: Lower quantile
    /// - Parameter upper: Upper quantile
    /// - Throws: SSSwiftyStatsError.invalidArgument if upper.isZero || upper < 0.0 || upper >= 1.0 || lower.isZero || lower < 0.0 || lower >= 1.0 || upper < lower
    public func interquantileRange(lowerQuantile lower: FPT, upperQuantile upper: FPT) throws -> FPT? {
        if upper.isZero || upper < 0 || upper >= 1 || lower.isZero || lower < 0 || lower >= 1 {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("lower and upper quantile has to be > 0.0 and < 1.0", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if upper < lower {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("lower quantile has to be less than upper quantile", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isNumeric {
            return nil
        }
        if lower == upper {
            return 0
        }
        do {
            if let q1 = try quantile(q: upper), let q2 = try quantile(q: lower) {
                return q1 - q2
            }
            else {
                return nil
            }
        }
        catch {
            return nil
        }
    }
    
    /// Returns the sample variance.
    /// - Parameter type: Can be .sample and .unbiased
    public func variance(type: SSVarianceType) -> FPT? {
        switch type {
        case .biased:
            return moment(r: 2, type: .central)
        case .unbiased:
            if isNotEmptyAndNumeric && self.sampleSize >= 2 {
                let m = self.arithmeticMean!
                var diff: FPT = 0
                var sum: FPT = 0
                for (item, freq) in self.elements {
                    let temp: FPT =  Helpers.makeFP(item)
                    if !temp.isNaN {
                        diff = temp - m
                        sum = sum + diff * diff *  Helpers.makeFP(freq)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return sum /  Helpers.makeFP(self.sampleSize - 1)
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the sample standard deviation.
    /// - Parameter type: .biased or .unbiased
    public func standardDeviation(type: SSStandardDeviationType) -> FPT? {
        if let v = variance(type: SSVarianceType(rawValue: type.rawValue)!) {
            return v.squareRoot()
        }
        else {
            return nil
        }
    }
    
    
    
    
    /// Returns the standard error of the sample
    public var standardError: FPT? {
        if isNotEmptyAndNumeric {
            if let sd = self.standardDeviation(type: .unbiased) {
                return sd /  Helpers.makeFP(self.sampleSize)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the entropy of the sample. Defined only for nominal or ordinal data
    public var entropy: FPT? {
        if !isEmpty {
            var s: FPT = 0
            for item in self.uniqueElements(sortOrder: .none)! {
                s += self.rFrequency(item) * SSMath.log21(self.rFrequency(item))
            }
            return -s
        }
        else {
            return nil
        }
    }
    
    /// Returns the relative entropy of the sample. Defined only for nominal or ordinal data
    public var relativeEntropy: FPT? {
        if let e = self.entropy {
            return e / SSMath.log21( Helpers.makeFP(self.sampleSize))
        }
        else {
            return nil
        }
    }
    
    // Returns the Herfindahl index
    public var herfindahlIndex: FPT? {
        if isNotEmptyAndNumeric {
            var s: FPT = 0
            var p: FPT = 0
            if let tot = self.total {
                for item in self.elementsAsArray(sortOrder: .raw)! {
                    let x: FPT =  Helpers.makeFP(item)
                    if !x.isNaN {
                        p = x / tot
                        s += p * p
                    }
                }
                return s
            }
            else {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("measure is not available", log: .log_stat, type: .error)
                }
                
                #endif
                
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the Herfindahl measure
    public var conc: FPT? {
        return self.herfindahlIndex
    }
    
    /// Returns the Gini coefficient
    public var gini: FPT? {
        var ex1: FPT
        var ex2: FPT
        var ex3: FPT
        var ex4: FPT
        if isNotEmptyAndNumeric {
            if self.sampleSize < 2 {
                return nil
            }
            let sorted = self.elementsAsArray(sortOrder: .ascending)!
            var s: FPT = 0
            let N: FPT =  Helpers.makeFP(self.sampleSize)
            let m = self.arithmeticMean!
            for i in 1...self.sampleSize {
                let x: FPT =  Helpers.makeFP(sorted[i - 1])
                if !x.isNaN {
                    ex1 = 2 *  Helpers.makeFP(i)
                    ex2 = ex1 - N
                    ex3 = ex2 - FPT.one
                    ex4 = ex3 * x
                    s = s + ex4
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return s / (SSMath.pow1(N, 2) * m)
        }
        else {
            return nil
        }
    }
    
    /// The normalized Gini measure
    public var giniNorm: FPT? {
        get {
            if let g = self.gini {
                let N: FPT =  Helpers.makeFP(self.sampleSize)
                return g * N / (N - 1)
            }
            else {
                return nil
            }
        }
    }
    
    /// The concentration ratio
    public func CR(_ g: Int) -> FPT? {
        if isNotEmptyAndNumeric {
            if g > 0 && g <= self.sampleSize {
                let a = self.elementsAsArray(sortOrder: .descending)!
                var sum: FPT = 0
                for i in 0..<g {
                    let x: FPT =  Helpers.makeFP(a[i])
                    if !x.isNaN {
                        sum = sum + x
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return sum
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the alpha-confidence interval of the mean when the population variance is known
    /// - Parameter a: Alpha
    /// - Parameter sd: Standard deviation of the population
    public func normalCI(alpha a: FPT, populationSD sd: FPT) -> SSConfIntv<FPT>? {
        if alpha <= 0 || alpha >= 1 {
            return nil
        }
        if isNotEmptyAndNumeric {
            var upper: FPT
            var lower: FPT
            var width: FPT
            var t1: FPT
            var u: FPT
            do {
                let m = self.arithmeticMean!
                let pp: FPT =  Helpers.makeFP(alpha)
                u = try SSProbDist.StandardNormal.quantile(p: 1 - ( pp / 2))
                let n: FPT =  Helpers.makeFP(self.sampleSize)
                t1 = sd / n.squareRoot()
                width = u * t1
                upper = m + width
                lower = m - width
                var result = SSConfIntv<FPT>()
                result.lowerBound = lower
                result.upperBound = upper
                result.intervalWidth = 2 * width
                return result
            }
            catch {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the alpha-confidence interval of the mean when the population variance is unknown
    /// - Parameter a: Alpha
    public func studentTCI(alpha a: FPT) -> SSConfIntv<FPT>? {
        if alpha <= 0 || alpha >= 1 {
            return nil
        }
        if isNotEmptyAndNumeric {
            var upper: FPT
            var lower: FPT
            var width: FPT
            var m: FPT
            var u: FPT
            m = self.arithmeticMean!
            if let s = self.standardDeviation(type: .unbiased) {
                do {
                    u = try SSProbDist.StudentT.quantile(p:  Helpers.makeFP(1) - a / 2 , degreesOfFreedom:  Helpers.makeFP(self.sampleSize - 1))
                }
                catch {
                    return nil
                }
                let n: FPT =  Helpers.makeFP(self.sampleSize)
                lower = m - u * s / n.squareRoot()
                upper = m + u * s / n.squareRoot()
                width = u * s / n.squareRoot()
                var result = SSConfIntv<FPT>()
                result.lowerBound = lower
                result.upperBound = upper
                result.intervalWidth = 2 * width
                return result
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the 0.95-confidence interval of the mean using Student's T distribution.
    public var meanCI: SSConfIntv<FPT>? {
        get {
            return self.studentTCI(alpha:  Helpers.makeFP(0.05))
        }
    }
    
    /// Returns the coefficient of variation. A shorctut for coefficientOfVariation:
    public var cv: FPT? {
        return coefficientOfVariation
    }
    
    
    /// Returns the coefficient of variation
    public var coefficientOfVariation: FPT? {
        if isNotEmptyAndNumeric {
            if let s = self.standardDeviation(type: .unbiased) {
                return s / self.arithmeticMean!
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the mean absolute difference
    public var meanDifference: FPT? {
        if isNotEmptyAndNumeric {
            if self.sampleSize < 2 {
                return nil
            }
            if let g = self.gini, let m = self.arithmeticMean {
                return g * 2 * m
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the median absolute deviation around the reference point given (`rp`). If you would like to know the median absoulute deviation from the median, you can do so by setting the reference point to the median
    /// - Parameter rp: Reference point
    /// - Parameter scaleFactor: Used for consistency reasons. If nil, the default value will be used.
    /// ### Note ###
    /// The scale factor is valid for normally distributed data only.
    public func medianAbsoluteDeviation(center rp: FPT, scaleFactor c: FPT?) -> FPT? {
        if !isNotEmptyAndNumeric || rp.isNaN {
            return nil
        }
        var diffArray:Array<FPT> = Array<FPT>()
        let values = self.elementsAsArray(sortOrder: .ascending)!
        let result: FPT
        for item in values  {
            let t1: FPT =  Helpers.makeFP(item)
            if !t1.isNaN {
                diffArray.append(abs(t1 - rp))
            }else {
                fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
            }
        }
        let sortedDifferences = diffArray.sorted(by: {$0 < $1})
        let k: FPT =  Helpers.makeFP(sortedDifferences.count) *  Helpers.makeFP(0.5 )
        if Helpers.isInteger(k) {
            result = (sortedDifferences [Helpers.integerValue(k - 1)] + sortedDifferences [Helpers.integerValue(k)]) / 2
        }
        else {
            result = sortedDifferences [Helpers.integerValue(ceil(k - FPT.one))]
        }
        var cf:FPT
        if c != nil {
            cf = c!
        }
        else {
            // = 1 / Standard.quantile(0.75)
            cf =  Helpers.makeFP(1.482602218505601860547)
        }
        return cf * result
    }
    
    /// Returns the mean absolute deviation around the reference point given. If you would like to know the mean absoulute deviation from the median, you can do so by setting the reference point to the median
    /// - Parameter rp: Reference point
    public func meanAbsoluteDeviation(center rp: FPT) -> FPT? {
        if !isNotEmptyAndNumeric || rp.isNaN {
            return nil
        }
        var sum: FPT = 0
        var f1: FPT
        var c: Int = 0
        for (item, freq) in self.elements {
            let t1: FPT =  Helpers.makeFP(item)
            if !t1.isNaN {
                f1 =  Helpers.makeFP(freq)
                sum = sum + abs(t1 - rp) * f1
                c = c + freq
            }
            else {
                fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
            }
        }
        let cc: FPT =  Helpers.makeFP(c)
        return sum / cc
    }
    
    
    /// Returns the relative mean absolute difference
    public var meanRelativeDifference: FPT? {
        if let md = meanDifference {
            return md / arithmeticMean!
        }
        else {
            return nil
        }
    }
    
    /// Returns the semi-variance
    /// - Parameter type: SSSemiVariance.lower or SSSemiVariance.upper
    public func semiVariance(type: SSSemiVariance) -> FPT? {
        if isNotEmptyAndNumeric {
            switch type {
            case .lower:
                let a = self.elementsAsArray(sortOrder: .ascending)!
                let m: FPT = self.arithmeticMean!
                var s: FPT = 0
                var k: FPT = 0
                for itm in a {
                    let t: FPT =  Helpers.makeFP(itm)
                    if !t.isNaN {
                        if t < m {
                            s = s + SSMath.pow1(t - m, 2)
                            k = k + 1
                        }
                        else {
                            break
                        }
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return s / k
            case .upper:
                let a = self.elementsAsArray(sortOrder: .descending)!
                let m: FPT = self.arithmeticMean!
                var s: FPT = 0
                var k: FPT = 0
                for itm in a {
                    let t: FPT =  Helpers.makeFP(itm)
                    if !t.isNaN {
                        if t > m {
                            s = s + SSMath.pow1(t - m, 2)
                            k = k + 1
                        }
                        else {
                            break
                        }
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return s / k
            }
        }
        else {
            return nil
        }
    }
    
    
    // MARK: Empirical Moments
    
    /// Returns the r_th moment of the given type.
    /// If .central is specified, the r_th central moment of all elements with respect to their mean will be returned.
    /// If .origin is specified, the r_th moment about the origin will be returned.
    /// If .standardized is specified, the r_th standardized moment will be returned.
    /// - Parameter r: r
    public func moment(r: Int, type: SSMomentType) -> FPT? {
        switch type {
        case .central:
            return centralMoment(r: r)
        case .origin:
            return originMoment(r: r)
        case .standardized:
            return standardizedMoment(r: r)
        }
    }
    
    /// Returns the r_th central moment of all elements with respect to their mean. Will be Double.nan if isEmpty == true and data are not numerical
    /// - Parameter r: r
    fileprivate func centralMoment(r: Int!) -> FPT? {
        if isNotEmptyAndNumeric {
            let m = self.arithmeticMean!
            var diff: FPT = 0
            var sum: FPT = 0
            let rr: FPT =  Helpers.makeFP(r)
            for (item, freq) in self.elements {
                let t: FPT =  Helpers.makeFP(item)
                if !t.isNaN {
                    diff = t - m
                    sum = sum + SSMath.pow1(diff, rr) *  Helpers.makeFP(freq)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return sum /  Helpers.makeFP(self.sampleSize)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the r_th moment about the origin of all elements. Will be Double.nan if isEmpty == true and data are not numerical
    /// - Parameter r: r
    fileprivate func originMoment(r: Int!) -> FPT? {
        if isNotEmptyAndNumeric {
            var sum: FPT = 0
            let rr: FPT =  Helpers.makeFP(r)
            for (item, freq) in self.elements {
                let t: FPT =  Helpers.makeFP(item)
                if !t.isNaN {
                    sum = sum + SSMath.pow1(t, rr) *  Helpers.makeFP(freq)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            return sum /  Helpers.makeFP(self.sampleSize)
        }
        else {
            return nil
        }
    }
    
    /// Returns then r_th standardized moment.
    fileprivate func standardizedMoment(r: Int!) -> FPT? {
        if isNotEmptyAndNumeric {
            var sum: FPT = 0
            let m = self.arithmeticMean!
            let sd = self.standardDeviation(type: .biased)!
            let rr: FPT =  Helpers.makeFP(r)
            if !sd.isZero {
                for (item, freq) in self.elements {
                    let t: FPT =  Helpers.makeFP(item)
                    if !t.isNaN {
                        sum = sum + SSMath.pow1( ( t - m ) / sd, rr) *  Helpers.makeFP(freq)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                return sum /  Helpers.makeFP(self.sampleSize)
            }
            else {
                return FPT.infinity
            }
        }
        else {
            return nil
        }
    }
    
    // FIXME: AUTOCORR
    
    /// Returns the lag-n autocorrelation of the data.
    /// - Parameter n: Lag (default = 1)
    public func autocorrelation(n: Int = 1) throws -> Double? {
        if self.isNotEmptyAndNumeric {
            do {
                let bl: SSBoxLjungResult = try SSHypothesisTesting.autocorrelation(data: self as! SSExamine<Double, Double>)
                if let l = bl.coefficients?[n] {
                    return l
                }
                else {
                    return nil
                }
            }
            catch {
                throw error
            }
        }
        else {
            return nil
        }
    }
    
    // MARK: Empirical distribution parameters
    
    /// Returns the kurtosis excess
    public var kurtosisExcess: FPT? {
        if isNotEmptyAndNumeric {
            let m4 = moment(r: 4, type: .central)!
            let m2 = moment(r: 2, type: .central)!
            return m4 / SSMath.pow1(m2, 2) - 3
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the kurtosis.
    public var kurtosis: FPT? {
        if let k = kurtosisExcess {
            return k + 3
        }
        else {
            return nil
        }
    }
    
    /// Returns the type of kurtosis.
    public var kurtosisType: SSKurtosisType? {
        get {
            if let ke = kurtosisExcess {
                if ke < 0 {
                    return .platykurtic
                }
                else if ke.isZero {
                    return .mesokurtic
                }
                else {
                    return .leptokurtic
                }
            }
            else {
                return nil
            }
        }
    }
    
    
    
    /// Returns the skewness.
    public var skewness: FPT? {
        if isNotEmptyAndNumeric {
            if let m3 = moment(r: 3, type: .central), let s3 = standardDeviation(type: .biased) {
                return m3 / SSMath.pow1(s3, 3)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the type of skewness
    public var skewnessType: SSSkewness? {
        get {
            if let sk = skewness {
                if sk < 0 {
                    return .leftSkewed
                }
                else if sk.isZero {
                    return .symmetric
                }
                else {
                    return .rightSkewed
                }
            }
            else {
                return nil
            }
        }
    }
    
    // FIXME: GRUBBS
    /// Returns true, if there are outliers.
    /// - Parameter testType: SSOutlierTest.grubbs or SSOutlierTest.esd (Rosner Test)
    public func hasOutliers(testType: SSOutlierTest) -> Bool? {
        if isNotEmptyAndNumeric {
            switch testType {
            case .grubbs:
                do {
                    let res: SSGrubbsTestResult<SSElement, FPT> = try SSHypothesisTesting.grubbsTest(data:self, alpha:  Helpers.makeFP(0.05))
                    return res.hasOutliers
                }
                catch {
                    return nil
                }
            case .esd:
                var tempArray = Array<Double>()
                let a:Array<SSElement> = self.elementsAsArray(sortOrder: .raw)!
                for itm in a {
                    let t: Double =  Helpers.makeFP(itm)
                    if !t.isNaN {
                        tempArray.append(t)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                if let res = try! SSHypothesisTesting.esdOutlierTest(array: tempArray, alpha: 0.05, maxOutliers: self.sampleSize / 2, testType: .bothTails) {
                    if res.countOfOutliers! > 0 {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else {
                    return nil
                }
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns an Array containing outliers if those exist. Uses the ESD statistics,
    /// - Parameter alpha: Alpha
    /// - Parameter max: Maximum number of outliers to return
    /// - Parameter testType: SSOutlierTest.grubbs or SSOutlierTest.esd (Rosner Test)
    public func outliers(alpha: FPT!, max: Int!, testType t: SSESDTestType) -> Array<SSElement>? {
        if isNotEmptyAndNumeric {
            var tempArray = Array<Double>()
            let a:Array<SSElement> = self.elementsAsArray(sortOrder: .raw)!
            for itm in a {
                let temp: Double =  Helpers.makeFP(itm)
                if !temp.isNaN {
                    tempArray.append(temp)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            if let res: SSESDTestResult<SSElement, FPT> = try! SSHypothesisTesting.esdOutlierTest(data: self, alpha: alpha, maxOutliers: max, testType: t) {
                if res.countOfOutliers! > 0 {
                    return res.outliers
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns true, if the sammple seems to be drawn from a normally distributed population with mean = mean(sample) and sd = sd(sample)
    public var isGaussian: Bool? {
        if !isNotEmptyAndNumeric {
            return nil
        }
        else {
            do {
                if let r = try SSHypothesisTesting.ksGoFTest(array: self.elementsAsArray(sortOrder: .ascending)! as! Array<FPT>, targetDistribution: .gaussian) {
                    if let p = r.pValue {
                        let test = p > self.alpha
                        return test
                    }
                    else {
                        return nil
                    }
                }
                else {
                    return nil
                }
            }
            catch {
                return nil
            }
        }
    }
    
    /// Tests, if the sample was drawn from population with a particular distribution function
    // - Parameter target: Distribution to test
    public func testForDistribution(targetDistribution target: SSGoFTarget) throws -> SSKSTestResult<FPT>? {
        if !isNotEmptyAndNumeric {
            return nil
        }
        else {
            do {
                return try SSHypothesisTesting.ksGoFTest(array: self.elementsAsArray(sortOrder: .ascending)! as! Array<FPT>, targetDistribution: target)
            }
            catch {
                throw error
            }
        }
    }
    
    /// Returns the statistics needed to create a Box-Whisker Plot
    /// - Returns: A SSBoxWhisker structure
    public var boxWhisker: SSBoxWhisker<SSElement, FPT>? {
        get {
            if isNotEmptyAndNumeric {
                do {
                    var res: SSBoxWhisker<SSElement, FPT> = SSBoxWhisker<SSElement, FPT>()
                    res.median = self.median
                    res.q25 = try self.quantile(q:  Helpers.makeFP(0.25))
                    res.q75 = try self.quantile(q:  Helpers.makeFP(0.75))
                    res.iqr = self.interquartileRange
                    let a = self.elementsAsArray(sortOrder: .descending)!
                    var iqr3h: FPT
                    var iqr3t: FPT
                    var notchCoeff: FPT
                    let N: FPT =  Helpers.makeFP(self.sampleSize)
                    if res.iqr != nil {
                        iqr3h =  Helpers.makeFP(1.5 ) * res.iqr!
                        iqr3t =  Helpers.makeFP(2.0 ) * iqr3h
                        notchCoeff =  Helpers.makeFP(1.58 ) * res.iqr! / sqrt(N)
                    }
                    else {
                        return nil
                    }
                    res.uNotch = res.median! + notchCoeff
                    res.lNotch = res.median! - notchCoeff
                    res.extremes = Array<SSElement>()
                    res.outliers = Array<SSElement>()
                    for i in 0..<self.sampleSize {
                        let temp: FPT =  Helpers.makeFP(a[i])
                        if !temp.isNaN {
                            if temp > res.q75! + iqr3t {
                                res.outliers?.append(a[i])
                            }
                            else if temp > res.q75! + iqr3h {
                                res.extremes?.append(a[i])
                            }
                            else {
                                res.uWhiskerExtreme = a[i]
                                break
                            }
                        }
                    }
                    for i in stride(from: self.sampleSize - 1, through: 0, by: -1) {
                        let temp: FPT =  Helpers.makeFP(a[i])
                        if !temp.isNaN {
                            if temp < res.q25! - iqr3t {
                                res.outliers?.append(a[i])
                            }
                            else if temp < res.q25! - iqr3h {
                                res.extremes?.append(a[i])
                            }
                            else {
                                res.lWhiskerExtreme = a[i]
                                break
                            }
                        }
                    }
                    return res
                }
                catch {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }
    
    
    
    
}
