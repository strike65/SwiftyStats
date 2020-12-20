//
//  SSDataFrame.swift
//  SwiftyStats


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


/// Defines a structure holding multiple SSExamine objects:
/// Each column contains an SSExamine object.
///
/// Each COL represents a single SSExamine object. The structure of the dataframe is like a two-dimensional table:
///
/// With N = sampleSize:
///
///     <          COL[0]      COL[1]     ...  COL[columns - 1] >
///     tags       tags[0]     tags[1]    ...  tags[columns - 1]
///     cnames     cnames[0    cnames[1]  ...  cnames[columns - 1]
///     ROW0       data[0][0]  data[0][1] ...  data[0][columns - 1]
///     ROW1       data[1][0]  data[1][1] ...  data[1][columns - 1]
///     ...        ..........  .......... ...  ....................
///     ROWN       data[N][0]  data[N][1] ...  data[N][columns - 1]
///
public class SSDataFrame<SSElement, FPT: SSFloatingPoint>: NSObject, NSCopying, Codable, NSMutableCopying, SSDataFrameContainer where SSElement: Comparable, SSElement: Hashable, SSElement: Codable, FPT: Codable {
    
//    public typealias Examine = SSExamine<SSElement, Double>
    
    // coding keys
    private enum CodingKeys: String, CodingKey {
        case data = "ExamineArray"
        case tags
        case cnames
        case nrows
        case ncolumns
    }
    
    /// Required func to conform to Codable protocol
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.data, forKey: .data)
        try container.encodeIfPresent(self.tags, forKey: .tags)
        try container.encodeIfPresent(self.cNames, forKey: .cnames)
        try container.encodeIfPresent(self.rows, forKey: .nrows)
        try container.encodeIfPresent(self.cols, forKey: .ncolumns)
    }
    
    /// Required func to conform to Codable protocol
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let d = try container.decodeIfPresent(Array<SSExamine<SSElement, FPT>>.self, forKey: .data) {
            self.data = d
        }
        if let t = try container.decodeIfPresent(Array<String>.self, forKey: .tags) {
            self.tags = t
        }
        if let n = try container.decodeIfPresent(Array<String>.self, forKey: .cnames) {
            self.cNames = n
        }
        if let r = try container.decodeIfPresent(Int.self, forKey: .nrows) {
            self.rows = r
        }
        if let c = try container.decodeIfPresent(Int.self, forKey: .ncolumns) {
            self.cols = c
        }
        
    }
    #if os(macOS) || os(iOS)
//    @available(macOS 10.12, iOS 10, *)
    /// Saves the dataframe to filePath using JSONEncoder
    /// - Parameter path: The full qualified filename.
    /// - Parameter overwrite: If true, file will be overwritten.
    /// - Throws: SSSwiftyStatsError.posixError (file can't be removed), SSSwiftyStatsError.directoryDoesNotExist, SSSwiftyStatsError.fileNotReadable
    public func archiveTo(filePath path: String!, overwrite: Bool!) throws -> Bool {
        let fm: FileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        let dir: String = NSString(string: fullFilename).deletingLastPathComponent
        var isDir = ObjCBool(false)
        if !fm.fileExists(atPath: dir, isDirectory: &isDir) {
            if !isDir.boolValue || path.count == 0 {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("No writeable path found", log: .log_fs ,type: .error)
                }
                #endif
                throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
            }
            #if os(macOS) || os(iOS)

            if #available(macOS 10.12, iOS 13, *) {
            os_log("File doesn't exist", log: .log_fs ,type: .error)
            }
            #endif
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        if fm.fileExists(atPath: fullFilename) {
            if overwrite {
                if fm.isWritableFile(atPath: fullFilename) {
                    do {
                        try fm.removeItem(atPath: fullFilename)
                    }
                    catch {
                        #if os(macOS) || os(iOS)
                        if #available(macOS 10.12, iOS 13, *) {
                            os_log("Unable to remove file prior to saving new file: %@", log: .log_fs ,type: .error, error.localizedDescription)
                        }
                        #endif
                        throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                    }
                }
                else {
                    #if os(macOS) || os(iOS)
                    if #available(macOS 10.12, iOS 13, *) {
                        os_log("Unable to remove file prior to saving new file", log: .log_fs ,type: .error)
                    }
                    #endif
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            }
            else {
                #if os(macOS) || os(iOS)
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("File exists: %@", log: .log_fs ,type: .error, fullFilename)
                }
                #endif
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            }
        }
        let jsonEncode = JSONEncoder()
        let d = try jsonEncode.encode(self)
        do {
            try d.write(to: URL.init(fileURLWithPath: fullFilename), options: Data.WritingOptions.atomic)
            return true
        }
        catch {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unable to write data", log: .log_fs, type: .error)
            }
            #endif
            return false
        }
    }

//    @available(macOS 10.10, iOS 10, *)
    /// Initializes a new dataframe from an archive saved by archiveTo(filePath path:overwrite:).
    /// - Parameter path: The full qualified filename.
    /// - Throws: SSSwiftyStatError.fileNotReadable
    public class func unarchiveFrom(filePath path: String!) throws -> SSDataFrame<SSElement, FPT>? {
        let fm: FileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fm.isReadableFile(atPath: fullFilename) {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("File not readable", log: .log_fs ,type: .error)
            }
            #endif
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        do {
            let data: Data = try Data.init(contentsOf: URL.init(fileURLWithPath: fullFilename))
            let jsonDecoder = JSONDecoder()
            let result = try jsonDecoder.decode(SSDataFrame<SSElement, FPT>.self, from: data)
            return result
        }
        catch {
            #if os(macOS) || os(iOS)
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Failure", log: .log_fs ,type: .error)
            }
            #endif
            return nil
        }
    }
    #endif
    
    
    private var data:Array<SSExamine<SSElement, FPT>> = Array<SSExamine<SSElement, FPT>>()
    private var tags: Array<String> = Array<String>()
    private var cNames: Array<String> = Array<String>()
    private var rows: Int = 0
    private var cols: Int = 0
    
    /// Array containing all SSExamine objects
    public var examines: Array<SSExamine<SSElement, FPT>> {
        get {
            return data
        }
    }
    
    /// Number of rows per column (= sample size)
    public var sampleSize: Int {
        get {
            return rows
        }
    }
    
    /// Returns true if the receiver is equal to `object`.
    public override func isEqual(_ object: Any?) -> Bool {
        var result: Bool = true
        if let df: SSDataFrame<SSElement, FPT> = object as? SSDataFrame<SSElement, FPT> {
            if self.columns == df.columns && self.rows == df.rows {
                for k in 0..<self.columns {
                    result = result && self[k].isEqual(df[k])
                }
                return result
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    /// Number of samples (Same as `columns`)
    public var countOfSamples: Int {
        get {
            return cols
        }
    }
    
    /// Number of samples (Same as `countOfSamples`)
    public var columns: Int {
        get {
            return cols
        }
    }
    
    /// Returns true, if the receiver is empty (i.e. there are no data)
    public var isEmpty: Bool {
        get {
            return rows == 0 && cols == 0
        }
    }
    
    
    /// Initializes a new instance and returns that instance in a fully initialized state
    /// - Parameter examineArray: An Array of SSEXamine objects
    /// - Throws: SSSwiftyStatsError
    init(examineArray: Array<SSExamine<SSElement, FPT>>!) throws {
        let tempSampleSize = examineArray.first!.sampleSize
        data = Array<SSExamine<SSElement, FPT>>.init()
        tags = Array<String>()
        cNames = Array<String>()
        var i: Int = 0
        for a in examineArray {
            if a.sampleSize != tempSampleSize {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("Sample sizes are expected to be equal", log: .log_stat, type: .error)
                }
                
                #endif
                
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
                tags.append("NA")
            }
            if let n = a.name {
                if let _ = cNames.firstIndex(of: n) {
                    var k: Int = 1
                    var tempSampleString = n + "_" + String(format: "%02d", arguments: [k as CVarArg])
                    while (cNames.firstIndex(of: tempSampleString) != nil) {
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
        super.init()
    }
    
    /// Required initializer
    override public init() {
        cNames = Array<String>()
        tags = Array<String>()
        data = Array<SSExamine<SSElement, FPT>>()
        rows = 0
        cols = 0
        super.init()
    }
    
    /// Appends a column
    /// - Parameter examine: The SSExamine object
    /// - Parameter name: Name of column
    /// - Throws: SSSwiftyStatsError examine.sampleSize != self.rows
    public func append(_ examine: SSExamine<SSElement, FPT>, name: String?) throws {
        if examine.sampleSize != self.rows {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Sample sizes are expected to be equal", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError.init(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        self.data.append(examine)
        if let t = examine.tag {
            self.tags.append(t)
        }
        else {
            self.tags.append("NA")
        }
        if let n = examine.name {
            self.cNames.append(n)
        }
        else {
            cNames.append(String(format: "%03d", arguments: [(self.cols + 1) as CVarArg] ))
        }
        cols += 1
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
    public func remove(name: String!) -> SSExamine<SSElement, FPT>? {
        if cols > 0 {
            if let i = cNames.firstIndex(of: name) {
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
    
    
    private func isValidColumnIndex(_ index: Int) -> Bool {
        return (index >= 0 && index < self.columns) ? true : false
    }
    
    private func isValidRowIndex(_ index: Int) -> Bool {
        return (index >= 0 && index < self.rows) ? true : false
    }
    
    private func indexOf(columnName: String!) -> Int? {
        if let i = cNames.firstIndex(of: columnName) {
            return i
        }
        else {
            return nil
        }
    }
    
    /// Returns the row at a given index
    public func row(at index: Int) -> Array<SSElement> {
        if isValidRowIndex(index) {
            var res = Array<SSElement>()
            for c in self.data {
                if let e = c[index] {
                    res.append(e)
                }
                else {
                    fatalError("Index out of range")
                }
            }
            return res
        }
        else {
            fatalError("Row-Index out of row.")
        }
    }
    
    /// Accesses the column at a given index
    public subscript(_ idx: Int) -> SSExamine<SSElement, FPT> {
        if isValidColumnIndex(idx) {
            return data[idx]
        }
        else {
            fatalError("Index out of range")
        }
    }
    
    /// Accesses the column named `name`
    public subscript(_ name: String) -> SSExamine<SSElement, FPT> {
        if let i = cNames.firstIndex(of: name) {
            return data[i]
        }
        else {
            fatalError("Index out of range")
        }
    }
    
    /// Returns a new instance that’s a copy of the receiver.
    ///
    /// The returned object is implicitly retained by the sender, who is responsible for releasing it. The copy returned is immutable if the consideration “immutable vs. mutable” applies to the receiving object; otherwise the exact nature of the copy is determined by the class.
    /// - Parameters:
    ///     - zone: This parameter is ignored. Memory zones are no longer used by Objective-C.
    public func copy(with zone: NSZone? = nil) -> Any {
        do {
            let res = try SSDataFrame<SSElement, FPT>.init(examineArray: self.data)
            res.tags = self.tags
            res.cNames = self.cNames
            return res
        }
        catch {
            fatalError("Copy failed")
        }
    }

    /// Returns a new instance that’s a mutable copy of the receiver.
    ///
    /// The returned object is implicitly retained by the sender, who is responsible for releasing it. The copy returned is immutable if the consideration “immutable vs. mutable” applies to the receiving object; otherwise the exact nature of the copy is determined by the class. In fact, that functions does the same as `copy(with:)`
    /// - Parameters:
    ///     - zone: This parameter is ignored. Memory zones are no longer used by Objective-C.
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        return self.copy(with: zone)
    }

    /// Returns the object returned by `mutableCopy(with:)` where the `zone` is nil.
    ///
    /// This is a convenience method for classes that adopt the NSMutableCopying protocol. An exception is raised if there is no implementation for `mutableCopy(with:)`.
    public override func mutableCopy() -> Any {
        return self.copy(with: nil)
    }
    
    /// Returns the object returned by `copy(with:) where the `zone` is nil.
    ///
    /// This is a convenience method for classes that adopt the NSCopying protocol. An exception is raised if there is no implementation for copy(with:). NSObject does not itself support the NSCopying protocol. Subclasses must support the protocol and implement the copy(with:) method. A subclass version of the copy(with:) method should send the message to super first, to incorporate its implementation, unless the subclass descends directly from NSObject.
    public override func copy() -> Any {
        return copy(with: nil)
    }
    
    /// Exports the dataframe as csv
    /// - Parameter path: The full path
    /// - Parameter atomically: Write atomically
    /// - Parameter firstRowAsColumnName: If true, the row name is equal to the exported SSExamine object. If this object hasn't a name, an auto incremented integer is used.
    /// - Parameter useQuotes: If true all fields will be enclosed by quotation marks
    /// - Parameter overwrite: If true an existing file will be overwritten
    /// - Parameter stringEncoding: Encoding
    /// - Returns: True if the file was successfully written.
    /// - Throws: SSSwiftyStatsError
    public func exportCSV(path: String!, separator sep: String = ",", useQuotes: Bool = false, firstRowAsColumnName cn: Bool = true, overwrite: Bool = false, stringEncoding enc: String.Encoding = String.Encoding.utf8, atomically: Bool = true) throws -> Bool {
        if !self.isEmpty {
            var string = String()
            if cn {
                for c in 0..<cols {
                    if useQuotes {
                        string = string + "\"" + cNames[c] + "\"" + sep
                    }
                    else {
                        string = string + cNames[c] + sep
                    }
                }
                string = String.init(string.dropLast())
                string += "\n"
            }
            for r in 0..<self.rows {
                for c in 0..<self.cols {
                    if useQuotes {
                        string = string + "\"" + "\(String(describing: self.data[c][r]!))" + "\"" + sep
                    }
                    else {
                        string = string + "\(String(describing: self.data[c][r]!))" + sep
                    }
                }
                string = String.init(string.dropLast())
                string += "\n"
            }
            string = String.init(string.dropLast())
            let fileManager = FileManager.default
            let fullName = NSString(string: path).expandingTildeInPath
            if fileManager.fileExists(atPath: fullName) {
                if !overwrite {
                    #if os(macOS) || os(iOS)
                    
                    if #available(macOS 10.12, iOS 13, *) {
                        os_log("File already exists", log: .log_fs, type: .error)
                    }
                    
                    #endif
                    
                    throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
                }
                else {
                    do {
                        try fileManager.removeItem(atPath: fullName)
                    }
                    catch {
                        #if os(macOS) || os(iOS)
                        
                        if #available(macOS 10.12, iOS 13, *) {
                            os_log("Can't remove file", log: .log_fs, type: .error)
                        }
                        
                        #endif
                        
                        throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                    }
                }
            }
            var result: Bool
            do {
                try string.write(toFile: fullName, atomically: atomically, encoding: enc)
                result = true
            }
            catch {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("File could not be written", log: .log_fs, type: .error)
                }
                
                #endif
                
                result = false
            }
            return result
        }
        else {
            return false
        }
    }
    
    /// Initializes a new DataFrame instance.
    /// - Parameter fromString: A string of objects (mostly numbers) separated by `separator`
    /// - Parameter separator: The separator (delimiter) used. Default = ","
    /// - Parameter firstRowContainsNames: Indicates, that the first line contains Column Identifiers.
    /// - Parameter parser: A function to convert a string to the expected generic type
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed
    ///
    /// The following example creates a DataFrame object with 4 columns:
    ///
    ///     let dataString = "Group 1,Group 2,Group 3,Group 4\n6.9,8.3,8.0,5.8\n5.4,6.8,10.5,3.8\n5.8,7.8,8.1,6.1\n4.6,9.2,6.9,5.6\n4.0,6.5,9.3,6.2"
    ///     var df: SSDataFrame<Double, Double>
    ///     do {
    ///         df = try SSDataFrame.dataFrame(fromString: TukeyKramerData_01String, parser: scanDouble)
    ///     }
    ///     catch {
    ///         ...
    ///     }
    public class func dataFrame(fromString: String!, separator sep: String! = ",", firstRowContainsNames cn: Bool = true, parser: (String) -> SSElement?) throws -> SSDataFrame<SSElement, FPT> {
        do {
            var importedString = fromString
            
            if let lastScalar = importedString?.unicodeScalars.last {
                if CharacterSet.newlines.contains(lastScalar) {
                    importedString = String(importedString!.dropLast())
                }
            }
            let lines: Array<String> = importedString!.components(separatedBy: CharacterSet.newlines)
            var cnames: Array<String> = Array<String>()
            var cols: Array<String>
            var curString: String
            var columns: Array<Array<SSElement>> = Array<Array<SSElement>>()
            var k: Int = 0
            var startRow: Int
            if cn {
                startRow = 1
            }
            else {
                startRow = 0
            }
            for r in startRow..<lines.count {
                cols = lines[r].components(separatedBy: sep)
                if columns.count == 0 && cols.count > 0 {
                    for _ in 1...cols.count {
                        columns.append(Array<SSElement>())
                    }
                }
                for c in 0..<cols.count {
                    curString = cols[c].replacingOccurrences(of: "\"", with: "")
                    if let d = parser(curString) {
                        columns[c].append(d)
                    }
                    else {
                        #if os(macOS) || os(iOS)
                        
                        if #available(macOS 10.12, iOS 13, *) {
                            os_log("Error during processing data file", log: .log_fs, type: .error)
                        }
                        
                        #endif
                        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
                    }
                }
            }
            if cn {
                let names = lines[0].components(separatedBy: sep)
                for name in names {
                    curString = name.replacingOccurrences(of: "\"", with: "")
                    cnames.append(curString)
                }
            }
            var examineArray: Array<SSExamine<SSElement, FPT>> = Array<SSExamine<SSElement, FPT>>()
            for k in 0..<columns.count {
                examineArray.append(SSExamine<SSElement, FPT>.init(withArray: columns[k], name: nil, characterSet: nil))
            }
            if cn {
                k = 0
                for e in examineArray {
                    e.name = cnames[k]
                    k += 1
                }
            }
            return try SSDataFrame<SSElement, FPT>.init(examineArray: examineArray)
        }
        catch {
            return SSDataFrame<SSElement, FPT>()
        }
    }
    
    /// Loads the content of a file using the specified encoding.
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter separator: The separator used in the file
    /// - Parameter firstRowContainsNames: Indicates, that the first line contains Column Identifiers.
    /// - Parameter stringEncoding: The encoding to use.
    /// - Parameter parser: A function to convert a string to the expected generic type
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed
    public class func dataFrame(fromFile path: String!, separator sep: String! = ",", firstRowContainsNames cn: Bool = true, stringEncoding: String.Encoding! = String.Encoding.utf8, _ parser: (String) -> SSElement?) throws -> SSDataFrame<SSElement, FPT> {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("File not found", log: .log_fs, type: .error)
            }
            
            #endif
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        do {
            var importedString = try String.init(contentsOfFile: fullFilename, encoding: stringEncoding)
            if let lastScalar = importedString.unicodeScalars.last {
                if CharacterSet.newlines.contains(lastScalar) {
                    importedString = String(importedString.dropLast())
                }
            }
            let lines: Array<String> = importedString.components(separatedBy: CharacterSet.newlines)
            var cnames: Array<String> = Array<String>()
            var cols: Array<String>
            var curString: String
            var columns: Array<Array<SSElement>> = Array<Array<SSElement>>()
            var k: Int = 0
            var startRow: Int
            if cn {
                startRow = 1
            }
            else {
                startRow = 0
            }
            for r in startRow..<lines.count {
                cols = lines[r].components(separatedBy: sep)
                if columns.count == 0 && cols.count > 0 {
                    for _ in 1...cols.count {
                        columns.append(Array<SSElement>())
                    }
                }
                for c in 0..<cols.count {
                    curString = cols[c].replacingOccurrences(of: "\"", with: "")
                    if let d = parser(curString) {
                        columns[c].append(d)
                    }
                    else {
                        #if os(macOS) || os(iOS)
                        
                        if #available(macOS 10.12, iOS 13, *) {
                            os_log("Error during processing data file", log: .log_fs, type: .error)
                        }
                        
                        #endif
                        
                        throw SSSwiftyStatsError.init(type: .functionNotDefinedInDomainProvided, file: #file, line: #line, function: #function)
                    }
                }
            }
            if cn {
                let names = lines[0].components(separatedBy: sep)
                for name in names {
                    curString = name.replacingOccurrences(of: "\"", with: "")
                    cnames.append(curString)
                }
            }
            var examineArray: Array<SSExamine<SSElement, FPT>> = Array<SSExamine<SSElement, FPT>>()
            for k in 0..<columns.count {
                examineArray.append(SSExamine<SSElement, FPT>.init(withArray: columns[k], name: nil, characterSet: nil))
            }
            if cn {
                k = 0
                for e in examineArray {
                    e.name = cnames[k]
                    k += 1
                }
            }
            return try SSDataFrame<SSElement, FPT>.init(examineArray: examineArray)
        }
        catch {
            throw error
        }
    }
    
    
}
