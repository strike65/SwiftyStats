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
    /// Number of rows
    public var rows: Int {
        get {
            return rr
        }
    }
    
    /// Number of columns
    public var columns: Int {
        get {
            return cc
        }
    }
    
    /// Returns the first row
    public var firstRow: Array<T> {
        get {
            return self.grid[0]
        }
    }
    
    /// Returns the last row
    public var lastRow: Array<T> {
        get {
            return self.grid[self.rr - 1]
        }
    }
    
    /// Returns the first column
    public var firstColumn: Array<T> {
        get {
            var temp: Array<T> = Array<T>()
            for i in 0..<self.rr {
                temp.append(grid[i][0])
            }
            return temp
        }
    }
    
    /// Returns the last column
    public var lastColumn: Array<T> {
        get {
            var temp: Array<T> = Array<T>()
            for i in 0..<self.rr {
                temp.append(grid[i][self.cc - 1])
            }
            return temp
        }
    }
    
    /// returns the row names or nil
    public var rowNames: Array<String>? {
        get {
            return rnames
        }
    }
    
    /// returns the column names or nil
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
    
    /// Initializes a new crosstab
    /// - Parameter rows: number of rows
    /// - Parameter columns: number of columns
    /// - Parameter initialValue: Initial value
    init(rows: Int, columns: Int, initialValue: T) {
        self.rr = rows
        self.cc = columns
        self.grid = Array<Array<T>>()
        for _ in 1...rows {
            self.grid.append(Array<T>.init(repeating: initialValue, count: columns))
        }
        self.isNumber = isNumeric(initialValue)
    }
    
    
    private func isValidIndex(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rr && column >= 0 && column < self.cc
    }
    
    /// Returns the row at rowIndex
    public func row(rowIndex at: Int) -> Array<T> {
        assert(at >= 0 && at < self.rr, "Index out of range")
        return self.grid[at]
    }
    
    /// Returns the column at columnIndex
    public func column(columnIndex at: Int) -> Array<T> {
        assert(at >= 0 && at < self.cc, "Index out of range")
        var temp = Array<T>()
        for r in 0..<self.rr {
            temp.append(self.grid[r][at])
        }
        return temp
    }
    
    /// Returns the row with name rowName or nil
    public func rowNamed(rowName: String) -> Array<T>? {
        if self.rnames != nil {
            if let i = self.rnames!.index(of: rowName) {
                return self.grid[i]
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the column with name columnName or nil
    public func columnNamed(columnName: String) -> Array<T>? {
        if self.cnames != nil {
            if let i = self.cnames!.index(of: columnName) {
                return self.column(columnIndex: i)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    subscript(rowName: String!, columnName: String!) -> T {
        get {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidIndex(row: r, column: c), "Index out of range")
            return self.grid[r][c]
        }
        set {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidIndex(row: r, column: c), "Index out of range")
            grid[r][c] = newValue
        }
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            assert(isValidIndex(row: row, column: column), "Index out of range")
            return grid[row][column]
        }
        set {
            assert(isValidIndex(row: row, column: column), "Index out of range")
            grid[row][column] = newValue
        }
    }
    
    /// Appends a row
    public func appendRow(_ row: Array<T>) {
        assert(row.count == self.cc, "Rows to append must have \(self.cc) columns")
        grid.append(row)
        self.rr += 1
    }

    /// Appends a column
    public func appendColumn(_ column: Array<T>) {
        assert(column.count == self.rr, "Columns to append must have \(self.rr) rows")
        var i = 0
        for c in column {
            self.grid[i].append(c)
            i += 1
        }
        self.cc += 1
    }
    
    /// Remove row at index at
    public func removeRow(at: Int) {
        assert(at >= 0 && at < self.rr, "Index out of range")
        self.grid.remove(at: at)
        self.rr -= 1
    }
    
    /// Remove column at index at
    public func removeColumn(at: Int) {
        assert(at >= 0 && at < self.cc, "Index out of range")
        for i in 0..<self.grid.count {
            self.grid[i].remove(at: at)
        }
        self.cc -= 1
    }
    
    /// Inserts a row at index at
    public func insertRow(newRow: Array<T>, at: Int) {
        assert(at >= 0 && at < self.rr, "Index out of range")
        assert(newRow.count == self.cc, "Rows to append must have \(self.cc) columns")
        self.grid.insert(newRow, at: at)
        self.rr += 1
    }
    
    /// Inserts a column at index at
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
    
    /// Sets the rows names. Length of rowNames must be equal to self.rows
    public func setRowNames(rowNames: Array<String>) {
        assert(rowNames.count == self.rr, "Array of row names must be of length \(self.rr)")
        self.rnames = rowNames
    }
    
    /// Sets the column names. Length of columnNames must be equal to self.columns
   public func setColumnNames(columnNames: Array<String>) {
        assert(columnNames.count == self.cc, "Array of column names must be of length \(self.cc)")
        self.cnames = columnNames
    }
    
    /// Description string
    override public var description: String {
        var string = ""
        if let cn = self.columnNames {
            for s in cn {
                string.append(s + " | ")
            }
            string.append("\n")
        }
        for r in 0..<rows {
            if let rn = self.rowNames {
                string.append(rn[r] + " | ")
            }
            for c in 0..<columns {
                string.append("\(grid[r][c]) ")
            }
            string.append("\n")
        }
        return string
    }
}

extension SSCrosstab {
    
    /// Returns the row sums as an array with self.rows values
    public func rowSums() -> Array<Double>? {
        if self.isNumber {
            var sum: Double = 0.0
            var temp = Array<Double>()
            var temp1: Double
            for r in 0..<self.rows {
                sum = 0.0
                for c in 0..<self.columns {
                    if T.self is Int.Type {
                        temp1 = Double(self[r, c] as! Int)
                    }
                    else {
                        temp1 = self[r, c] as! Double
                    }
                    sum += temp1
                }
                temp.append(sum)
            }
            return temp
        }
        else {
            return nil
        }
    }

    /// Returns the column sums as an array with self.columns values
    public func columnSums() -> Array<Double>? {
        if self.isNumber {
            var sum: Double = 0.0
            var temp = Array<Double>()
            var temp1: Double
            for c in 0..<self.columns {
                sum = 0.0
                for r in 0..<self.rows {
                    if T.self is Int.Type {
                        temp1 = Double(self[r, c] as! Int)
                    }
                    else {
                        temp1 = self[r, c] as! Double
                    }
                    sum += temp1
                }
                temp.append(sum)
            }
            return temp
        }
        else {
            return nil
        }
    }
    
    /// Returns the sum of all rows
    public func rowTotal() -> Double {
        if let rs = self.rowSums() {
            var t: Double = 0.0
            for s in rs {
                t += s
            }
            return t
        }
        else {
            return Double.nan
        }
    }

    /// Returns the sum of all columns
    public func colummTotal() -> Double {
        if let cs = self.columnSums() {
            var t: Double = 0.0
            for s in cs {
                t += s
            }
            return t
        }
        else {
            return Double.nan
        }
    }

}

