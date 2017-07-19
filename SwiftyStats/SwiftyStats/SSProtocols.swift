//
//  SSProtocols.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 09.07.17.
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
/// Defines a protocol to conform by SSExamine subclasses.
public protocol SSExamineContainer {
    associatedtype Item
    /// The sample size
    var sampleSize: Int { get }
    /// The "length" of the container. I.e. the number of unique items
    var length: Int { get }
    /// Contains the container any items
    var isEmpty: Bool { get }
    /// Contains the container the item?
    func contains(item: Item) -> Bool
    /// Frequency of item
    func frequency(item: Item) -> Int
    /// Relative frequency of item
    func relativeFrequency(item: Item) -> Double
    /// Appends an item
    mutating func append(_ item: Item!)
    /// Appends an item <count> times
    mutating func append(repeating count: Int!, item: Item!)
    /// Appends items from an array
    mutating func append(fromArray: Array<Item>!)
    /// Appends characters from a string. Throws, if Item is not of type string
    mutating func append(text: String!, characterSet: CharacterSet?) throws
    /// Removes the item
    mutating func remove(_ item: Item!, allOccurences: Bool!)
    /// Remove all items
    mutating func removeAll()
}
