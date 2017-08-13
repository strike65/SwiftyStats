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
import os.log

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
    
    public var isNumeric: Bool
    
    /// Initializes a new crosstab
    /// - Parameter rows: number of rows
    /// - Parameter columns: number of columns
    /// - Parameter initialValue: Initial value
    init(rows: Int, columns: Int, initialValue: T) {
        assert(rows > 0 && columns > 0, "Creating an empty crosstab is not possible, Use init() instead.")
        self.rr = rows
        self.cc = columns
        self.grid = Array<Array<T>>()
        self.rnames = nil
        self.cnames = nil
        for _ in 1...rows {
            self.grid.append(Array<T>.init(repeating: initialValue, count: columns))
        }
        self.isNumeric = isNumber(initialValue)
    }
    
    public var is2x2Table: Bool {
        get {
            return self.rows == 2 && self.columns == 2
        }
    }
    
    func isValidRowName(name: String) -> Bool {
        if let _ = indexOfRow(rowName: name) {
            return true
        }
        else {
            return false
        }
    }

    func isValidColumnName(name: String) -> Bool {
        if let _ = indexOfColumn(columnName: name) {
            return true
        }
        else {
            return false
        }
    }

    func isValidRowIndex(row: Int) -> Bool {
        return row >= 0 && row < self.rows
    }

    func isValidColumnIndex(column: Int) -> Bool {
        return column >= 0 && column < self.columns
    }

    func isValidIndex(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rr && column >= 0 && column < self.cc
    }
    
    /// Returns the row at rowIndex
    public func row(rowIndex at: Int) throws -> Array<T> {
        if !(at >= 0 && at < self.rr) {
            throw SSSwiftyStatsError.init(type: .rowIndexOutOfRange, file: #file, line: #line, function: #function)
        }
        return self.grid[at]
    }
    
    /// Returns the column at columnIndex
    public func column(columnIndex at: Int) throws -> Array<T> {
        if !(at >= 0 && at < self.cc) {
            throw SSSwiftyStatsError.init(type: .columnIndexOutOfRange, file: #file, line: #line, function: #function)
        }
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
    public func columnNamed(columnName: String) throws -> Array<T>? {
        if self.cnames != nil {
            if let i = self.cnames!.index(of: columnName) {
                do {
                    return try self.column(columnIndex: i)
                }
                catch{
                    throw error
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
    
    subscript(rowName: String!, columnName: String!) -> T {
        get {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidRowIndex(row: r), "Row-Index out of range")
            assert(isValidColumnIndex(column: c), "Column-Index out of range")
            return self.grid[r][c]
        }
        set {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidRowIndex(row: r), "Row-Index out of range")
            assert(isValidColumnIndex(column: c), "Column-Index out of range")
            grid[r][c] = newValue
        }
    }
    
    subscript(row: Int, column: Int) -> T {
        get {
            assert(isValidRowIndex(row: row), "Row-Index out of range")
            assert(isValidColumnIndex(column: column), "Column-Index out of range")
            return grid[row][column]
        }
        set {
            assert(isValidRowIndex(row: row), "Row-Index out of range")
            assert(isValidColumnIndex(column: column), "Column-Index out of range")
            grid[row][column] = newValue
        }
    }
    
    /// Appends a row
    public func appendRow(_ row: Array<T>, name: String?) throws {
        if !(row.count == self.cc) {
            os_log("Rows to append must have self.columns columns", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        grid.append(row)
        self.rr += 1
        if name != nil {
            if self.rnames != nil {
                self.rnames!.append(name!)
            }
            else {
                self.rnames = Array<String>.init(repeating: "(NA)", count: self.rows)
                self.rnames!.remove(at: self.rows - 1)
                self.rnames!.append(name!)
            }
        }
    }
    
    /// Appends a column
    public func appendColumn(_ column: Array<T>, name: String?) throws {
        if !(column.count == self.rr) {
            os_log("Columns to append must have self.rows rows", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        var i = 0
        for c in column {
            self.grid[i].append(c)
            i += 1
        }
        self.cc += 1
        if name != nil {
            if self.cnames != nil {
                self.cnames!.append(name!)
            }
            else {
                self.cnames = Array<String>.init(repeating: "(NA)", count: self.columns)
                self.cnames!.remove(at: self.columns - 1)
                self.cnames!.append(name!)
            }
        }
    }
    
    /// Removes the row with name
    public func removeRow(rowName name: String) throws -> Array<T> {
        guard let i = self.indexOfRow(rowName: name) else {
            throw SSSwiftyStatsError.init(type: .rowNameUnknown, file: #file, line: #line, function: #function)
        }
        return self.removeRow(at: i)
    }
    
    /// Removes the column with name
    public func removeColumn(columnName name: String) throws -> Array<T> {
        guard let i = self.indexOfColumn(columnName: name) else {
            throw SSSwiftyStatsError.init(type: .columnNameUnknown, file: #file, line: #line, function: #function)
        }
        return self.removeColumn(at: i)
    }
    
    /// Remove row at index at
    public func removeRow(at: Int) -> Array<T> {
        assert(at >= 0 && at < self.rr, "Row-Index out of range")
        let removed = self.grid.remove(at: at)
        self.rr -= 1
        if self.rnames != nil {
            self.rnames!.remove(at: at)
        }
        return removed
    }
    
    /// Remove column at index at
    public func removeColumn(at: Int) -> Array<T> {
        assert(at >= 0 && at < self.cc, "Column-Index out of range")
        var temp: Array<T> = Array<T>()
        for i in 0..<self.grid.count {
            temp.append(self.grid[i].remove(at: at))
        }
        if self.cnames != nil {
            self.cnames!.remove(at: at)
        }
        self.cc -= 1
        return temp
    }
    
    /// Inserts a row at index at
    public func insertRow(newRow: Array<T>, at: Int, name: String?) throws {
        assert(at >= 0 && at < self.rr, "Row-Index out of range")
        if !(newRow.count == self.cc) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.grid.insert(newRow, at: at)
        self.rr += 1
        if name != nil {
            if self.rnames != nil {
                self.rnames!.insert(name!, at: at)
            }
            else {
                self.rnames = Array<String>.init(repeating: "(NA)", count: self.rows - 1)
                self.rnames!.insert(name!, at: at)
            }
        }
    }
    
    /// Inserts a column at index at
    public func insertColumn(newColumn: Array<T>, at: Int, name: String?) throws {
        assert(at >= 0 && at < self.cc, "Column-Index out of range")
        if !(newColumn.count == self.rr) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        var i = 0
        for v in newColumn {
            self.grid[i].insert(v, at: at)
            i += 1
        }
        self.cc += 1
        if name != nil {
            if self.cnames != nil {
                self.cnames!.insert(name!, at: at)
            }
            else {
                self.cnames = Array<String>.init(repeating: "(NA)", count: self.columns - 1)
                self.cnames!.insert(name!, at: at)
            }
        }
    }
    
    public func replaceRow(newRow: Array<T>, at: Int, name: String?) throws {
        assert(self.isValidRowIndex(row: at), "Row-Index out of range")
        do {
            try self.insertRow(newRow: newRow, at: at, name: name)
        }
        catch {
            throw error
        }
        let _ = self.removeRow(at: at + 1)
    }

    
    public func replaceColumn(newColumn: Array<T>, at: Int, name: String?) throws {
        assert(self.isValidColumnIndex(column: at), "Column-Index out of range")
        do {
            try self.insertColumn(newColumn: newColumn, at: at, name: name)
        }
        catch {
            throw error
        }
        let _ = self.removeColumn(at: at + 1)
    }

    
    
    /// Sets the rows names. Length of rowNames must be equal to self.rows
    public func setRowNames(rowNames: Array<String>) throws {
        if !(rowNames.count == self.rr) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.rnames = rowNames
    }
    
    /// Sets the column names. Length of columnNames must be equal to self.columns
    public func setColumnNames(columnNames: Array<String>) throws {
        if !(columnNames.count == self.cc) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
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
    public var rowSums: Array<Double>? {
        get {
                if self.isNumeric {
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
    }
    
    /// Returns the column sums as an array with self.columns values
    public var columnSums: Array<Double>? {
        get {
            if self.isNumeric {
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
    }
    
    /// The sum of a row
    public func rowSum(row: Int) -> Double {
        assert(row < self.rows && row >= 0, "Row-Index out of range")
        if let rs = self.rowSums {
            return rs[row]
        }
        else {
            return Double.nan
        }
    }

    /// Sum of row named rowName
    public func rowSum(rowName: String) -> Double {
        if let rn = self.rowNames {
            let i = rn.index(of: rowName)
            guard i != nil else {
                return Double.nan
            }
            return self.rowSum(row: i!)
        }
        else {
            return Double.nan
        }
    }

    /// The sum of a column
    public func columnSum(column: Int) -> Double {
        assert(isValidColumnIndex(column: column), "Column-Index out of range")
        if let cs = self.columnSums {
            return cs[column]
        }
        else {
            return Double.nan
        }
    }
    
    /// Sum of column named columnName
    public func columnSum(columnName: String) -> Double {
        if let rn = self.columnNames {
            let i = rn.index(of: columnName)
            guard i != nil else {
                return Double.nan
            }
            return self.columnSum(column: i!)
        }
        else {
            return Double.nan
        }
    }

    /// Returns the name of the column or nil if there is no name
    public func nameOfColumn(column: Int) -> String? {
        assert(column < self.columns && column >= 0, "Column-Index out of range")
        if let cn = self.columnNames {
            return cn[column]
        }
        else {
            return nil
        }
    }
    
    /// Returns the name of the row or nil if there is no name
    public func nameOfRow(row: Int) -> String? {
        assert(row < self.rows && row >= 0, "Row-Index out of range")
        if let rn = self.rowNames {
            return rn[row]
        }
        else {
            return nil
        }
    }
    
    /// Returns the index of the column with name columnName or nil if there is no column with that name.
    public func indexOfColumn(columnName: String) -> Int? {
        if let cn = self.columnNames {
            return cn.index(of: columnName)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the index of the row with name rowName or nil if there is no row with that name.
    public func indexOfRow(rowName: String) -> Int? {
        if let rn = self.rowNames {
            return rn.index(of: rowName)
        }
        else {
            return nil
        }
    }
    
    
    /// the total
    public var total: Double {
        get {
            return self.rowTotal()
        }
    }
    
    /// Returns the sum of all rows
    public func rowTotal() -> Double {
        if let rs = self.rowSums {
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
        if let cs = self.columnSums {
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
    
    /// Returns the relative frequency of cell[row, column]
    public func relativeFrequencyCell(row: Int, column: Int) throws -> Double {
        assert(isValidRowIndex(row: row), "Row-Index out of range")
        assert(isValidColumnIndex(column: column), "Column-Index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[row, column] as! Int)
            }
            else {
                temp = self[row, column] as! Double
            }
            return temp / self.total
        }
        else {
            return Double.nan
        }
    }

    
    /// Returns the relative frequency of [rowName, columnName]
    public func relativeFrequencyCell(rowName: String, columnName: String) throws -> Double {
        assert(isValidRowName(name: rowName), "Row-Name unknown")
        assert(isValidColumnName(name: columnName), "Column-Name unknown")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[rowName, columnName] as! Int)
            }
            else {
                temp = self[rowName, columnName] as! Double
            }
            return temp / self.total
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative row frequency of cell[row, column]
    public func relativeRowFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[row, column] as! Int)
            }
            else {
                temp = self[row, column] as! Double
            }
            return temp / self.rowSums![row]
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative column frequency of cell[row, column]
    public func relativeColumnFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[row, column] as! Int)
            }
            else {
                temp = self[row, column] as! Double
            }
            return temp / self.columnSums![column]
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative margin row frequency of [row]
    public func relativeRowMarginFrequency(row: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            temp = self.rowSums![row]
            return temp / self.total
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative margin row frequency of [row]
    public func relativeColumnMarginFrequency(column: Int) -> Double {
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            temp = self.columnSums![column]
            return temp / self.total
        }
        else {
            return Double.nan
        }
    }
    
    /// Returns the relative total frequency
    public func relativeTotalFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[row, column] as! Int)
            }
            else {
                temp = self[row, column] as! Double
            }
            return temp / self.total
        }
        else {
            return Double.nan
        }
    }

    /// Returns the expected frequency for cell[row, column]
    public func expectedFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        if self.isNumeric {
            return (self.rowSum(row: row) * self.columnSum(column: column)) / self.total
        }
        else {
            return Double.nan
        }
    }

    /// Returns the residual for cell[row, column]
    public func residual(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        var temp: Double = 0.0
        if self.isNumeric {
            if T.self is Int.Type {
                temp = Double(self[row, column] as! Int)
            }
            else {
                temp = self[row, column] as! Double
            }
            return temp - self.expectedFrequency(row: row, column: column)
        }
        else {
            return Double.nan
        }
    }
    
    /// Returns the standardized residual for cell[row, column]
    public func standardizedResidual(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        return self.residual(row: row, column: column) / sqrt(expectedFrequency(row: row, column: column))
    }

    /// Returns the adjusted residual for cell[row, column]
    public func adjustedResidual(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        let rowSum = self.rowSum(row: row)
        let columnSum = self.columnSum(column: column)
        return self.residual(row: row, column: column) / sqrt((expectedFrequency(row: row, column: column)) * (1.0 - rowSum / self.total) * (1.0 - columnSum / self.total))
    }

    /// Degrees of freedom
    public var degreesOfFreedom: Double {
        get {
            let df = Double(self.rows - 1) * Double(self.columns - 1)
            if df >= 0.0 {
                return df
            }
            else {
                return Double.nan
            }
        }
    }

    /// Returns Pearson's Chi-Square
    public var chiSquare: Double {
        get {
            if self.isNumeric {
                var sum: Double = 0.0
                for r in 0..<self.rows {
                    for c in 0..<self.columns {
                        sum += pow(self.residual(row: r, column: c), 2.0) / self.expectedFrequency(row: r, column: c)
                    }
                }
                return sum
            }
            else {
                return Double.nan
            }
        }
    }

    /// Returns Chi-Square Likelihood Ratio
    public var likelihoodRatio: Double {
        get {
            var temp: Double = 0.0
            var sum: Double = 0.0
            if self.isNumeric {
                for r in 0..<self.rows {
                    for c in 0..<self.columns {
                        if T.self is Int.Type {
                            temp = Double(self[r, c] as! Int)
                        }
                        else {
                            temp = self[r, c] as! Double
                        }
                        if temp != 0 {
                            sum += temp * log(temp / self.expectedFrequency(row: r, column: c))
                        }
                    }
                }
                return 2.0 * sum
            }
            else {
                return Double.nan
            }
        }
    }
    
    /// Returns the Yates continuity corrected Chi-Square for a 2 x 2 table
    public var chiSquareYates: Double {
        get {
            if self.is2x2Table {
                var n11: Double
                var n12: Double
                var n21: Double
                var n22: Double
                if T.self is Int.Type {
                    n11 = Double(self[0,0] as! Int)
                    n12 = Double(self[0,1] as! Int)
                    n21 = Double(self[1,0] as! Int)
                    n22 = Double(self[1,1] as! Int)
                }
                else {
                    n11 = self[0,0] as! Double
                    n12 = self[0,1] as! Double
                    n21 = self[1,0] as! Double
                    n22 = self[1,1] as! Double
                }
                let temp = fabs(n11 * n22 - n12 * n21)
                let t = self.total
                if temp <= (0.5 * t) {
                    return 0.0
                }
                else {
                    let den = self.rowSum(row: 0) * self.rowSum(row: 1) * self.columnSum(column: 0) * self.columnSum(column: 1)
                    return t * pow(temp - 0.5 * t, 2.0) / den
                }
            }
            else {
                return Double.nan
            }
        }
    }

}

