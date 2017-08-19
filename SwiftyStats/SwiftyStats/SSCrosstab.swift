//
//  SSCrosstab.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 12.08.17.
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

/// Class provides a matrix-like crosstable. Elements are accessibla by c[row, column].
/// - Precondition: Rowa and columns must be named.
public class SSCrosstab<N,R,C>: NSObject where N: Comparable, N: Hashable, R: Comparable, R: Hashable, C: Comparable, C: Hashable {
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
    public var firstRow: Array<N> {
        get {
            return self.counts[0]
        }
    }
    
    /// Returns the last row
    public var lastRow: Array<N> {
        get {
            return self.counts[self.rr - 1]
        }
    }
    
    /// Returns the first column
    public var firstColumn: Array<N> {
        get {
            var temp: Array<N> = Array<N>()
            for i in 0..<self.rr {
                temp.append(counts[i][0])
            }
            return temp
        }
    }
    
    /// Returns the last column
    public var lastColumn: Array<N> {
        get {
            var temp: Array<N> = Array<N>()
            for i in 0..<self.rr {
                temp.append(counts[i][self.cc - 1])
            }
            return temp
        }
    }
    
    /// returns the row names or nil
    public var rowNames: Array<R>? {
        get {
            return rnames
        }
    }
    
    /// returns the column names or nil
    public var columnNames: Array<C>? {
        get {
            return cnames
        }
    }
    
    /// Defines the level od measurement of the column variable
    public var columnLevelOfMeasurement: SSLevelOfMeasurement {
        get {
            return self.levelRows
        }
        set {
            self.levelRows = newValue
        }
    }
    
    /// Defines the level od measurement of the row variable
    public var rowLevelOfMeasurement: SSLevelOfMeasurement {
        get {
            return self.levelRows
        }
        set {
            self.levelRows = newValue
        }
    }
    
    private var rnames: Array<R>?
    private var cnames: Array<C>?
    private var levelRows: SSLevelOfMeasurement
    private var levelColumns: SSLevelOfMeasurement
    
    private var rr: Int, cc: Int
    private var counts: Array<Array<N>>
    
    public var isNumeric: Bool
    
    /// Initializes a new crosstab
    /// - Parameter rows: number of rows
    /// - Parameter columns: number of columns
    /// - Parameter initialValue: Initial value
    init(rows: Int, columns: Int, initialValue: N, rowID: Array<R>, columnID: Array<C>) throws {
        assert(rows > 0 && columns > 0, "Creating an empty crosstab is not possible, Use init() instead.")
        if rowID.count != rows {
            os_log("You must provide as many row id's as rows", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if columnID.count != columns {
            os_log("You must provide as many row id's as rows", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isNumber(initialValue) {
            os_log("Cell counts must be numeric", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if R.self is Int.Type || R.self is Double.Type {
            self.levelRows = .interval
        }
        else {
            self.levelRows = .nominal
        }
        if C.self is Int.Type || C.self is Double.Type {
            self.levelColumns = .interval
        }
        else {
            self.levelColumns = .nominal
        }
        self.rr = rows
        self.cc = columns
        self.counts = Array<Array<N>>()
        self.rnames = rowID
        self.cnames = columnID
        for _ in 1...rows {
            self.counts.append(Array<N>.init(repeating: initialValue, count: columns))
        }
        
        self.isNumeric = isNumber(initialValue)
    }
    
    /// Returns true if rows = 2 and columns = 2
    public var is2x2Table: Bool {
        get {
            return self.rows == 2 && self.columns == 2
        }
    }
    /// Returns true if name is a valid row-name
    func isValidRowName(name: R) -> Bool {
        if let _ = indexOfRow(rowName: name) {
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if name is a valid column-name
    func isValidColumnName(name: C) -> Bool {
        if let _ = indexOfColumn(columnName: name) {
            return true
        }
        else {
            return false
        }
    }

    /// Returns true if row is a valid index
    func isValidRowIndex(row: Int) -> Bool {
        return row >= 0 && row < self.rows
    }

    /// Returns true if column is a valid column index
    func isValidColumnIndex(column: Int) -> Bool {
        return column >= 0 && column < self.columns
    }

    /// Returns true if row and column are valid indexes
    func isValidIndex(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rr && column >= 0 && column < self.cc
    }
    
    /// Returns the row at rowIndex
    public func row(rowIndex at: Int, sorted: Bool!) throws -> Array<N> {
        if !(at >= 0 && at < self.rr) {
            throw SSSwiftyStatsError.init(type: .rowIndexOutOfRange, file: #file, line: #line, function: #function)
        }
        if sorted {
            return self.counts[at].sorted(by: { $0 < $1 })
        }
        else {
            return self.counts[at]
        }
    }
    
    /// Returns the column at columnIndex
    public func column(columnIndex at: Int, sorted: Bool!) throws -> Array<N> {
        if !(at >= 0 && at < self.cc) {
            throw SSSwiftyStatsError.init(type: .columnIndexOutOfRange, file: #file, line: #line, function: #function)
        }
        var temp = Array<N>()
        for r in 0..<self.rr {
            temp.append(self.counts[r][at])
        }
        if sorted {
            return temp.sorted(by: {$0 < $1})
        }
        else {
            return temp
        }
    }
    
    /// Returns the row with name rowName or nil
    public func rowNamed(rowName: R, sorted: Bool!) throws -> Array<N>? {
        if self.rnames != nil {
            if let i = self.rnames!.index(of: rowName) {
                do {
                    return try self.row(rowIndex: i, sorted: sorted)
                }
                catch {
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
    
    /// Returns the column with name columnName or nil
    public func columnNamed(columnName: C, sorted: Bool) throws -> Array<N>? {
        if self.cnames != nil {
            if let i = self.cnames!.index(of: columnName) {
                do {
                    return try self.column(columnIndex: i, sorted: sorted)
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
    
    subscript(rowName: R!, columnName: C!) -> N {
        get {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidRowIndex(row: r), "Row-Index out of range")
            assert(isValidColumnIndex(column: c), "Column-Index out of range")
            return self.counts[r][c]
        }
        set {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            guard let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) else {
                assert(false, "Index out of range")
            }
            assert(isValidRowIndex(row: r), "Row-Index out of range")
            assert(isValidColumnIndex(column: c), "Column-Index out of range")
            self.counts[r][c] = newValue
        }
    }
    
    subscript(row: Int, column: Int) -> N {
        get {
            assert(isValidRowIndex(row: row), "Row-Index out of range")
            assert(isValidColumnIndex(column: column), "Column-Index out of range")
            return self.counts[row][column]
        }
        set {
            assert(isValidRowIndex(row: row), "Row-Index out of range")
            assert(isValidColumnIndex(column: column), "Column-Index out of range")
            self.counts[row][column] = newValue
        }
    }
    
    /// Appends a row
    public func appendRow(_ row: Array<N>, name: R?) throws {
        if !(row.count == self.cc) {
            os_log("Rows to append must have self.columns columns", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        counts.append(row)
        self.rr += 1
        if name != nil {
            if self.rnames != nil {
                self.rnames!.append(name!)
            }
        }
    }
    
    /// Appends a column
    public func appendColumn(_ column: Array<N>, name: C?) throws {
        if !(column.count == self.rr) {
            os_log("Columns to append must have self.rows rows", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        var i = 0
        for c in column {
            self.counts[i].append(c)
            i += 1
        }
        self.cc += 1
        if name != nil {
            if self.cnames != nil {
                self.cnames!.append(name!)
            }
//            else {
//                self.cnames = Array<String>.init(repeating: "(NA)", count: self.columns)
//                self.cnames!.remove(at: self.columns - 1)
//                self.cnames!.append(name!)
//            }
        }
    }
    
    /// Removes the row with name
    public func removeRow(rowName name: R) throws -> Array<N> {
        guard let i = self.indexOfRow(rowName: name) else {
            throw SSSwiftyStatsError.init(type: .rowNameUnknown, file: #file, line: #line, function: #function)
        }
        return self.removeRow(at: i)
    }
    
    /// Removes the column with name
    public func removeColumn(columnName name: C) throws -> Array<N> {
        guard let i = self.indexOfColumn(columnName: name) else {
            throw SSSwiftyStatsError.init(type: .columnNameUnknown, file: #file, line: #line, function: #function)
        }
        return self.removeColumn(at: i)
    }
    
    /// Remove row at index at
    public func removeRow(at: Int) -> Array<N> {
        assert(at >= 0 && at < self.rr, "Row-Index out of range")
        let removed = self.counts.remove(at: at)
        self.rr -= 1
        if self.rnames != nil {
            self.rnames!.remove(at: at)
        }
        return removed
    }
    
    /// Remove column at index at
    public func removeColumn(at: Int) -> Array<N> {
        assert(at >= 0 && at < self.cc, "Column-Index out of range")
        var temp: Array<N> = Array<N>()
        for i in 0..<self.counts.count {
            temp.append(self.counts[i].remove(at: at))
        }
        if self.cnames != nil {
            self.cnames!.remove(at: at)
        }
        self.cc -= 1
        return temp
    }
    
    /// Sets a row at a given index
    public func setRow(at: Int, newRow: Array<N>) throws {
        assert(isValidRowIndex(row: at), "Row-Index out of range")
        if newRow.count != self.columns {
            os_log("New row has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        for c in 0..<self.columns {
            self[at, c] = newRow[c]
        }
    }

    /// Sets a row at a given index
    public func setRow(name: R, newRow: Array<N>) throws {
        assert(isValidRowName(name: name), "Row-Index out of range")
        if newRow.count != self.columns {
            os_log("New row has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        let i = indexOfRow(rowName: name)!
        for c in 0..<self.columns {
            self[i, c] = newRow[c]
        }
    }

    /// Sets a column at a given index
    public func setColumn(name: C, newColumn: Array<N>) throws {
        assert(isValidColumnName(name: name), "Column-Index out of range")
        if newColumn.count != self.rows {
            os_log("New column has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        let i = indexOfColumn(columnName: name)!
        for r in 0..<self.rows {
            self[r, i] = newColumn[r]
        }
    }
    
    /// Sets a column at a given index
    public func setColumn(at: Int, newColumn: Array<N>) throws {
        assert(isValidColumnIndex(column: at), "Column-Index out of range")
        if newColumn.count != self.rows {
            os_log("New column has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        for r in 0..<self.rows {
            self[r, at] = newColumn[r]
        }
    }
    
    /// Inserts a row at index at
    public func insertRow(newRow: Array<N>, at: Int, name: R?) throws {
        assert(at >= 0 && at < self.rr, "Row-Index out of range")
        if !(newRow.count == self.cc) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.counts.insert(newRow, at: at)
        self.rr += 1
        if name != nil {
            if self.rnames != nil {
                self.rnames!.insert(name!, at: at)
            }
//            else {
//                self.rnames = Array<String>.init(repeating: "(NA)", count: self.rows - 1)
//                self.rnames!.insert(name!, at: at)
//            }
        }
    }
    
    /// Inserts a column at index at
    public func insertColumn(newColumn: Array<N>, at: Int, name: C?) throws {
        assert(at >= 0 && at < self.cc, "Column-Index out of range")
        if !(newColumn.count == self.rr) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        var i = 0
        for v in newColumn {
            self.counts[i].insert(v, at: at)
            i += 1
        }
        self.cc += 1
        if name != nil {
            if self.cnames != nil {
                self.cnames!.insert(name!, at: at)
            }
//            else {
//                self.cnames = Array<String>.init(repeating: "(NA)", count: self.columns - 1)
//                self.cnames!.insert(name!, at: at)
//            }
        }
    }
    
    /// Replaces the row at a given index
    public func replaceRow(newRow: Array<N>, at: Int, name: R?) throws {
        assert(self.isValidRowIndex(row: at), "Row-Index out of range")
        do {
            try self.insertRow(newRow: newRow, at: at, name: name)
        }
        catch {
            throw error
        }
        let _ = self.removeRow(at: at + 1)
    }

    
    /// Replaces the column at a given index
    public func replaceColumn(newColumn: Array<N>, at: Int, name: C?) throws {
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
    public func setRowNames(rowNames: Array<R>) throws {
        if !(rowNames.count == self.rr) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.rnames = rowNames
    }
    
    /// Sets the column names. Length of columnNames must be equal to self.columns
    public func setColumnNames(columnNames: Array<C>) throws {
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
                string.append("\(s)" + " | ")
            }
            string.append("\n")
        }
        for r in 0..<rows {
            if let rn = self.rowNames {
                string.append("\(rn[r])" + " | ")
            }
            for c in 0..<columns {
                string.append("\(counts[r][c]) ")
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
                            if N.self is Int.Type {
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
                        if N.self is Int.Type {
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
    public func rowSum(rowName: R) -> Double {
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
    public func columnSum(columnName: C) -> Double {
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
    public func nameOfColumn(column: Int) -> C? {
        assert(column < self.columns && column >= 0, "Column-Index out of range")
        if let cn = self.columnNames {
            return cn[column]
        }
        else {
            return nil
        }
    }
    
    /// Returns the name of the row or nil if there is no name
    public func nameOfRow(row: Int) -> R? {
        assert(row < self.rows && row >= 0, "Row-Index out of range")
        if let rn = self.rowNames {
            return rn[row]
        }
        else {
            return nil
        }
    }
    
    /// Returns the index of the column with name columnName or nil if there is no column with that name.
    public func indexOfColumn(columnName: C) -> Int? {
        if let cn = self.columnNames {
            return cn.index(of: columnName)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the index of the row with name rowName or nil if there is no row with that name.
    public func indexOfRow(rowName: R) -> Int? {
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
    
    /// Returns the largest column total
    public var largestRowTotal: Double {
        get {
            assert(self.rows > 0, "Now data")
            if let r = self.rowSums?.sorted(by: {$0 > $1}) {
                return r.first!
            }
            else {
                return Double.nan
            }
        }
    }

    /// Returns the largest column total
    public var largestColumTotal: Double {
        get {
            assert(self.columns > 0, "Now data")
            if let c = self.columnSums?.sorted(by: {$0 > $1}) {
                return c.first!
            }
            else {
                return Double.nan
            }
        }
    }
    
    /// Returns the largest cell count for column
    public func largestCellCount(column: Int) -> Double {
        if self.isNumeric {
            assert(isValidColumnIndex(column: column), "Row-Index out of range")
            let column = try! self.column(columnIndex: column, sorted: true)
            if N.self is Int.Type {
                return Double(column.last as! Int)
            }
            else {
                return column.last! as! Double
            }
        }
        else {
            return Double.nan
        }
    }

    
    /// Returns the largest cell count for row
    public func largestCellCount(row: Int) -> Double {
        if self.isNumeric {
            assert(isValidRowIndex(row: row), "Row-Index out of range")
            let row = try! self.row(rowIndex: row, sorted: true)
            if N.self is Int.Type {
                return Double(row.last as! Int)
            }
            else {
                return row.last! as! Double
            }
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
            if N.self is Int.Type {
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
    public func relativeFrequencyCell(rowName: R, columnName: C) throws -> Double {
        assert(isValidRowName(name: rowName), "Row-Name unknown")
        assert(isValidColumnName(name: columnName), "Column-Name unknown")
        var temp: Double = 0.0
        if self.isNumeric {
            if N.self is Int.Type {
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
            if N.self is Int.Type {
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
            if N.self is Int.Type {
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
            if N.self is Int.Type {
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

    /// Returns the expected frequency for cell[row, column]
    public func expectedFrequency(rowName: R, columnName: C) -> Double {
        assert(isValidRowName(name: rowName), "Row-index out of range")
        assert(isValidColumnName(name: columnName), "Column-index out of range")
        if self.isNumeric {
            let r = self.indexOfRow(rowName: rowName)!
            let c = self.indexOfColumn(columnName: columnName)!
            return (self.rowSum(row: r) * self.columnSum(column: c)) / self.total
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
            if N.self is Int.Type {
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
    /// - Precondition: at least nominal scaled measurements
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
    /// - Precondition: at least nominal scaled measurements
    public var likelihoodRatio: Double {
        get {
            var temp: Double = 0.0
            var sum: Double = 0.0
            if self.isNumeric {
                for r in 0..<self.rows {
                    for c in 0..<self.columns {
                        if N.self is Int.Type {
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
    /// - Precondition: at least nominal scaled measurements
    public var chiSquareYates: Double {
        get {
            if self.is2x2Table {
                var n11: Double
                var n12: Double
                var n21: Double
                var n22: Double
                if N.self is Int.Type {
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

    /// Returns the covariance
    /// - Precondition: at least interval scaled measurements
    public var covariance: Double {
        get {
            if self.rowLevelOfMeasurement == .nominal || self.columnLevelOfMeasurement == .nominal {
                return Double.nan
            }
            else {
                var frc: Double = 0.0
                var sum1: Double = 0.0
                if self.isNumeric {
                    var X: Double
                    var Y: Double
                    for r in 0..<self.rows {
                        if R.self is Int.Type {
                            X = Double(self.rowNames![r] as! Int)
                        }
                        else {
                            X = self.rowNames![r] as! Double
                        }
                        for c in 0..<self.columns {
                            if C.self is Int.Type {
                                Y = Double(self.columnNames![c] as! Int)
                            }
                            else {
                                Y = self.columnNames![c] as! Double
                            }
                            if N.self is Int.Type {
                                frc = Double(self[r, c] as! Int)
                            }
                            else {
                                frc = self[r, c] as! Double
                            }
                            sum1 += X * Y * frc
                        }
                    }
                    var sum2: Double = 0.0
                    for r in 0..<self.rows {
                        if R.self is Int.Type {
                            X = Double(self.rowNames![r] as! Int)
                        }
                        else {
                            X = self.rowNames![r] as! Double
                        }
                        sum2 += X * self.rowSum(row: r)
                    }
                    var sum3: Double = 0.0
                    for c in 0..<self.columns {
                        if C.self is Int.Type {
                            Y = Double(self.columnNames![c] as! Int)
                        }
                        else {
                            Y = self.columnNames![c] as! Double
                        }
                        sum3 += Y * self.columnSum(column: c)
                    }
                    return sum1 - (sum2 * sum3) / self.total
                }
                else {
                    return Double.nan
                }
            }
        }
    }
    /// Returns the product moment correlation r (Pearson's r)
    /// - Precondition: At least interval scaled measurements
    public var pearsonR: Double {
        get {
            if self.isNumeric && self.rowLevelOfMeasurement != .nominal && self.rowLevelOfMeasurement != .ordinal && self.columnLevelOfMeasurement != .nominal && self.columnLevelOfMeasurement != .ordinal {
                var X: Double
                var Y: Double
                var sum1: Double = 0.0
                var SX: Double
                var SY: Double
                for r in 0..<self.rows {
                    if R.self is Int.Type {
                        X = Double(self.rowNames![r] as! Int)
                    }
                    else {
                        X = self.rowNames![r] as! Double
                    }
                    sum1 += X * X * self.rowSum(row: r)
                }
                var sum2: Double = 0.0
                for r in 0..<self.rows {
                    if R.self is Int.Type {
                        X = Double(self.rowNames![r] as! Int)
                    }
                    else {
                        X = self.rowNames![r] as! Double
                    }
                    sum2 += X * self.rowSum(row: r)
                }
                SX = sum1 - pow(sum2, 2.0) / self.total
                sum1 = 0.0
                for c in 0..<self.columns {
                    if C.self is Int.Type {
                        Y = Double(self.columnNames![c] as! Int)
                    }
                    else {
                        Y = self.columnNames![c] as! Double
                    }
                    sum1 += Y * Y * self.columnSum(column: c)
                }
                sum2 = 0.0
                for c in 0..<self.columns {
                    if C.self is Int.Type {
                        Y = Double(self.columnNames![c] as! Int)
                    }
                    else {
                        Y = self.columnNames![c] as! Double
                    }
                    sum2 += Y * self.columnSum(column: c)
                }
                SY = sum1 - pow(sum2, 2.0) / self.total
                return self.covariance / sqrt(SX * SY)
            }
            else {
                return Double.nan
            }
        }
    }
    
    /// Returns Phi
    public var phi: Double {
        get {
            return sqrt(self.chiSquare / self.total)
        }
    }
    
    /// Returns the Mantel-Haenszel Chi-Square
    public var chiSquareMH: Double {
        get {
            return (self.total - 1.0) * pow(self.pearsonR, 2.0)
        }
    }
    
    /// Returns the coefficient of contingency
    public var cc: Double {
        get {
            let chi = self.chiSquare
            return sqrt(chi / (chi + self.total))
        }
    }
    
    /// Returns the coefficient of contingency
    public var coefficientOfContingency: Double {
        get {
            return self.cc
        }
    }

    /// Returns Cramer's V
    public var cramerV: Double {
        get {
            let q = Double(min(self.rows, self.columns))
            let chi = self.chiSquare
            return sqrt(chi / (self.total * (q - 1.0)))
        }
    }
    
    /// Returns Lambda
    public var lambda_C_R: Double {
        if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
            let cm = self.largestColumTotal
            var sum: Double = 0.0
            for r in 0..<self.rows {
                sum += self.largestCellCount(row: r)
            }
            return (sum - cm) / (self.total - cm)
        }
        else {
            return Double.nan
        }
    }

    /// Returns Lambda
    public var lambda_R_C: Double {
        if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
            let rm = self.largestRowTotal
            var sum: Double = 0.0
            for c in 0..<self.columns {
                sum += self.largestCellCount(column: c)
            }
            return (sum - rm) / (self.total - rm)
        }
        else {
            return Double.nan
        }
    }


    /// Returns the relative risk
    /// - Preconditions: Only applicable to a 2x2 table
    public var r0: Double {
        get {
            if self.is2x2Table {
                var n11: Double
                var n12: Double
                var n21: Double
                var n22: Double
                if N.self is Int.Type {
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
                return (n11 * n22) / (n12 * n21)
            }
            else {
                return Double.nan
            }
        }
    }

    
    /// Returns the relative risk in a cohort study
    /// - Preconditions: Only applicable to a 2x2 table
    public var r1: Double {
        get {
            if self.is2x2Table {
                var n11: Double
                var n12: Double
                var n21: Double
                var n22: Double
                if N.self is Int.Type {
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
                return (n11 * (n21 + n22)) / (n21 * (n11 + n12))
            }
            else {
                return Double.nan
            }
        }
    }

    
    public var tauCR: Double {
        get {
            if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
                var sum1 = 0.0
                var sum2 = 0.0
                var fij = 0.0
                for r in 0..<self.rows {
                    for c in 0..<self.columns {
                        if N.self is Int.Type {
                            fij = Double(self[r,c] as! Int)
                        }
                        else {
                            fij = self[r,c] as! Double
                        }
                        sum1 += pow(fij, 2.0) / self.rowSum(row: r)
                        sum2 += pow(self.columnSum(column: c), 2.0)
                    }
                }
                return (self.total * sum1 - sum2) / (pow(self.total, 2.0) - sum2)
            }
            else {
                return Double.nan
            }
        }
    }
}

