//
//  SSCrosstab.swift
//  SwiftyStats
//
//  Created by strike65 on 12.08.17.
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
#if os(macOS) || os(iOS)
import os.log
#endif

/// Struct provides a matrix-like crosstable. Elements are accessible by c[row, column].
/// - Precondition: Rows and columns must be named. Row- <R> and column- <C> names are defined as generics. The content of one cell <N> is generic too.
public struct SSCrosstab<N,R,C, FPT: SSFloatingPoint>: Codable where N: Comparable,N: Codable, N: Hashable, R: Comparable,R: Codable, R: Hashable, C: Comparable, C: Hashable, C: Codable, FPT: Codable {
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
    
    /// Returns the row-names or nil
    public var rowNames: Array<R>? {
        get {
            return rnames
        }
    }
    
    /// Returns the column-names or nil
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
    
    /// Support for Codable
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
    
    
    
    /// the row-names
    private var rnames: Array<R>?
    /// the column-names
    private var cnames: Array<C>?
    /// the level of measurement for rows
    private var levelRows: SSLevelOfMeasurement
    /// the level of measurement for columns
    private var levelColumns: SSLevelOfMeasurement
    
    private var rr: Int, cc: Int
    
    private var counts: Array<Array<N>>
    
    public var isNumeric: Bool
    
    /// Encodes the instance to an encoder
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
    
    /// Decodes from a decoder
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
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("You must provide as many row id's as rows", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if columnID.count != columns {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("You must provide as many row id's as rows", log: .log_stat, type: .error)
            }
            
            #endif
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !Helpers.isNumber(initialValue) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Cell counts must be numeric", log: .log_stat, type: .error)
            }
            
            #endif
            
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
        
        self.isNumeric = Helpers.isNumber(initialValue)
    }
    
    /// Returns `true` if rows = 2 and columns = 2
    public var is2x2Table: Bool {
        get {
            return self.rowCount == 2 && self.columnCount == 2
        }
    }
    /// Returns true if the table is empty
    public var isEmpty: Bool {
        get {
            return self.rowCount == 0 && self.columnCount == 0
        }
    }
    
    /// Returns true if row-count == column-count
    public var isSquare: Bool {
        get {
            return self.rowCount == self.columnCount
        }
    }
    
    // MARK: Validity checking
    
    /// Returns `true` if name is a valid row-name
    func isValidRowName(name: R) -> Bool {
        if let _ = firstIndexOfRow(rowName: name) {
            return true
        }
        else {
            return false
        }
    }
    
    /// Returns  `true`  if name is a valid column-name
    func isValidColumnName(name: C) -> Bool {
        if let _ = firstIndexOfColumn(columnName: name) {
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
        if !isValidRowIndex(row: idx) {
            fatalError("Index out of range.")
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
        if !isValidColumnIndex(column: idx) {
            fatalError("Index out of range.")
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
        if isValidRowName(name: rowName) {
            if let i = self.rnames!.firstIndex(of: rowName) {
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
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unknown Row Name", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns the column with name columnName or nil
    /// - Throws: An error of type SSSwiftyStatsError
    public func columnNamed(_ columnName: C, sorted: Bool = false) throws -> Array<N>? {
        if isValidColumnName(name: columnName) {
            if let i = self.cnames!.firstIndex(of: columnName) {
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
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unknown Column Name", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Accesses the element at [rowName][columnName]
    subscript(_ rowName: R, _ columnName: C) -> N {
        get {
            if isValidRowName(name: rowName) && isValidColumnName(name: columnName) {
                if let r = self.rnames!.firstIndex(of: rowName), let c = self.cnames!.firstIndex(of: columnName) {
                    return self.counts[r][c]
                }
                else {
                    fatalError("Index out of range.")
                }
            }
            else {
                fatalError("Index out of range.")
            }
        }
        set {
            if isValidRowName(name: rowName) && isValidColumnName(name: columnName) {
                if let r = self.rnames!.firstIndex(of: rowName), let c = self.cnames!.firstIndex(of: columnName) {
                    self.counts[r][c] = newValue
                }
                else {
                    fatalError("Index out of range.")
                }
            }
            else {
                fatalError("Index out of range.")
            }
        }
    }
    
    /// Accesses the element at [row][column]
    subscript(_ row: Int, _ column: Int) -> N {
        get {
            if isValidRowIndex(row: row) && isValidColumnIndex(column: column) {
                return self.counts[row][column]
            }
            else {
                fatalError("Index out of range.")
            }
        }
        set {
            if isValidRowIndex(row: row) && isValidColumnIndex(column: column) {
                self.counts[row][column] = newValue
            }
            else {
                fatalError("Index out of range.")
            }
        }
    }
    
    /// Appends a row
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating  func appendRow(_ row: Array<N>, name: R?) throws {
        if !(row.count == self.cc) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Rows to append must have self.columns columns", log: .log_stat, type: .error)
            }
            
            #endif
            
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
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Columns to append must have self.rows rows", log: .log_stat, type: .error)
            }
            
            #endif
            
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
        }
    }
    
    /// Removes the row with name
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func removeRow(rowName name: R) throws -> Array<N> {
        if let i = self.firstIndexOfRow(rowName: name) {
            return self.removeRow(at: i)
        }
        else {
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Removes the column with name
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func removeColumn(columnName name: C) throws -> Array<N> {
        if let i = self.firstIndexOfColumn(columnName: name) {
            return self.removeColumn(at: i)
        }
        else {
            throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Remove row at `index`
    public mutating func removeRow(at index: Int) -> Array<N> {
        let removed: Array<N>
        if isValidRowIndex(row: index) {
            removed = self.counts.remove(at: index)
            self.rr -= 1
            if self.rnames != nil {
                self.rnames!.remove(at: index)
            }
            return removed
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Remove column at `index`
    public mutating func removeColumn(at idx: Int) -> Array<N> {
        if isValidColumnIndex(column: idx) {
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
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Sets a row at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setRow(at idx: Int, newRow: Array<N>) throws {
        if isValidRowIndex(row: idx) {
            if newRow.count != self.columnCount {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New row: wrong length", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            for c in 0..<self.columnCount {
                self[idx, c] = newRow[c]
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Sets a row at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setRow(name: R, newRow: Array<N>) throws {
        if isValidRowName(name: name) {
            if newRow.count != self.columnCount {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New row: wrong length", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            let i = firstIndexOfRow(rowName: name)!
            for c in 0..<self.columnCount {
                self[i, c] = newRow[c]
            }
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unknown row name", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Sets a column at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setColumn(name: C, newColumn: Array<N>) throws {
        if isValidColumnName(name: name) {
            if newColumn.count != self.rowCount {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New column: wrong length", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            let i = firstIndexOfColumn(columnName: name)!
            for r in 0..<self.rowCount {
                self[r, i] = newColumn[r]
            }
        }
        else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unknown row name", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Sets a column at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func setColumn(at idx: Int, newColumn: Array<N>) throws {
        if isValidColumnIndex(column: idx) {
            if newColumn.count != self.rowCount {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New column: wrong length", log: .log_stat, type: .error)
                }
                
                #endif
                
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            for r in 0..<self.rowCount {
                self[r, idx] = newColumn[r]
            }
        }
        else {
            fatalError("Index out of range")
        }
    }
    
    /// Inserts a row at index at
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func insertRow(newRow: Array<N>, at idx: Int, name: R?) throws {
        if isValidRowIndex(row: idx) {
            if !(newRow.count == self.cc) {
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            self.counts.insert(newRow, at: idx)
            self.rr += 1
            if name != nil {
                if self.rnames != nil {
                    self.rnames!.insert(name!, at: idx)
                }
            }
        }
    }
    
    /// Inserts a column at index at
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func insertColumn(newColumn: Array<N>, at idx: Int, name: C?) throws {
        if isValidColumnIndex(column: idx) {
            if !(newColumn.count == self.rr) {
                throw SSSwiftyStatsError.init(type: .sizeMismatch, file: #file, line: #line, function: #function)
            }
            var i = 0
            for v in newColumn {
                self.counts[i].insert(v, at: idx)
                i += 1
            }
            self.cc += 1
            if name != nil {
                if self.cnames != nil {
                    self.cnames!.insert(name!, at: idx)
                }
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Replaces the row at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func replaceRow(newRow: Array<N>, at idx: Int, name: R?) throws {
        if isValidRowIndex(row: idx) {
            do {
                try self.insertRow(newRow: newRow, at: idx, name: name)
            }
            catch {
                throw error
            }
            let _ = self.removeRow(at: idx + 1)
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    
    /// Replaces the column at a given index
    /// - Throws: An error of type SSSwiftyStatsError
    public mutating func replaceColumn(newColumn: Array<N>, at idx: Int, name: C?) throws {
        if isValidColumnIndex(column: idx) {
            do {
                try self.insertColumn(newColumn: newColumn, at: idx, name: name)
            }
            catch {
                throw error
            }
            let _ = self.removeColumn(at: idx + 1)
        }
        else {
            fatalError("Index out of range.")
        }
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
    public var rowSums: Array<FPT>? {
        get {
            if self.isNumeric {
                var sum: FPT = 0
                var temp = Array<FPT>()
                for r in 0..<self.rowCount {
                    sum = 0
                    for c in 0..<self.columnCount {
                        let temp1: FPT =  Helpers.makeFP(self[r, c])
                        if !temp1.isNaN {
                            sum += temp1
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
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
    public var columnSums: Array<FPT>? {
        get {
            if self.isNumeric {
                var sum: FPT = 0
                var temp = Array<FPT>()
                for c in 0..<self.columnCount {
                    sum = 0
                    for r in 0..<self.rowCount {
                        let temp1: FPT =  Helpers.makeFP(self[r, c])
                        if !temp1.isNaN {
                            sum += temp1
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
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
    public func rowSum(row: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if let rs = self.rowSums {
                return rs[row]
            }
            else {
                return FPT.nan
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Sum of row named rowName
    public func rowSum(rowName: R) -> FPT {
        if isValidRowName(name: rowName) {
            if let i = self.rnames!.firstIndex(of: rowName) {
                return self.rowSum(row: i)
            }
            else {
                return FPT.nan
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// The sum of a column
    public func columnSum(column: Int) -> FPT {
        if isValidColumnIndex(column: column) {
            if let cs = self.columnSums {
                return cs[column]
            }
            else {
                return FPT.nan
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Sum of column named columnName
    public func columnSum(columnName: C) throws -> FPT {
        if isValidColumnName(name: columnName) {
            if let i = self.cnames!.firstIndex(of: columnName) {
                return self.columnSum(column: i)
            }
            else {
                return FPT.nan
            }
        }
        else {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("New column: wrong length", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns the name of the column or nil if there is no name
    public func nameOfColumn(column: Int) -> C? {
        if isValidColumnIndex(column: column) {
            if let cn = self.columnNames {
                return cn[column]
            }
            else {
                return nil
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Returns the name of the row or nil if there is no name
    public func nameOfRow(row: Int) -> R? {
        if isValidRowIndex(row: row) {
            if let rn = self.rowNames {
                return rn[row]
            }
            else {
                return nil
            }
        }
        else {
            fatalError("Index out of range.")
        }
    }
    
    /// Returns the index of the column with name columnName or nil if there is no column with that name.
    public func firstIndexOfColumn(columnName: C) -> Int? {
        if let cn = self.columnNames {
            return cn.firstIndex(of: columnName)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the index of the row with name rowName or nil if there is no row with that name.
    public func firstIndexOfRow(rowName: R) -> Int? {
        if let rn = self.rowNames {
            return rn.firstIndex(of: rowName)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the total
    public var total: FPT {
        get {
            return self.rowTotal()
        }
    }
    
    /// Returns the sum of all rows
    public func rowTotal() -> FPT {
        if let rs = self.rowSums {
            var t: FPT = 0
            for s in rs {
                t += s
            }
            return t
        }
        else {
            return FPT.nan
        }
    }
    
    /// Returns the sum of all columns
    public func colummTotal() -> FPT {
        if let cs = self.columnSums {
            var t: FPT = 0
            for s in cs {
                t += s
            }
            return t
        }
        else {
            return FPT.nan
        }
    }
    
    
    
    /// Returns the largets row total
    ///
    /// - Returns: FPT Type or FPT.nan
    /// - Throws: SSSwiftyStatsError.missingData if there are no data
    public func largestRowTotal() throws -> FPT {
        if self.rowCount > 0 {
            if let r = self.rowSums?.sorted(by: {$0 > $1}) {
                return r.first!
            }
            else {
                return FPT.nan
            }
        }
        else {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("New column: wrong length", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .missingData, file: #file, line: #line, function: #function)
        }

    }
    
    /// Returns the largest column total
    func largestColumTotal() throws -> FPT {
        if self.rowCount > 0 {
            if let c = self.columnSums?.sorted(by: {$0 > $1}) {
                return c.first!
            }
            else {
                return FPT.nan
            }
        }
        else {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("New column: wrong length", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .missingData, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns the largest cell count for column
    public func largestCellCount(atColumn: Int) -> FPT {
        if self.isNumeric {
            if isValidColumnIndex(column: atColumn) {
                let column = try! self.column(at: atColumn, sorted: true)
                let temp1: FPT =  Helpers.makeFP(column.last)
                if !temp1.isNaN {
                    return temp1
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                fatalError("Index out of range.")
            }
        }
        else {
            return FPT.nan
        }
    }
    
    
    /// Returns the largest cell count for row
    public func largestCellCount(atRow: Int) -> FPT {
        if self.isNumeric {
            if isValidRowIndex(row: atRow) {
                let row = try! self.row(at: atRow, sorted: true)
                let temp1: FPT =  Helpers.makeFP(row.last)
                if !temp1.isNaN {
                    return temp1
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                fatalError("Index out of range.")
            }
        }
        else {
            return FPT.nan
        }
    }
    
    /// Returns the relative total frequency of a cell at [row, column]
    public func relativeTotalFrequency(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                if self.isNumeric {
                    let temp: FPT =  Helpers.makeFP(self[row, column])
                    if !temp.isNaN {
                        return temp / self.total
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                else {
                    return FPT.nan
                }
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row index out of range.")
        }
    }
    
    
    /// Returns the relative frequency of [rowName, columnName]
    public func relativeTotalFrequency(rowName: R, columnName: C) throws -> FPT {
        if isValidRowName(name: rowName) {
            if isValidColumnName(name: columnName) {
                if self.isNumeric {
                    let temp: FPT =  Helpers.makeFP(self[rowName, columnName])
                    return temp / self.total
                }
                else {
                    return FPT.nan
                }
            }
            else {

                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New column: wrong length", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
            }
        }
        else {

            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("New column: wrong length", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns the relative row frequency of cell[row, column]
    public func relativeRowFrequency(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                if self.isNumeric {
                    let temp: FPT =  Helpers.makeFP(self[row, column])
                    if !temp.isNaN {
                        return temp / self.rowSums![row]
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                else {
                    return FPT.nan
                }
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the relative column frequency of cell[row, column]
    public func relativeColumnFrequency(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                if self.isNumeric {
                    let temp: FPT =  Helpers.makeFP(self[row, column])
                    if  !temp.isNaN {
                        return temp / self.columnSums![column]
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                else {
                    return FPT.nan
                }
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the relative margin row frequency of [row]
    public func relativeRowMarginFrequency(row: Int) -> FPT {
        if isValidRowIndex(row: row) {
            var temp: FPT = 0
            if self.isNumeric {
                temp = self.rowSums![row]
                return temp / self.total
            }
            else {
                return FPT.nan
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the relative margin row frequency of [row]
    public func relativeColumnMarginFrequency(column: Int) -> FPT {
        if isValidColumnIndex(column: column) {
            var temp: FPT = 0
            if self.isNumeric {
                temp = self.columnSums![column]
                return temp / self.total
            }
            else {
                return FPT.nan
            }
        }
        else {
            fatalError("Column-index out of range")
        }
    }
    
    /// Returns the expected frequency for cell[row, column]
    public func expectedFrequency(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                if self.isNumeric {
                    return (self.rowSum(row: row) * self.columnSum(column: column)) / self.total
                }
                else {
                    return FPT.nan
                }
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the expected frequency for cell[rowName, columnName]
    public func expectedFrequency(rowName: R, columnName: C) throws -> FPT {
        if isValidRowName(name: rowName) {
            if isValidColumnName(name: columnName) {
                if self.isNumeric {
                    let r = self.firstIndexOfRow(rowName: rowName)!
                    let c = self.firstIndexOfColumn(columnName: columnName)!
                    return (self.rowSum(row: r) * self.columnSum(column: c)) / self.total
                }
                else {
                    return FPT.nan
                }
            }
            else {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("New column: wrong length", log: .log_stat, type: .error)
                }
                #endif
                throw SSSwiftyStatsError.init(type: .unknownColumnName, file: #file, line: #line, function: #function)
            }
        }
        else {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("New column: wrong length", log: .log_stat, type: .error)
            }
            #endif
            throw SSSwiftyStatsError.init(type: .unknownRowName, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns the residual for cell[row, column]
    public func residual(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                if self.isNumeric {
                    let temp: FPT =  Helpers.makeFP(self[row, column])
                    if  !temp.isNaN {
                        return temp - self.expectedFrequency(row: row, column: column)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                else {
                    return FPT.nan
                }
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the standardized residual for cell[row, column]
    public func standardizedResidual(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                return self.residual(row: row, column: column) / expectedFrequency(row: row, column: column).squareRoot()
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Returns the adjusted residual for cell[row, column]
    public func adjustedResidual(row: Int, column: Int) -> FPT {
        if isValidRowIndex(row: row) {
            if isValidColumnIndex(column: column) {
                let rowSum: FPT = self.rowSum(row: row)
                let columnSum: FPT = self.columnSum(column: column)
                let e1: FPT = self.residual(row: row, column: column)
                let e2: FPT = expectedFrequency(row: row, column: column)
                let e3: FPT = e2 * (FPT.one - rowSum / self.total)
                let e4: FPT = e3 * sqrt(FPT.one - columnSum / self.total)
                let e5 = e1 / e4
                return e5
            }
            else {
                fatalError("Column-index out of range")
            }
        }
        else {
            fatalError("Row-index out of range")
        }
    }
    
    /// Degrees of freedom
    public var degreesOfFreedom: FPT {
        get {
            let df: FPT =  Helpers.makeFP((self.rowCount - 1) * (self.columnCount - 1))
            if df >= 0 {
                return df
            }
            else {
                return FPT.nan
            }
        }
    }
    
    /// Returns Pearson's Chi-Square
    /// - Precondition: Measurements must be at least nominally scaled
    public var chiSquare: FPT {
        get {
            if self.isNumeric {
                var sum: FPT = 0
                for r in 0..<self.rowCount {
                    for c in 0..<self.columnCount {
                        sum += SSMath.pow1(self.residual(row: r, column: c), 2) / self.expectedFrequency(row: r, column: c)
                    }
                }
                return sum
            }
            else {
                return FPT.nan
            }
        }
    }
    
    /// Returns the Chi-Square Likelihood Ratio
    /// - Precondition: at least nominally scaled measurements
    public var chiSquareLikelihoodRatio: FPT {
        get {
            var sum: FPT = 0
            if self.isNumeric {
                for r in 0..<self.rowCount {
                    for c in 0..<self.columnCount {
                        let temp: FPT =  Helpers.makeFP(self[r, c])
                        if !temp.isNaN {
                            if temp != 0 {
                                sum += temp * SSMath.log1(temp / self.expectedFrequency(row: r, column: c))
                            }
                            else {
                                sum = 0
                            }
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                        }
                    }
                }
                return 2 * sum
            }
            else {
                return FPT.nan
            }
        }
    }
    
    /// Returns the Yates continuity corrected Chi-Square for a 2 x 2 table
    /// - Precondition: at least nominally scaled measurements
    public var chiSquareYates: FPT {
        get {
            if self.is2x2Table {
                let n11: FPT =  Helpers.makeFP(self[0,0])
                let n12: FPT =  Helpers.makeFP(self[0,1])
                let n21: FPT =  Helpers.makeFP(self[1,0])
                let n22: FPT =  Helpers.makeFP(self[1,1])
                if !n11.isNaN && !n12.isNaN && !n21.isNaN && !n21.isNaN {
                    let temp = abs(n11 * n22 - n12 * n21)
                    let t = self.total
                    if temp <= ( Helpers.makeFP(0.5 ) * t) {
                        return 0
                    }
                    else {
                        let den = self.rowSum(row: 0) * self.rowSum(row: 1) * self.columnSum(column: 0) * self.columnSum(column: 1)
                        return t * SSMath.pow1(temp -  Helpers.makeFP(0.5 ) * t, 2) / den
                    }
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                return FPT.nan
            }
        }
    }
    
    /// Returns the covariance
    /// - Precondition: at least interval-scaled measurements
    public var covariance: FPT {
        get {
            if self.rowLevelOfMeasurement == .nominal || self.columnLevelOfMeasurement == .nominal {
                return FPT.nan
            }
            else {
                var sum1: FPT = 0
                if self.isNumeric {
                    for r in 0..<self.rowCount {
                        let X:FPT =  Helpers.makeFP(self.rowNames![r])
                        if !X.isNaN {
                            for c in 0..<self.columnCount {
                                let Y: FPT =  Helpers.makeFP(self.columnNames![c])
                                if !Y.isNaN {
                                    let frc: FPT =  Helpers.makeFP(self[r, c])
                                    if !frc.isNaN {
                                        sum1 += X * Y * frc
                                    }
                                    else {
                                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                                    }
                                }
                                else {
                                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                                }
                            }
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                        }
                    }
                    var sum2: FPT = 0
                    for r in 0..<self.rowCount {
                        let X: FPT =  Helpers.makeFP(self.rowNames![r])
                        if !X.isNaN {
                            sum2 += X * self.rowSum(row: r)
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                        }
                    }
                    var sum3: FPT = 0
                    for c in 0..<self.columnCount {
                        let Y: FPT =  Helpers.makeFP(self.columnNames![c])
                        if !Y.isNaN {
                            sum3 += Y * self.columnSum(column: c)
                        }
                        else {
                            fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                        }
                    }
                    return sum1 - (sum2 * sum3) / self.total
                }
                else {
                    return FPT.nan
                }
            }
        }
    }
    
    /// Returns the product moment correlation r (Pearson's r)
    /// - Precondition: At least interval-scaled measurements
    public var pearsonR: FPT {
        get {
            if self.isNumeric && self.rowLevelOfMeasurement != .nominal && self.rowLevelOfMeasurement != .ordinal && self.columnLevelOfMeasurement != .nominal && self.columnLevelOfMeasurement != .ordinal {
                var sum1: FPT = 0
                var sum2: FPT = 0
                var SX: FPT
                var SY: FPT
                for r in 0..<self.rowCount {
                    let X: FPT =  Helpers.makeFP(self.rowNames![r])
                    if !X.isNaN {
                        sum1 += X * X * self.rowSum(row: r)
                        sum2 += X * self.rowSum(row: r)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                SX = sum1 - SSMath.pow1(sum2, 2) / self.total
                sum1 = 0
                sum2 = 0
                for c in 0..<self.columnCount {
                    let Y: FPT =  Helpers.makeFP(self.columnNames![c])
                    if !Y.isNaN {
                        sum1 += Y * Y * self.columnSum(column: c)
                        sum2 += Y * self.columnSum(column: c)
                    }
                    else {
                        fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                    }
                }
                SY = sum1 - SSMath.pow1(sum2, 2) / self.total
                return self.covariance / (SX * SY).squareRoot()
            }
            else {
                return FPT.nan
            }
        }
    }
    
    /// Returns the Mantel-Haenszel Chi-Square
    public var chiSquareMH: FPT {
        get {
            return (self.total - 1) * SSMath.pow1(self.pearsonR, 2)
        }
    }
    
    /// Returns Phi
    public var phi: FPT {
        get {
            return (self.chiSquare / self.total).squareRoot()
        }
    }
    
    /// Returns the coefficient of contingency
    public var ccont: FPT {
        get {
            let chi = self.chiSquare
            return (chi / (chi + self.total)).squareRoot()
        }
    }
    
    /// Returns the coefficient of contingency
    public var coefficientOfContingency: FPT {
        get {
            return self.ccont
        }
    }
    
    /// Returns Cramer's V
    public var cramerV: FPT {
        get {
            let q: FPT =  Helpers.makeFP(min(self.rowCount, self.columnCount))
            let chi = self.chiSquare
            return (chi / (self.total * (q - 1))).squareRoot()
        }
    }
    
    /// Returns "Column|Row -Lambda"
    public func lambda_C_R() throws -> FPT {
        if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
            let cm: FPT
            do {
                cm = try self.largestColumTotal()
            }
            catch {
                throw error
            }
            var sum: FPT = 0
            for r in 0..<self.rowCount {
                sum += self.largestCellCount(atRow: r)
            }
            return (sum - cm) / (self.total - cm)
        }
        else {
            return FPT.nan
        }
    }
    
    /// Returns the "Row|Column"-Lambda
    public func lambda_R_C() throws -> FPT {
        if self.isNumeric && self.rowLevelOfMeasurement == .nominal && self.columnLevelOfMeasurement == .nominal {
            let rm: FPT
            do {
                rm = try self.largestColumTotal()
            }
            catch {
                throw error
            }
            var sum: FPT = 0
            for c in 0..<self.columnCount {
                sum += self.largestCellCount(atColumn: c)
            }
            return (sum - rm) / (self.total - rm)
        }
        else {
            return FPT.nan
        }
    }
    
    
    /// Returns the Odds Ratio
    /// - Preconditions: Only applicable to a 2x2 table
    public var r0: FPT {
        get {
            if self.is2x2Table {
                let n11: FPT =  Helpers.makeFP(self[0,0])
                let n12: FPT =  Helpers.makeFP(self[0,1])
                let n21: FPT =  Helpers.makeFP(self[1,0])
                let n22: FPT =  Helpers.makeFP(self[1,1])
                if !n11.isNaN && !n12.isNaN && !n21.isNaN && !n21.isNaN {
                    return (n11 * n22) / (n12 * n21)
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                return FPT.nan
            }
        }
    }
    
    
    /// Returns the relative risk in a cohort study for column 1
    /// - Precondition: Only applicable to a 2x2 table
    public var r1: FPT {
        get {
            if self.is2x2Table {
                var ex1: FPT
                var ex2: FPT
                var ex3: FPT
                var ex4: FPT
                let n11: FPT =  Helpers.makeFP(self[0,0])
                let n12: FPT =  Helpers.makeFP(self[0,1])
                let n21: FPT =  Helpers.makeFP(self[1,0])
                let n22: FPT =  Helpers.makeFP(self[1,1])
                if !n11.isNaN && !n12.isNaN && !n21.isNaN && !n21.isNaN {
                    ex1 = n21 + n22
                    ex2 = n11 * ex1
                    ex3 = n11 + n12
                    ex4 = n21 * ex3
                    return ex2 / ex4
                }
                else {
                    fatalError("The object is in an inconsistent state. Please try to reconstruct the process and open an issue on GitHub.")
                }
            }
            else {
                return FPT.nan
            }
        }
    }
}

