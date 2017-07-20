//
//  SSSwiftyStats-EnumsStructs.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 01.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//
/*
 MIT License
 
 Copyright (c) 2017 Volker Thieme
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation


/// Type of confidence interval
public enum SSCIType {
    /// To use in cases were the unbiased standard deviation is known
    case normal
    /// To use in cases were the unbiased standard deviation is unknown
    case student
}

/// Confidence interval struct
public struct SSConfIntv {
    /// Upper bound of the CI
    var upperBound: Double
    /// Lower bound of the CI
    var lowerBound: Double
    /// Range of the CI
    var intervalWidth: Double
    
    var type: SSCIType
    
    init(lower: Double, upper: Double, width: Double, type: SSCIType) {
        upperBound = upper
        lowerBound = lower
        intervalWidth = width
        self.type = type
    }
    
    init() {
        upperBound = 0
        lowerBound = 0
        intervalWidth = 0
        self.type = .normal
    }
}
/// Defines the format of the Cumulative Frequency Table
public enum SSCumulativeFrequencyTableFormat {
    /// Each item will be shown as many as found
    case eachUniqueItem
    /// Each item will be shown once
    case eachItem
}

/// Defines the level of measurement. In future versions this setting will be used to determine the available statistics.
public enum SSLevelOfMeasurement: Int {
    case nominal
    case ordinal
    case interval
    case ratio
}


/// Defines the sorting order of the elements.
public enum SSSortUniqeItems {
    /// Ascending order
    case ascending
    /// Descending order
    case descending
    /// Undefined/not determined
    case none
}

/// Defines the sort order of the Frequency Table
public enum SSFrequencyTableSortOrder {
    case frequencyAscending
    case frequencyDescending
    case valueAscending
    case valueDescending
    case none
}
/// Defines the sort order of items when exported as an array
public enum SSDataArraySortOrder {
    /// Ascending order
    case ascending
    /// Descending order
    case descending
    /// Original order
    case original
    /// Undefined/not determined
    case none
}
/// Defines the
public enum SSLeveneTestType {
    /// Use the median (Brown-Forsythe-Test)
    case median
    /// Use the arithmetic mean
    case mean
    /// Use the trimmed mean
    case trimmedMean
}

/// Type of the Rosner test for outliers (ESD test)
public enum SSRosnerTestType {
    case lowerTail, upperTail, bothTails, none
}

/// Defines the cutting point used by the Runs test
public enum SSRunsTestCuttingPoint {
    case median, mean, mode, userDefined
}

/// Defines the sort order of the Contingency Table
public enum SSContingencyTableSortOrder {
    case ascending, descending, none
}

/// The 1D Chisquare-Hypothesis type
public enum SS1DChiSquareHypothesisType {
    case uniform, irregular
}


/// Quartile struct
public struct SSQuartile {
    /// 25% Quartile
    var q25: Double
    /// 50% Quartile
    var q50: Double
    /// 75% Quartile
    var q75: Double
    
    init(Q25: Double, Q50: Double, Q75: Double) {
        q25 = Q25
        q50 = Q50
        q75 = Q75
    }
    init() {
        q25 = 0
        q50 = 0
        q75 = 0
    }
}

/// Struct containing descriptive stats
public struct SSDescriptiveStats {
    /// arithmetic mean
    var mean: Double
    /// Variance
    var variance: Double
    /// Sample size
    var sampleSize: Double
    /// Standard deviation
    var standardDeviation: Double

    init(mean: Double, variance: Double, sampleSize: Double, standardDev: Double) {
        self.mean = mean
        self.variance = variance
        standardDeviation = standardDev
        self.sampleSize = sampleSize
    }
    init() {
        self.mean = 0
        self.variance = 0
        standardDeviation = 0
        self.sampleSize = 0
    }
}

/// Parameters of a continuous probability distribution
public struct SSContProbDistParams {
    /// Kurtosis
    var kurtosis: Double
    /// Mean
    var mean: Double
    /// Skewness
    var skewness: Double
    /// Variance
    var variance: Double
    
    init(mean: Double, variance: Double, kurtosis: Double, skewness: Double) {
        self.mean = mean
        self.variance = variance
        self.skewness = skewness
        self.kurtosis = kurtosis
    }
    init() {
        self.mean = 0
        self.variance = 0
        self.skewness = 0
        self.kurtosis = 0
    }
}

/// Defines the type of the moment to compute
public enum SSMomentType {
    /// Central moment
    case central
    /// Moment about the origin
    case origin
    /// Standardized moment
    case standardized
}

/// Defines the type of variance to compute
public enum SSVarianceType: Int {
    case biased = 0
    case unbiased = 1
}

/// Defines the type of sd to compute
public enum SSStandardDeviationType: Int {
    case biased = 0
    case unbiased = 1
}

/// Defines type of kurtosis
public enum SSKurtosisType {
    case platykurtic // kurtosisExecs < 0
    case mesokurtic  // kurtosisExces == 0
    case leptokurtic  // kurtosisExcess > 0
}

/// Skewness type
public enum SSSkewness {
    /// skewness < 0
    case leftSkewed
    /// skewness > 0
    case rightSkewed
    /// skewness == 0
    case symmetric
}

/// Type of semi variance
public enum SSSemiVariance {
    /// lower semi-variance
    case lower
    /// upper semi-variance
    case upper
}

