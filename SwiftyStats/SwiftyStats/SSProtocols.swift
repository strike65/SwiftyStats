//
//  SSProtocols.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 09.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
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
