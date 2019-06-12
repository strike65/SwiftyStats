//
//  SSProtocols.swift
//  SwiftyStats
//
//  Created by strike65 on 09.07.17.
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
/// Defines a protocol to conform by SSExamine subclasses.
internal protocol SSExamineContainer {
    associatedtype ExamineElement
    associatedtype Frequency: SSFloatingPoint
    /// The sample size
    var sampleSize: Int { get }
    /// The "length" of the container. I.e. the number of unique items
    var length: Int { get }
    /// Contains the container any elements
    var isEmpty: Bool { get }
    /// Contains the container the element?
    mutating func contains(_ element: ExamineElement) -> Bool
    /// Frequency of element
    mutating func frequency(_ element: ExamineElement) -> Int
    /// Relative frequency of element
    mutating func rFrequency(_ element: ExamineElement) -> Frequency
    /// Appends an element
    mutating func append(_ element: ExamineElement)
    /// Appends an element <count> times
    mutating func append(repeating count: Int, element: ExamineElement)
    /// Appends items from an array
    mutating func append(contentOf array: Array<ExamineElement>)
    /// Appends characters from a string. Throws, if Item is not of type string
    mutating func append(text: String, characterSet: CharacterSet?) throws
    /// Removes the element
    mutating func remove(_ element: ExamineElement, allOccurences: Bool)
    /// Remove all items
    mutating func removeAll()
}

internal protocol SSDataFrameContainer {
    associatedtype Examine
    var columns: Int { get }
    var sampleSize: Int { get  }
    var isEmpty: Bool { get }
    mutating func append(_ examine: Examine, name: String?) throws
    mutating func remove(name: String!) -> Examine?
    mutating func removeAll()
}
