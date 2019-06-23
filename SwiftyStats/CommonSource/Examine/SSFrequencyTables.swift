//
//  SSFrequencyTableEntry.swift
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

/// One "row" of the frequency table
/// Containe: absolute Freq, relative Freq, Percent
public struct SSFrequencyTableItem<SSElement, FPT> where SSElement: Hashable, SSElement: Comparable, FPT: SSFloatingPoint {
    private var privateItem: SSElement!
    
    /// The item
    public var item: SSElement {
        get {
            return self.privateItem
        }
    }
    /// Relative frequency
    public var relativeFrequency: FPT = 0
    
    /// Frequency
    public var frequency: Int = 0
    
    /// Initializes a new row
    /// - Parameter item: An item of type SSElement
    /// - Parameter rf: Relative frequency of item
    /// - Parameter af: Frequency of item
    init(withItem item: SSElement!, relativeFrequency rf: FPT, frequency af: Int) {
        self.privateItem = item
        self.relativeFrequency = rf
        self.frequency = af
    }
    
    /// Description
    public var description: String {
        get {
            return String(format:"Value %@", self.privateItem as! CVarArg)
        }
    }
}

/// One "row" of the cumulative frequency table
/// Containe: cumulative Freq, cumulative relative Freq
public struct SSCumulativeFrequencyTableItem<SSElement, FPT> where SSElement: Hashable, SSElement: Comparable, FPT: SSFloatingPoint {
    private var privateItem: SSElement!
    private var privateCumRel: FPT!
    private var privateCumAbs: Int!
    
    /// Item
    public var item: SSElement {
        get {
            return privateItem
        }
        set {
            privateItem = newValue
        }
    }
    /// Cumulative frequency
    public var cumulativefrequency: Int {
        get {
            return privateCumAbs
        }
        set {
            privateCumAbs = newValue
        }
    }
    
    /// Cumulative relative frequency
    public var cumulativeRelativeFrequency: FPT {
        get {
            return privateCumRel
        }
        set {
            privateCumRel = newValue
        }
    }
    
    /// Initializes a new row
    /// - Parameter item: An item of type SSElement
    /// - Parameter cumRel: Relative frequency of item
    /// - Parameter cumFreq: Frequency of item
    init(withItem item: SSElement!, cumulativeRelativeFrequency cumRel: FPT, cumulativefrequency cumFreq: Int) {
        self.privateItem = item
        self.privateCumAbs = cumFreq
        self.privateCumRel = cumRel
    }
}
