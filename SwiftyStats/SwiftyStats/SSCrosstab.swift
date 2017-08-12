//
//  SSCrosstab.swift
//  SwiftyStats
//
//  Created by volker on 12.08.17.
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

public class SSCrosstab<T>: NSObject where T: Comparable, T: Hashable {
    
    public var rows: Int {
        get {
            return rr
        }
    }
    
    public var firstRow: Array<T> {
        get {
            return self.grid[0]
        }
    }
    
    public var lastRow: Array<T> {
        get {
            return self.grid[self.rr - 1]
        }
    }
    
    public var firstColumn: Array<T> {
        get {
            var temp: Array<T> = Array<T>()
            for i in 0..<self.rr {
                temp.append(grid[i][0])
            }
            return temp
        }
    }
    
    public var lastColumn: Array<T> {
        get {
            var temp: Array<T> = Array<T>()
            for i in 0..<self.rr {
                temp.append(grid[i][self.cc - 1])
            }
            return temp
        }
    }
    
    
    public var columns: Int {
        get {
            return cc
        }
    }
    
    public var rowNames: Array<String>? {
        get {
            return rnames
        }
    }
    
    public var columnNames: Array<String>? {
        get {
            return cnames
        }
    }
    
    private var rnames: Array<String>?
    private var cnames: Array<String>?
    
    private var rr: Int, cc: Int
    private var grid: Array<Array<T>>
    
    public var isNumber: Bool
    
    init(rows: Int, columns: Int, initialValue: T) {
        self.rr = rows
        self.cc = columns
        self.grid = Array<Array<T>>()
        for _ in 1...rows {
            self.grid.append(Array<T>.init(repeating: initialValue, count: columns))
        }
        self.isNumber = isNumeric(initialValue)
        self.rnames = nil
        self.cnames = nil
    }
    
    public func isValidIndex(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rr && column >= 0 && column < self.cc
    }
    
    
    
    public subscript(row: Int, column: Int) -> T {
        get {
            assert(isValidIndex(row: row, column: column), "Index out of range")
            return grid[row][column]
        }
        set {
            assert(isValidIndex(row: row, column: column), "Index out of range")
            grid[row][column] = newValue
        }
    }
    
    public func appendRow(_ row: Array<T>) {
        assert(row.count == self.cc, "Rows to append must have \(self.cc) columns")
        grid.append(row)
        self.rr += 1
    }
    
    public func appendColumn(_ column: Array<T>) {
        assert(column.count == self.rr, "Columns to append must have \(self.rr) rows")
        var i = 0
        for c in column {
            self.grid[i].append(c)
            i += 1
        }
        self.cc += 1
    }
    
    public func removeRow(at: Int) {
        assert(at >= 0 && at < self.rr, "Index out of range")
        self.grid.remove(at: at)
        self.rr -= 1
    }
    
    public func removeColumn(at: Int) {
        assert(at >= 0 && at < self.cc, "Index out of range")
        for i in 0..<self.grid.count {
            self.grid[i].remove(at: at)
        }
        self.cc -= 1
    }
    
    public func insertRow(newRow: Array<T>, at: Int) {
        assert(at >= 0 && at < self.rr, "Index out of range")
        assert(newRow.count == self.cc, "Rows to append must have \(self.cc) columns")
        self.grid.insert(newRow, at: at)
        self.rr += 1
    }
    
    public func insertColumn(newColumn: Array<T>, at: Int) {
        assert(at >= 0 && at < self.cc, "Index out of range")
        assert(newColumn.count == self.rr, "Rows to append must have \(self.rr) rows")
        var i = 0
        for v in newColumn {
            self.grid[i].insert(v, at: at)
            i += 1
        }
        self.cc += 1
    }
    
    public func setRowNames(rowNames: Array<String>) {
        assert(rowNames.count == self.rr, "Array of row names must be of length \(self.rr)")
        self.rnames = rowNames
    }
    
    public func setColumnNames(columnNames: Array<String>) {
        assert(columnNames.count == self.cc, "Array of column names must be of length \(self.cc)")
        self.cnames = columnNames
    }
    
    override public var description: String {
        var string = ""
        for r in 0..<rows {
            for c in 0..<columns {
                string.append("\(grid[r][c]) ")
            }
            string.append("\n")
        }
        return string
    }
}
