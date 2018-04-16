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

/// Class provides a matrix-like crosstable. Elements are accessible by c[row, column].
/// - Precondition: Rows and columns must be named.
public struct SSCrosstab<N,R,C>: Codable where N: Comparable,N: Codable, N: Hashable, R: Comparable,R: Codable, R: Hashable, C: Comparable, C: Hashable, C: Codable {
    
    /// Number of rows
    public var rowCount: Int {
        get {
            return rr
        }
    }
    
    /// Number of columns
    public var columnCount: Int {
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
    
    /// Returns the row names or nil
    public var rowNames: Array<R>? {
        get {
            return rnames
        }
    }
    
    /// Returns the column names or nil
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
    
    /// Defines the level of measurement of the row variable
    public var rowLevelOfMeasurement: SSLevelOfMeasurement {
        get {
            return self.levelRows
        }
        set {
            self.levelRows = newValue
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case rnames = "rowNames"
        case cnames = "columnNames"
        case levelRows = "levelOfRows"
        case levelColumns = "levelOfColumns"
        case rr = "rowCount"
        case cc = "columnCount"
        case counts = "table"
        case isNumeric = "isNumeric"
    }
    

    
    private var rnames: Array<R>?
    private var cnames: Array<C>?
    private var levelRows: SSLevelOfMeasurement
    private var levelColumns: SSLevelOfMeasurement
    
    private var rr: Int, cc: Int
    private var counts: Array<Array<N>>
    
    public var isNumeric: Bool
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rnames, forKey:CodingKeys.rnames)
        try container.encode(cnames, forKey: CodingKeys.cnames)
        try container.encode(levelRows.rawValue, forKey: CodingKeys.levelRows)
        try container.encode(levelColumns.rawValue, forKey: CodingKeys.levelColumns)
        try container.encode(rr, forKey: CodingKeys.rr)
        try container.encode(cc, forKey: CodingKeys.cc)
        try container.encode(counts, forKey: CodingKeys.counts)
        try container.encode(isNumeric, forKey: CodingKeys.isNumeric)
    }
    

    public init (from decoder: Decoder) throws {
        let container = try  decoder.container(keyedBy: CodingKeys.self)
        self.rnames = try container.decode(Array<R>.self, forKey: CodingKeys.rnames)
        self.cnames = try container.decode(Array<C>.self, forKey: CodingKeys.cnames)
        self.levelRows = try container.decode(SSLevelOfMeasurement.self, forKey: CodingKeys.levelRows)
        self.levelColumns = try container.decode(SSLevelOfMeasurement.self, forKey: CodingKeys.levelColumns)
        self.rr = try container.decode(Int.self, forKey: CodingKeys.rr)
        self.cc = try container.decode(Int.self, forKey: CodingKeys.cc)
        self.counts = try container.decode(Array<Array<N>>.self, forKey: CodingKeys.counts)
        self.isNumeric = try container.decode(Bool.self, forKey: CodingKeys.isNumeric)
    }
    
    /// Initializes a new crosstab
    /// - Parameter rows: number of rows
    /// - Parameter columns: number of columns
    /// - Parameter initialValue: Initial value for cell count
    /// - Parameter rowID: An array containing `rows` row identifiers
    /// - Parameter columnID: An array containing `columns` column identifiers
    /// - Throws: An error of type SSSwiftyStatsError
    init(rows: Int, columns: Int, initialValue: N, rowID: Array<R>, columnID: Array<C>) throws {
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
    
    /// Returns `true` if rows = 2 and columns = 2
    public var is2x2Table: Bool {
        get {
            return self.rowCount == 2 && self.columnCount == 2
        }
    }
    /// Returns `true` if name is a valid row-name
    func isValidRowName(name: R) -> Bool {
        if let _ = indexOfRow(rowName: name) {
            return true
        }
        else {
            return false
        }
    }

    /// Returns  `true`  if name is a valid column-name
    func isValidColumnName(name: C) -> Bool {
        if let _ = indexOfColumn(columnName: name) {
            return true
        }
        else {
            return false
        }
    }

    /// Returns `true` if row is a valid index
    private func isValidRowIndex(row: Int) -> Bool {
        return row >= 0 && row < self.rowCount
    }

    /// Returns `true` if column is a valid column index
    private func isValidColumnIndex(column: Int) -> Bool {
        return column >= 0 && column < self.columnCount
    }

    /// Returns `true` if row and column are valid indexes
    private func isValidIndex(row: Int, column: Int) -> Bool {
        return row >= 0 && row < self.rr && column >= 0 && column < self.cc
    }
    
    /// Returns the row at rowIndex
    /// - Throws: An error of type SSSwiftyStatsError
    public func row(at idx: Int, sorted: Bool! = false) throws -> Array<N> {
        if !(idx >= 0 && idx < self.rr) {
            throw SSSwiftyStatsError.init(type: .rowIndexOutOfRange, file: #file, line: #line, function: #function)
        }
        if sorted {
            return self.counts[idx].sorted(by: { $0 < $1 })
        }
        else {
            return self.counts[idx]
        }
    }
    
    /// Returns the column at columnIndex
    /// - Throws: An error of type SSSwiftyStatsError
    public func column(at idx: Int, sorted: Bool! = false) throws -> Array<N> {
        if !(idx >= 0 && idx < self.cc) {
            throw SSSwiftyStatsError.init(type: .columnIndexOutOfRange, file: #file, line: #line, function: #function)
        }
        var temp = Array<N>()
        for r in 0..<self.rr {
            temp.append(self.counts[r][idx])
        }
        if sorted {
            return temp.sorted(by: {$0 < $1})
        }
        else {
            return temp
        }
    }
    
    /// Returns the row with name rowName or nil
    /// - Throws: An error of type SSSwiftyStatsError
    public func rowNamed(_ rowName: R, sorted: Bool! = false) throws -> Array<N>? {
        if self.rnames != nil {
            if let i = self.rnames!.index(of: rowName) {
                do {
                    return try self.row(at: i, sorted: sorted)
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
    /// - Throws: An error of type SSSwiftyStatsError
    public func columnNamed(_ columnName: C, sorted: Bool = false) throws -> Array<N>? {
        if self.cnames != nil {
            if let i = self.cnames!.index(of: columnName) {
                do {
                    return try self.column(at: i, sorted: sorted)
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
    
    /// Accesses the element at [rowName][columnName]
    subscript(rowName: R!, columnName: C!) -> N {
        get {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            if let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) {
                return self.counts[r][c]
            }
            else {
                fatalError("Index out of range")
            }
        }
        set {
            assert(self.rnames != nil && self.cnames != nil, "Index out of range")
            if let r = self.rnames!.index(of: rowName), let c = self.cnames!.index(of: columnName) {
                self.counts[r][c] = newValue
            }
            else {
                fatalError("Index out of range")
            }
        }
    }
    
    /// Accesses the element at [row][column]
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating  func appendRow(_ row: Array<N>, name: R?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func appendColumn(_ column: Array<N>, name: C?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func removeRow(rowName name: R) throws -> Array<N> {
        if let i = self.indexOfRow(rowName: name) {
            return self.removeRow(at: i)
        }
        else {
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Removes the column with name
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func removeColumn(columnName name: C) throws -> Array<N> {
        if let i = self.indexOfColumn(columnName: name) {
            return self.removeColumn(at: i)
        }
        else {
            throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Remove row at `index`
    public mutating func removeRow(at index: Int) -> Array<N> {
        assert(index >= 0 && index < self.rr, "Row-Index out of range")
        let removed = self.counts.remove(at: index)
        self.rr -= 1
        if self.rnames != nil {
            self.rnames!.remove(at: index)
        }
        return removed
    }
    
    /// Remove column at `index`
    public mutating func removeColumn(at idx: Int) -> Array<N> {
        assert(idx >= 0 && idx < self.cc, "Column-Index out of range")
        var temp: Array<N> = Array<N>()
        for i in 0..<self.counts.count {
            temp.append(self.counts[i].remove(at: idx))
        }
        if self.cnames != nil {
            self.cnames!.remove(at: idx)
        }
        self.cc -= 1
        return temp
    }
    
    /// Sets a row at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setRow(at: Int, newRow: Array<N>) throws {
        assert(isValidRowIndex(row: at), "Row-Index out of range")
        if newRow.count != self.columnCount {
            os_log("New row has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        for c in 0..<self.columnCount {
            self[at, c] = newRow[c]
        }
    }

    /// Sets a row at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setRow(name: R, newRow: Array<N>) throws {
        assert(isValidRowName(name: name), "Row-Index out of range")
        if newRow.count != self.columnCount {
            os_log("New row has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        let i = indexOfRow(rowName: name)!
        for c in 0..<self.columnCount {
            self[i, c] = newRow[c]
        }
    }

    /// Sets a column at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setColumn(name: C, newColumn: Array<N>) throws {
        assert(isValidColumnName(name: name), "Column-Index out of range")
        if newColumn.count != self.rowCount {
            os_log("New column has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        let i = indexOfColumn(columnName: name)!
        for r in 0..<self.rowCount {
            self[r, i] = newColumn[r]
        }
    }
    
    /// Sets a column at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setColumn(at: Int, newColumn: Array<N>) throws {
        assert(isValidColumnIndex(column: at), "Column-Index out of range")
        if newColumn.count != self.rowCount {
            os_log("New column has the wrong length", log: log_stat, type: .error)
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        for r in 0..<self.rowCount {
            self[r, at] = newColumn[r]
        }
    }
    
    /// Inserts a row at index at
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func insertRow(newRow: Array<N>, at: Int, name: R?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func insertColumn(newColumn: Array<N>, at: Int, name: C?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func replaceRow(newRow: Array<N>, at: Int, name: R?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func replaceColumn(newColumn: Array<N>, at: Int, name: C?) throws {
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
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setRowNames(rowNames: Array<R>) throws {
        if !(rowNames.count == self.rr) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.rnames = rowNames
    }
    
    /// Sets the column names. Length of columnNames must be equal to self.columns
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setColumnNames(columnNames: Array<C>) throws {
        if !(columnNames.count == self.cc) {
            throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
        }
        self.cnames = columnNames
    }
    
    /// Description string
    public var description: String {
        var string = ""
        if let cn = self.columnNames {
            for s in cn {
                string.append("\(s)" + " | ")
            }
            string.append("\n")
        }
        for r in 0..<rowCount {
            if let rn = self.rowNames {
                string.append("\(rn[r])" + " | ")
            }
            for c in 0..<columnCount {
                string.append("\(counts[r][c]) ")
            }
            string.append("\n")
        }
        return string
    }
}

extension SSCrosstab {
    
    /// Returns the row sums as an array with self.rowCount values
    public var rowSums: Array<Double>? {
        get {
                if self.isNumeric {
                    var sum: Double = 0.0
                    var temp = Array<Double>()
                    for r in 0..<self.rowCount {
                        sum = 0.0
                        for c in 0..<self.columnCount {
                            if let temp1 = castValueToDouble(self[r, c]) {
                                sum += temp1
                            }
                            else {
                                fatalError("internal error")
                            }
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
    
    /// Returns the column sums as an array with self.columnCount values
    public var columnSums: Array<Double>? {
        get {
            if self.isNumeric {
                var sum: Double = 0.0
                var temp = Array<Double>()
                for c in 0..<self.columnCount {
                    sum = 0.0
                    for r in 0..<self.rowCount {
                        if let temp1 = castValueToDouble(self[r, c]) {
                            sum += temp1
                        }
                        else {
                            fatalError("internal error")
                        }
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
    
    /// Returns the sum of a row
    public func rowSum(row: Int) -> Double {
        assert(row < self.rowCount && row >= 0, "Row-Index out of range")
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
            if let i = rn.index(of: rowName) {
                return self.rowSum(row: i)
            }
            else {
                return Double.nan
            }
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
            if let i = rn.index(of: columnName) {
                return self.columnSum(column: i)
            }
            else {
                return Double.nan
            }
        }
        else {
            return Double.nan
        }
    }

    /// Returns the name of the column or nil if there is no name
    public func nameOfColumn(column: Int) -> C? {
        assert(column < self.columnCount && column >= 0, "Column-Index out of range")
        if let cn = self.columnNames {
            return cn[column]
        }
        else {
            return nil
        }
    }
    
    /// Returns the name of the row or nil if there is no name
    public func nameOfRow(row: Int) -> R? {
        assert(row < self.rowCount && row >= 0, "Row-Index out of range")
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
    
    
    /// Returns the total
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
            assert(self.rowCount > 0, "Missing data")
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
            assert(self.columnCount > 0, "Missing data")
            if let c = self.columnSums?.sorted(by: {$0 > $1}) {
                return c.first!
            }
            else {
                return Double.nan
            }
        }
    }
    
    /// Returns the largest cell count for column
    public func largestCellCount(atColumn: Int) -> Double {
        if self.isNumeric {
            assert(isValidColumnIndex(column: atColumn), "Row-Index out of range")
            let column = try! self.column(at: atColumn, sorted: true)
            if let temp1 = castValueToDouble(column.last) {
                return temp1
            }
            else {
                fatalError("internal error")
            }
        }
        else {
            return Double.nan
        }
    }

    
    /// Returns the largest cell count for row
    public func largestCellCount(atRow: Int) -> Double {
        if self.isNumeric {
            assert(isValidRowIndex(row: atRow), "Row-Index out of range")
            let row = try! self.row(at: atRow, sorted: true)
            if let temp1 = castValueToDouble(row.last) {
                return temp1
            }
            else {
                fatalError("internal error")
            }
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative total frequency of a cell at [row, column]
    public func relativeTotalFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        if self.isNumeric {
            if let temp = castValueToDouble(self[row, column]) {
                return temp / self.total
            }
            else {
                fatalError("internal error")
            }
        }
        else {
            return Double.nan
        }
    }
    

    /// Returns the relative frequency of [rowName, columnName]
    public func relativeTotalFrequency(rowName: R, columnName: C) throws -> Double {
        assert(isValidRowName(name: rowName), "Row-Name unknown")
        assert(isValidColumnName(name: columnName), "Column-Name unknown")
        if self.isNumeric {
            if let temp = castValueToDouble(self[rowName, columnName]) {
                return temp / self.total
            }
            else {
                fatalError("internal error")
            }
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative row frequency of cell[row, column]
    public func relativeRowFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        if self.isNumeric {
            if let temp = castValueToDouble(self[row, column]) {
                return temp / self.rowSums![row]
            }
            else {
                fatalError("internal error")
            }
        }
        else {
            return Double.nan
        }
    }

    /// Returns the relative column frequency of cell[row, column]
    public func relativeColumnFrequency(row: Int, column: Int) -> Double {
        assert(isValidRowIndex(row: row), "Row-index out of range")
        assert(isValidColumnIndex(column: column), "Column-index out of range")
        if self.isNumeric {
            if let temp = castValueToDouble(self[row, column]) {
                return temp / self.columnSums![column]
            }
            else {
                fatalError("internal error")
            }
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

    /// Returns the expected frequency for cell[rowName, columnName]
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
        if self.isNumeric {
            if let temp = castValueToDouble(self[row, column]) {
                return temp - self.expectedFrequency(row: row, column: column)
            }
            else {
                fatalError("internal error")
            }
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
            let df = Double(self.rowCount - 1) * Double(self.columnCount - 1)
            if df >= 0.0 {
                return df
            }
            else {
                return Double.nan
            }
        }
    }

    /// Returns Pearson's Chi-Square
    /// - Precondition: Mesurement must be at least nominal scaled
    public var chiSquare: Double {
        get {
            if self.isNumeric {
                var sum: Double = 0.0
                for r in 0..<self.rowCount {
                    for c in 0..<self.columnCount {
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
            var sum: Double = 0.0
            if self.isNumeric {
                for r in 0..<self.rowCount {
                    for c in 0..<self.columnCount {
                        if let temp = castValueToDouble(self[r, c]) {
                            if temp != 0 {
                                sum += temp * log(temp / self.expectedFrequency(row: r, column: c))
                            }
                        }
                        else {
                            fatalError("internal error")
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
                if let n11 = castValueToDouble(self[0,0]), let n12 = castValueToDouble(self[0,1]), let n21 = castValueToDouble(self[1,0]), let n22 = castValueToDouble(self[1,1]) {
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
                    fatalError("internal error")
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
                var sum1: Double = 0.0
                if self.isNumeric {
                    for r in 0..<self.rowCount {
                        if let X = castValueToDouble(self.rowNames![r]) {
                            for c in 0..<self.columnCount {
                                if let Y = castValueToDouble(self.columnNames![c]) {
                                    if let frc = castValueToDouble(self[r, c]) {
                                        sum1 += X * Y * frc
                                    }
                                    else {
                                        fatalError("internal error")
                                    }
                                }
                                else {
                                    fatalError("internal error")
                                }
                            }
                        }
                        else {
                            fatalError("internal error")
                        }
                    }
                    var sum2: Double = 0.0
                    for r in 0..<self.rowCount {
                        if let X = castValueToDouble(self.rowNames![r]) {
                            sum2 += X * self.rowSum(row: r)
                        }
                        else {
                            fatalError("internal error")
                        }
                    }
                    var sum3: Double = 0.0
                    for c in 0..<self.columnCount {
                        if let Y = castValueToDouble(self.columnNames![c]) {
                            sum3 += Y * self.columnSum(column: c)
                        }
                        else {
                            fatalError("internal error")
                        }
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
                var sum1: Double = 0.0
                var sum2: Double = 0.0
                var SX: Double
                var SY: Double
                for r in 0..<self.rowCount {
                    if let X = castValueToDouble(self.rowNames![r]) {
                        sum1 += X * X * self.rowSum(row: r)
                        sum2 += X * self.rowSum(row: r)
                    }
                    else {
                        fatalError("internal error")
                    }
                }
                SX = sum1 - pow(sum2, 2.0) / self.total
                sum1 = 0.0
                sum2 = 0.0
                for c in 0..<self.columnCount {
                    if let Y = castValueToDouble(self.columnNames![c]) {
                        sum1 += Y * Y * self.columnSum(column: c)
                        sum2 += Y * self.columnSum(column: c)
                    }
                    else {
                        fatalError("internal error")
                    }
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
    public var ccont: Double {
        get {
            let chi = self.chiSquare
            return sqrt(chi / (chi + self.total))
        }
    }
    
    /// Returns the coefficient of contingency
    public var coefficientOfContingency: Double {
        get {
            return self.ccont
        }
    }

    /// Returns Cramer's V
    public var cramerV: Double {
        get {
            let q = Double(min(self.rowCount, self.columnCount))
            let chi = self.chiSquare
            return sqrt(chi / (self.total * (q - 1.0)))
        }
    }
    
    /// Returns Lambda
    public var lambda_C_R: Double {
        if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
            let cm = self.largestColumTotal
            var sum: Double = 0.0
            for r in 0..<self.rowCount {
                sum += self.largestCellCount(atRow: r)
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
            for c in 0..<self.columnCount {
                sum += self.largestCellCount(atColumn: c)
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
                if let n11 = castValueToDouble(self[0,0]), let n12 = castValueToDouble(self[0,1]), let n21 = castValueToDouble(self[1,0]), let n22 = castValueToDouble(self[1,1]) {
                    return (n11 * n22) / (n12 * n21)
                }
                else {
                    fatalError("internal error")
                }
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
                if let n11 = castValueToDouble(self[0,0]), let n12 = castValueToDouble(self[0,1]), let n21 = castValueToDouble(self[1,0]), let n22 = castValueToDouble(self[1,1]) {
                    return (n11 * (n21 + n22)) / (n21 * (n11 + n12))
                }
                else {
                    fatalError("internal error")
                }
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
                for r in 0..<self.rowCount {
                    for c in 0..<self.columnCount {
                        if let fij = castValueToDouble(self[r,c]) {
                            sum1 += pow(fij, 2.0) / self.rowSum(row: r)
                            sum2 += pow(self.columnSum(column: c), 2.0)
                        }
                        else {
                            fatalError("internal error")
                        }
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

