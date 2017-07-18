//
//  SSFrequencyTableEntry.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 03.07.17.
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

/// One "row" of the frequency table
/// Containe: absolute Freq, relative Freq, Percent
public struct SSFrequencyTableItem<SSElement> where SSElement: Hashable, SSElement: Comparable {
    private var privateItem: SSElement!

    /// The item
    public var item: SSElement {
        get {
            return self.privateItem
        }
    }
    /// Relative frequency
    public var relativeFrequency: Double = 0.0
    
    /// Frequency
    public var frequency: Int = 0
    
    /// Initializes a new row
    /// - Parameter item: An item of type SSElement
    /// - Parameter rf: Relative frequency of item
    /// - Parameter af: Frequency of item
    init(withItem item: SSElement!, relativeFrequency rf: Double!, frequency af: Int!) {
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
public struct SSCumulativeFrequencyTableItem<SSElement> where SSElement: Hashable, SSElement: Comparable {
    private var privateItem: SSElement!
    private var privateCumRel: Double!
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
    public var cumulativeRelativeFrequency: Double {
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
    init(withItem item: SSElement!, cumulativeRelativeFrequency cumRel: Double!, cumulativefrequency cumFreq: Int!) {
        self.privateItem = item
        self.privateCumAbs = cumFreq
        self.privateCumRel = cumRel
    }





}
