//
//  SSDataFrame.swift
//  SwiftyStats
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

// Defines a structure holding multiple SSExamine objects:
// Each column contains an SSExamine object. That way we can assign different samples to one column.
public class SSDataFrame<SSElement> where SSElement: Comparable, SSElement: Hashable{
    
    private var data:Array<SSExamine<SSElement>>
    private var tags: Array<Any>
    private var cNames: Array<String>
    private var rows: Int
    private var cols: Int
    
    /// Number of rwos per column (= sample size)
    public var sampleSize: Int {
        get {
            return rows
        }
    }
    
    /// Number of samples
    public var columns: Int {
        get {
            return cols
        }
    }
    
    
    init(examineArray: Array<SSExamine<SSElement>>!) throws {
        let tempSampleSize = examineArray.first!.sampleSize
        data = Array<SSExamine<SSElement>>.init()
        tags = Array<Any>()
        cNames = Array<String>()
        var i: Int = 0
        for a in examineArray {
            if a.sampleSize != tempSampleSize {
                os_log("Sample sizes are expected to be equal", log: log_stat, type: .error)
                data.removeAll()
                tags.removeAll()
                cNames.removeAll()
                rows = 0
                cols = 0
                throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
            }
            i += 1
            data.append(a)
            if let t = a.tag {
                tags.append(t)
            }
            else {
                tags.append("NA" as Any)
            }
            if let n = a.name {
                if let _ = cNames.index(of: n) {
                    var k: Int = 1
                    var tempSampleString = n + "_" + String(format: "%02d", arguments: [k as CVarArg])
                    while (cNames.index(of: tempSampleString) != nil) {
                        k += 1
                        tempSampleString = n + "_" + String(format: "%02d", arguments: [k as CVarArg])
                    }
                    cNames.append(tempSampleString)
                }
                else {
                    cNames.append(n)
                }
            }
            else {
                cNames.append(String(format: "%03d", arguments: [i as CVarArg]))
            }
        }
        rows = tempSampleSize
        cols = i
    }
    
    /// Appends a column
    /// - Parameter examine: The SSExamine object
    /// - Parameter name: Name of column
    /// - Throws: SSSwiftyStatsError examine.sampleSize != self.rows
    public func append(examine: SSExamine<SSElement>, name: String?) throws {
        if examine.sampleSize != self.rows {
            os_log("Sample sizes are expected to be equal", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
    }
    
    /// Removes all columns
    public func removeAll() {
        data.removeAll()
        cNames.removeAll()
        tags.removeAll()
        cols = 0
        rows = 0
    }
    /// Removes a column
    /// - Parameter name: Name of column
    /// - Returns: the removed column oe nil
    public func remove(name: String!) -> SSExamine<SSElement>? {
        if cols > 0 {
            if let i = cNames.index(of: name) {
                cNames.remove(at: i)
                tags.remove(at: i)
                cols -= 1
                rows -= 1
                return data.remove(at: i)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    private func isValidIndex(_ index: Int) -> Bool {
        return (index >= 0 && index < self.columns) ? true : false
    }
    
    private func indexOf(columnName: String!) -> Int? {
        if let i = cNames.index(of: columnName) {
            return i
        }
        else {
            return nil
        }
    }
    
    subscript(column: Int) -> SSExamine<SSElement> {
        assert(isValidIndex(column), "Index out of range")
        return data[column]
    }
    
    subscript(name: String!) -> SSExamine<SSElement> {
        guard let i = cNames.index(of: name) else {
            assert(false, "Index out of range")
        }
        return data[i]
    }
    
    
    
}
