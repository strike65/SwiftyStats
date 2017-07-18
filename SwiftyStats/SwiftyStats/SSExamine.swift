//
//  SSExamine.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 01.07.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//
/*
 MIT License
 
 Copyright (c) 2017 Volker Thieme
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import os.log
/// SSExamine
/// This class offers the possibility to store, manipulate and analyze data of any type. The only prerequisite is that the data meet the protocols "Hashable" and "Comparable".
/// The available statistics depend on whether the data are numeric or non-numeric. If statistics are requested that are not available for the data type being used, Double.nan or nil is returned. Some methods throws an error in such circumstances.
public class SSExamine<SSElement>:  NSObject, SSExamineContainer, NSCopying, NSCoding where SSElement: Hashable, SSElement: Comparable {
   
    // MARK: OPEN/PUBLIC VARS
    
    /// User defined tag to identify the instance
    public var tag: Any?

    /// Human readable description
    public var descriptionString: String?
    
    /// Name of the table
    public var name: String?
    
    /// Significance level to use, default: 0.05
    public var alpha: Double! = 0.05
    
    /// Indicates if there are changes
    public var hasChanges: Bool! = false
    
    /// Defines the level of measurement
    public var levelOfMeasurement: SSLevelOfMeasurement! = .interval
    
    /// If true, the instance contains numerical data
    public var numeric: Bool! = true
    
    /// Returns the count of SSElements
    public var length: Int {
        return items.count
    }
    
    /// Returns true, if count == 0
    public var isEmpty: Bool {
        return count == 0
    }

    /// The total number pf observations (= sum of all absolute frequencies)
    public var sampleSize: Int {
        return count
    }
    
    /// Returns a Dictionary<element : cumulative frequency >
    public var cumulativeRelativeFrequencies: Dictionary<SSElement, Double> {
        return cumRelFrequencies
    }
    
    /// Returns the hash value
    public override var hashValue: Int {
        var temp: Int
        if !isEmpty {
            var a = elementsAsArray(sortOrder: .original)!
            temp = (a[a.startIndex].hashValue)
            for item in a {
                temp = temp ^ item.hashValue
            }
            return temp
        }
        else {
            return 0
        }
    }
    
    /// Two SSExamine objects are supposed to be equal, iff the item arrays are equal.
    /// - Paramater object: The object to compare to
    public override func isEqual(_ object: Any?) -> Bool {
        if let o: SSExamine<SSElement> = object as? SSExamine<SSElement> {
            if !self.isEmpty && !o.isEmpty {
                let a1 = self.elementsAsArray(sortOrder: .original)!
                let a2 = o.elementsAsArray(sortOrder: .original)!
                return a1 == a2
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }


    /// Returns all unique elements as a Dictionary
    /// key: item
    /// value: absolute frequency
    public var elements: Dictionary<SSElement, Int> {
        return items
    }
    
    /// Returns a dictionary containing an array for each element. The array contains the order in which the elements were appended.
    public var sequences: Dictionary<SSElement, Array<Int>> {
        return sequence
    }
    
    
    // MARK: PRIVATE VARS
    
    private var sequence: Dictionary<SSElement, Array<Int>> = [:]
    private var items: Dictionary<SSElement, Int> = [:]
    private var relFrequencies: Dictionary<SSElement, Double> = [:]
    private var cumRelFrequencies: Dictionary<SSElement, Double> = [:]
    private var allItemsAscending: Array<SSElement> = []
    
    // sum over all absolute frequencies (= sampleSize)
    private var count: Int = 0
    
    // MARK: INITIALIZERS
    
    /// General initializer.
    public override init() {
        super.init()
        initializeSSExamine()
    }

    /// Initializes a SSExamine instance using a string or an array<SSElement>
    /// Throws an error, if object is not a string or an array<SSElement>
    /// - Parameter object: The object used
    /// - Parameter characterSet: Set containing all characters to include by string analysis
    /// - Throws: SSSwiftyStatsError.missingData
    public init(withObject object: Any!, levelOfMeasurement lom: SSLevelOfMeasurement! ,characterSet: CharacterSet?) throws {
        // allow only arrays an strings as 'object'
        guard ((object is String && object is SSElement) || (object is Array<SSElement>)) else {
            os_log("Error creating SSExamine instance", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .missingData, file: #file, line: #line, function: #function)
        }
        super.init()
        self.levelOfMeasurement = lom
        if object is String  {
            self.levelOfMeasurement = .nominal
            self.initializeWithString(string: object as! String, characterSet: characterSet)
        }
        else if object is Array<SSElement> {
            self.initializeWithArray(array: object as! Array<SSElement>)
        }
    }
    
    /// Returns: New table by analyzing string. Taking characterSet into account, when set
    /// - Parameter array: The array containing the elements
    /// - Parameter characterSet: Set containing all characters to include by string analysis. Ignored, if elements are numeric.
    public init(withArray array: Array<SSElement>!, characterSet: CharacterSet?) {
        super.init()
        self.initializeWithArray(array: array)
    }

    
    /// Loads the content of a file interpreting the elements separated by separator as double values using the specified encoding.
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter separator: The separator used in the file
    /// - Parameter stringEncoding: The encoding to use.
    public class func examine(withContentsOfFile path: String!, separator: String!, stringEncoding: String.Encoding!) throws -> SSExamine<Double>? {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            os_log("File not found", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        var doubleScanner: Scanner
        var numberArray: Array<Double> = Array<Double>()
        var dbl: Double = 0.0
        var go: Bool = true
        do {
            let importedString = try String.init(contentsOfFile: fullFilename, encoding: stringEncoding)
            if importedString.contains(separator) {
                if importedString.characters.count > 0 {
                    let separatedStrings: Array<String> = importedString.components(separatedBy: separator)
                    for number in separatedStrings {
                        if number.characters.count > 0 {
                            doubleScanner = Scanner(string: number)
                            if doubleScanner.scanDouble(&dbl) {
                                numberArray.append(dbl)
                            }
                            else {
                                go = false
                                break
                            }
                        }
                    }
                }
            }
            else {
                return nil
            }
        }
        catch {
            return nil
        }
        if go {
            return SSExamine<Double>.init(withArray: numberArray, characterSet: nil)
        }
        else {
            return nil
        }
    }
    
    /// Saves the object to the given path using the specified encoding.
    /// - Parameter path: Path to the file
    /// - Parameter atomically: If true, the object will be written to a temporary file first. This file will be renamed upon completion.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Parameter separator: Separator to use.
    /// - Parameter stringEncoding: String encoding
    /// - Throws: An error will be thrown if the file could not be written.
    public func saveTo(fileName path: String!, atomically: Bool!, overwrite: Bool!, separator: String!, stringEncoding: String.Encoding) throws -> Bool {
        var result = true
        let fileManager = FileManager.default
        let fullName = NSString(string: path).expandingTildeInPath
        if fileManager.fileExists(atPath: fullName) {
            if !overwrite {
                os_log("File already exists", log: log_stat, type: .error)
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            }
            else {
                do {
                    try fileManager.removeItem(atPath: fullName)
                }
                catch {
                    os_log("Can't remove file", log: log_stat, type: .error)
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            }
        }
        if let s = elementsAsString(withDelimiter: separator) {
            do {
                try s.write(toFile: fullName, atomically: atomically, encoding: stringEncoding)
            }
            catch {
                os_log("File could not be written", log: log_stat, type: .error)
                result = false
            }
        }
        return result
    }
    
    /// Returns a SSExamine instance initialized using the string provided. Level of measurement will be set to .nominal.
    /// - Parameter string: String
    /// - Parameter characterSet: If characterSet is not nil, only characters contained in the set will be appended
    public class func examineWithString(_ string: String!, characterSet: CharacterSet?) -> SSExamine<String>? {
        do {
            let result:SSExamine<String> = try SSExamine<String>(withObject: string, levelOfMeasurement: .nominal, characterSet: characterSet)
            return result
        }
        catch {
            os_log("Error creating SSExamine instance", log: log_stat, type: .error)
            return nil
        }
    }
    
    
    
    /// Initialize the table using a string. Append only characters contained in characterSet
    /// - Parameter string: String
    /// - Parameter characterSet: If characterSet is not nil, only characters contained in the set will be appended
    private func initializeWithString(string: String, characterSet: CharacterSet?) {
        initializeSSExamine()
        numeric = false
        var index: String.Index = string.startIndex
        var offset: String.IndexDistance = 0
        if index < string.endIndex {
            if let cs: CharacterSet = characterSet {
                for scalar in string.unicodeScalars {
                    if cs.contains(scalar) {
                        append(String(string[index]) as! SSElement)
                    }
                    offset = offset.advanced(by: 1)
                    index = string.index(string.startIndex, offsetBy: offset)
                }
            }
            else {
                for c: Character in string.characters {
                    append(String(c) as! SSElement)
                }
            }
        }
   }
    
    
    /// Initializes a new instance using an array
    /// - Parameter array: The array containing the elements
    private func initializeWithArray(array: Array<SSElement>!) {
        initializeSSExamine()
        if array.count > 0 {
            if isNumeric(array[0]) {
                numeric = true
            }
            else {
                numeric = false
            }
            for item in array {
                append(item)
            }
        }
    }

    
    /// Sets default values
    fileprivate func initializeSSExamine() {
        sequence.removeAll()
        items.removeAll()
        relFrequencies.removeAll()
        cumRelFrequencies.removeAll()
        count = 0
        descriptionString = "SSExamine Instance - standard"
        alpha = 0.05
        hasChanges = false
        numeric = true
    }
    
    
    // MARK: NSCoding protocol
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.sampleSize, forKey: "count")
        aCoder.encode(tag, forKey: "tag")
        aCoder.encode(descriptionString?.data(using: String.Encoding.unicode), forKey: "descriptionString")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(alpha, forKey:"alpha")
        aCoder.encode(levelOfMeasurement.rawValue, forKey: "levelOfMeasurement")
        aCoder.encode(relFrequencies, forKey: "relFrequencies")
        aCoder.encode(sequence, forKey: "sequence")
        aCoder.encode(items, forKey: "items")
        aCoder.encode(cumRelFrequencies, forKey: "cumRelFrequencies")
        aCoder.encode(numeric, forKey: "numeric")
        aCoder.encode(hasChanges, forKey: "hasChanges")
        aCoder.encode(SSStatisticsFileVersionString, forKey: "fileVersionString")
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        count = aDecoder.decodeInteger(forKey: "count")
        relFrequencies = aDecoder.decodeObject(forKey: "relFrequencies") as! Dictionary<SSElement, Double>
        cumRelFrequencies = aDecoder.decodeObject(forKey: "cumRelFrequencies") as! Dictionary<SSElement, Double>
        sequence = aDecoder.decodeObject(forKey: "sequence") as! Dictionary<SSElement, Array<Int>>
        items = aDecoder.decodeObject(forKey: "items") as! Dictionary<SSElement, Int>
        tag = aDecoder.decodeObject(forKey: "tag")
        name = aDecoder.decodeObject(forKey: "name") as? String
        descriptionString = aDecoder.decodeObject(forKey: "descriptionString") as? String
        alpha = aDecoder.decodeObject(forKey: "alpha") as! Double
        numeric = aDecoder.decodeObject(forKey: "numeric") as! Bool
        hasChanges = aDecoder.decodeObject(forKey: "hasChanges") as! Bool
        levelOfMeasurement = SSLevelOfMeasurement(rawValue: aDecoder.decodeInteger(forKey: "levelOfMeasurement"))
    }
    
    // MARK: NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let res: SSExamine = SSExamine()
        if !isEmpty {
            res.tag = self.tag
            res.descriptionString = self.descriptionString
            res.name = self.name
            res.alpha = self.alpha
            res.levelOfMeasurement = self.levelOfMeasurement
            res.hasChanges = self.hasChanges
            let a: Array<SSElement> = elementsAsArray(sortOrder: .original)!
            for item in a {
                res.append(item)
            }
        }
        return res
    }
    
    /// Updates cumulative frequencies
    private func updateCumulativeFrequencies() {
        
        // 1. Alle Werte nach Größe sortieren
        // 2. crf(n) = crf(n-1) + rf(n)
        if !isEmpty {
            var temp = self.uniqueElements(sortOrder: .ascending)!
            var i: Int = 0
            cumRelFrequencies.removeAll()
            for key in temp {
                if i == 0 {
                    cumRelFrequencies[key] = relFrequencies[key]
                }
                else {
                    cumRelFrequencies[key] = cumRelFrequencies[temp[i - 1]]! + relFrequencies[key]!
                }
                i = i + 1
            }
            allItemsAscending = self.uniqueElements(sortOrder: .ascending)!
        }
    }
    
    // MARK: SSExamineContainer Protocol
    
    /// Returns true, if the table contains the item
    /// - Parameter item: Item to search
    public func contains(item: SSElement) -> Bool {
        if !isEmpty {
            let test = items.contains(where: { (key: SSElement, value: Int) in
                if key == item {
                    return true
                }
                else {
                    return false
                }
            })
            return test
        }
        else {
            return false
        }
    }
    
    
    /// Returns the relative Frequency of item
    /// - Parameter item: Item
    public func relativeFrequency(item: SSElement) -> Double {
        if contains(item: item) {
            return relFrequencies[item]!
        }
        else {
            return 0.0
        }
    }
    
    /// Returns the absolute frequency of item
    /// - Parameter item: Item
    public func frequency(item: SSElement) -> Int {
        if contains(item: item) {
            return items[item]!
        }
        else {
            return 0
        }
    }
    
    /// Appends <item> and updates frequencies
    /// - Parameter item: Item
    public func append(_ item: SSElement!) {
        var tempPos: Array<Int>
        count = count + 1
        let test = items.contains(where: { (key: SSElement, value: Int) in
            if key == item {
                return true
            }
            else {
                return false
            }
        })
        var currentFrequency: Int
        if test {
            currentFrequency = items[item]!
            items.removeValue(forKey: item)
            relFrequencies.removeValue(forKey: item)
            items[item] = currentFrequency + 1
            // update relative frequencies
            for key in items.keys {
                relFrequencies[key] = Double(items[key]!) / Double(self.sampleSize)
            }
            sequence[item]!.append(count)
        }
        else {
            items[item] = 1
            relFrequencies[item] = 1.0 / Double(self.sampleSize)
            tempPos = Array()
            tempPos.append(count)
            sequence[item] = tempPos
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends n elements
    /// - Paramater n: Count of elements to add
    /// - Parameter item: Item to append
    public func append(repeating n: Int!, item: SSElement!) {
        for _ in 1...n {
            append(item)
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends elements from an array
    /// - Parameter array: Array containing elements to add
    public func append(fromArray array: Array<SSElement>!) {
        if array.count > 0 {
            if isEmpty {
                numeric = isNumeric(array[array.startIndex])
            }
            for item in array {
                append(item)
            }
        }
//        updateCumulativeFrequencies()
    }
    
    /// Appends the characters of the given string. Only characters contained in the character set are appended.
    /// - Parameter text: The text
    /// - Parameter characterSet: A CharacterSet containing the characters to include
    public func append(text: String!, characterSet: CharacterSet?) throws {
        if !(SSElement.self is String.Type) {
            os_log("Can only append strings", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        else {
            var index: String.Index = text.startIndex
            var offset: String.IndexDistance = 0
            if index < text.endIndex {
                if let cs: CharacterSet = characterSet {
                    for scalar in text.unicodeScalars {
                        if cs.contains(scalar) {
                            append(String(text[index]) as! SSElement)
                        }
                        offset = offset.advanced(by: 1)
                        index = text.index(text.startIndex, offsetBy: offset)
                    }
                }
                else {
                    for c: Character in text.characters {
                        append(String(c) as! SSElement)
                    }
                }
            }
        }
    }
    
    /// Removes item from the table.
    /// - Parameter item: Item
    /// - Parameter allOccurences: If false, only the item first found will be removed.
    public func remove(_ item: SSElement!, allOccurences all: Bool!) {
        if !isEmpty {
            if contains(item: item) {
                var temp: Array<SSElement> = elementsAsArray(sortOrder: .original)!
                // remove all elements
                if all {
                    temp = temp.filter({ $0 != item})
                }
                else {
                    // remove only the first occurence
                    let s: Array<Int> = sequence[item]!
                    temp.remove(at:s.first! - 1)
                }
                items.removeAll()
                relFrequencies.removeAll()
                cumRelFrequencies.removeAll()
                sequence.removeAll()
                count = 0
                for i in temp {
                    append(i)
                }
            }
        }
    }
    
    /// Removes all elements leaving an empty table,
    public func removeAll() {
        count = 0
        items.removeAll()
        sequence.removeAll()
        relFrequencies.removeAll()
        cumRelFrequencies.removeAll()
        numeric = true
        hasChanges = true
    }
    


}

// MARK: Management
extension SSExamine {

    /// Saves the table to filePath using NSKeyedArchiver.
    /// - Parameter path: The full qualified filename.
    /// - Parameter overwrite: If yes an existing file will be overwritten.
    /// - Throws: SSSwiftyStatsError.posixError (file can'r be removed), SSSwiftyStatsError.directoryDoesNotExist, SSSwiftyStatsError.fileNotReadable
    public func archiveTo(filePath path: String!, overwrite: Bool!) throws -> Bool {
        var result: Bool = false
        let fm: FileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        let dir: String = NSString(string: fullFilename).deletingLastPathComponent
        var isDir = ObjCBool(false)
        if !fm.fileExists(atPath: dir, isDirectory: &isDir) {
            if !isDir.boolValue || path.characters.count == 0{
                os_log("No writeable path found", log: log_stat ,type: .error)
                throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
            }
            os_log("File doesn't exist", log: log_stat ,type: .error)
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        if fm.fileExists(atPath: fullFilename) {
            if overwrite {
                if fm.isWritableFile(atPath: fullFilename) {
                    do {
                        try fm.removeItem(atPath: fullFilename)
                    }
                    catch {
                        os_log("Unable to remove file prior to saving new file: %@", log: log_stat ,type: .error, error.localizedDescription)
                        throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                    }
                }
                else {
                    os_log("Unable to remove file prior to saving new file", log: log_stat ,type: .error)
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            }
            else {
                os_log("File exists: %@", log: log_stat ,type: .error, fullFilename)
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            }
        }
        result = NSKeyedArchiver.archiveRootObject(self, toFile: fullFilename)
        return result
    }
   
    /// Initializes a new table from an archive saved by archiveTo(filePath path:overwrite:).
    /// - Parameter path: The full qualified filename.
    /// - Throws: SSSwiftyStatError.fileNotReadable
    public class func unarchiveFrom(filePath path: String!) throws -> SSExamine<SSElement>? {
        let fm: FileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fm.isReadableFile(atPath: fullFilename) {
            os_log("File not readable", log: log_stat ,type: .error)
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        let result: SSExamine<SSElement>? = NSKeyedUnarchiver.unarchiveObject(withFile: fullFilename) as? SSExamine<SSElement>
        return result
    }
}

// MARK: Elements
extension SSExamine {
    
    /// Returns all elements as one string. Elements are delimited by del.
    /// Paramater del: The delimiter. Can be nil or empty.
    public func elementsAsString(withDelimiter del: String?) -> String? {
        let a: Array<SSElement> = elementsAsArray(sortOrder: .original)!
        var res: String = String()
        for item in a {
            res = res + "\(item)"
            if let _ = del {
                res = res + del!
            }
        }
        if let _ = del {
            if del!.characters.count > 0 {
                for _ in 1...del!.characters.count {
                    res = String(res.characters.dropLast())
                }
            }
        }
        if res.characters.count > 0 {
            return res
        }
        else {
            return nil
        }
    }
    
    /// Returns an array containing all elements.
    /// - Parameter sortOrder: The sort sortOrder.
    /// - Returns: An array containing all elements sortOrdered as specified.
    public func elementsAsArray(sortOrder: SSDataArraySortOrder) -> Array<SSElement>? {
        if !isEmpty {
            var temp: Array<SSElement> = Array<SSElement>()
            var result: Array<SSElement>
            switch sortOrder {
            case .ascending:
                for (item, freq) in self.elements {
                    for _ in 1...freq {
                       temp.append(item)
                    }
                }
                result = temp.sorted(by: {$0 < $1})
            case .descending:
                for (item, freq) in self.elements {
                    for _ in 1...freq {
                        temp.append(item)
                    }
                }
                result = temp.sorted(by: {$0 > $1})
            case .none:
                for (item, freq) in self.elements {
                    for _ in 1...freq {
                        temp.append(item)
                    }
                }
                result = temp
            case .original:
                for _ in 1...self.sampleSize {
                    temp.append(self.elements.keys[self.elements.keys.startIndex])
                }
                for (item, seq) in self.sequences {
                    for i in seq {
                        temp[i - 1] = item
                    }
                }
                result = temp
            }
            return result
        }
        else {
            return nil
        }
    }
    
    /// Returns an array containing all unique elements.
    /// - Paramater sortOrder: Sorting order
    public func uniqueElements(sortOrder: SSSortUniqeItems) -> Array<SSElement>? {
        var result: Array<SSElement>? = nil
        if !isEmpty {
            var temp: Array<SSElement> = Array<SSElement>()
            switch sortOrder {
            case .ascending:
                for (item, _) in self.elements {
                    temp.append(item)
                }
                result = temp.sorted(by: {$0 < $1})
            case .descending:
                for (item, _) in self.elements {
                    temp.append(item)
                }
                result = temp.sorted(by: {$0 > $1})
            case .none:
                for (item, _) in self.elements {
                    temp.append(item)
                }
                result = temp
            }
        }
        return result
    }
}


// MARK: Descriptive
extension SSExamine {
    
    /// Sum over all sqared elements. Returns Double.nan iff data are non-numeric.
    public var squareTotal: Double {
        if numeric && !isEmpty {
            var s: Double = 0.0
            for (item, freq) in self.elements {
                s = s + pow((item as! Double),2.0) * Double(freq)
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    /// Sum of all elements raised to power p
    /// - Parameter p: Power
    public func poweredTotal(power p: Double) -> Double {
        if numeric && !isEmpty {
            var s: Double = 0.0
            for (item, freq) in self.elements {
                s = s + pow((item as! Double), p) * Double(freq)
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    
    /// Total of all elements. Returns Double.nan iff data are non-numeric.
    public var total: Double {
        if numeric && !isEmpty {
            var s: Double = 0.0
            for (item, freq) in self.elements {
                s = s + (item as! Double) * Double(freq)
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    /// Returns the sum of all inversed elements
    public var inverseTotal: Double {
        if numeric && !isEmpty {
            var s = 0.0
            var temp: Double
            for (item, freq) in self.elements {
                temp = (item as! Double)
                if !temp.isZero {
                    s = s + (1.0 / temp) * Double(freq)
                }
                else {
                    return Double.infinity
                }
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    
    /// Arithemtic mean. Will be Double.nan for non-numeric data.
    public var arithmeticMean: Double {
        if numeric && !isEmpty {
            return total / Double(sampleSize)
        }
        else {
            return Double.nan
        }
    }
    
    /// Product of all elements. Will be Double.nan for non-numeric data.
    public var product: Double {
        if numeric && !isEmpty {
            var p: Double = 1.0
            for (item, freq) in self.elements {
                if (item as! Double).isZero {
                    return 0.0
                }
                else {
                    p = p * pow((item as! Double), Double(freq))
                }
            }
            return p
        }
        else {
            if isEmpty {
               return Double.nan
            }
            else {
                return 0.0
            }
        }
    }
    
    /// The log-Product. Will be Double.nan for non-numeric data or if there is at least one item lower than zerp. Returns +inf if there is at least one item equals to zero.
    public var logProduct: Double {
        var sp : Double = 0.0
        var temp: Double
        if numeric && !isEmpty {
            if isEmpty {
                return 0.0
            }
            else {
                for (item, freq) in self.elements {
                    temp = item as! Double
                    if temp > 0 {
                        sp = sp + log(temp) * Double(freq)
                    }
                    else if temp.isZero {
                        return Double.infinity * -1.0
                    }
                    else {
                        return Double.nan
                    }
                }
                return sp
            }
        }
        else {
            return Double.nan
        }
    }
    
    
    /// Returns the frequency table as an array, ordered as speciefied.
    /// - Parameter sortOrder: SSFrequencyTableSortsortOrder
    public func frequencyTable(sortOrder: SSFrequencyTableSortOrder) -> Array<SSFrequencyTableItem<SSElement>> {
        var result = Array<SSFrequencyTableItem<SSElement>>()
        var tableItem: SSFrequencyTableItem<SSElement>
        if self.sampleSize > 0 {
            for (item, freq) in self.elements {
                tableItem = SSFrequencyTableItem<SSElement>(withItem: item, relativeFrequency: Double(freq)/Double(self.sampleSize), frequency: freq)
                result.append(tableItem)
            }
            switch sortOrder {
                case .none:
                    return result
                case .valueAscending:
                    return result.sorted(by: { $0.item < $1.item})
                case .valueDescending:
                    return result.sorted(by: { $0.item > $1.item})
                case .frequencyAscending:
                    return result.sorted(by: { $0.frequency < $1.frequency})
                case .frequencyDescending:
                    return result.sorted(by: { $0.frequency > $1.frequency})
            }
        }
        else {
            return result
        }
    }
    
    /// Returns the cumulative frequency table
    /// - Parameter format: SSCumulativeFrequencyTableFormat
    public func cumulativeFrequencyTable(format: SSCumulativeFrequencyTableFormat) -> Array<SSCumulativeFrequencyTableItem<SSElement>> {
        var tableItem: SSCumulativeFrequencyTableItem<SSElement>
        var cumRelFreq: Double = 0.0
        var cumAbsFreq: Double = 0.0
        var result = Array<SSCumulativeFrequencyTableItem<SSElement>>()
        let frequencyTable = self.frequencyTable(sortOrder: .valueAscending)
        switch format {
        case .eachUniqueItem:
            for fItem:SSFrequencyTableItem<SSElement> in frequencyTable {
                cumAbsFreq = cumAbsFreq + Double(fItem.frequency)
                cumRelFreq = cumRelFreq + fItem.relativeFrequency
                for _ in (Int(cumAbsFreq) - fItem.frequency)...(Int(cumAbsFreq) - 1) {
                    tableItem = SSCumulativeFrequencyTableItem<SSElement>(withItem: fItem.item, cumulativeRelativeFrequency: cumRelFreq, cumulativefrequency: Int(cumAbsFreq))
                    result.append(tableItem)
                }
            }
        case .eachItem:
            for fItem:SSFrequencyTableItem<SSElement> in frequencyTable {
                cumAbsFreq = cumAbsFreq + Double(fItem.frequency)
                cumRelFreq = cumRelFreq + Double(fItem.relativeFrequency)
                tableItem = SSCumulativeFrequencyTableItem<SSElement>(withItem: fItem.item, cumulativeRelativeFrequency: cumRelFreq, cumulativefrequency: Int(cumAbsFreq))
                result.append(tableItem)
            }
        }
        return result
    }
    
    /// The largest item. Can be nil for empty tables.
    public var maximum: SSElement? {
        get {
            if !isEmpty {
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    return a.last
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }

    /// The smallest item. Can be nil for empty tables.
    public var minimum: SSElement? {
        get {
            if !isEmpty {
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    return a.first
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }

    /// The difference between maximum and minimum. Can be nil for empty tables.
    public var range: Double? {
        get {
            if !isEmpty && numeric {
                return (self.maximum as! Double) - (self.minimum as! Double)
            }
            else {
                return nil
            }
        }
    }
    
    /// Empirical CDF of item
    /// - Parameter item: The item for which the cdf will be returned.
    public func empiricalCDF(of item: SSElement) -> Double {
        var result: Double = Double.nan
        if let min = self.minimum, let max = self.maximum {
            if item < min {
                return 0.0
            }
            else if item > max {
                return 1.0
            }
            if self.contains(item: item) {
                result = self.cumulativeRelativeFrequencies[item]!
            }
            else {
                for itm in self.uniqueElements(sortOrder: .ascending)! {
                    if itm < item {
                        result = self.cumulativeRelativeFrequencies[itm]!
                    }
                }
            }
        }
        return result
    }
    
    /// The smallest frequency. Can be nil for empty tables.
    public var smallestFrequency: Int? {
        if !isEmpty {
            return (self.frequencyTable(sortOrder: .frequencyAscending).first?.frequency)!
        }
        else {
            return nil
        }
    }
    
    /// The largest frequency Can be nil for empty tables.
    public var largestFrequency: Int? {
        if !isEmpty {
            return (self.frequencyTable(sortOrder: .frequencyAscending).last?.frequency)!
        }
        else {
            return nil
        }
    }
    
    /// The scarcest elements. Can be nil for empty tables.
    public var scarcest: Array<SSElement>? {
        if !isEmpty {
            var result: Array<SSElement> = Array<SSElement>()
            let ft = self.frequencyTable(sortOrder: .frequencyAscending)
            let freq = ft.first?.frequency
            for tableItem in ft {
                if tableItem.frequency <= freq! {
                    result.append(tableItem.item)
                }
                else {
                    break
                }
            }
            return result
        }
        else {
            return nil
        }
    }
    
    /// The mode. Can contain more than one item. Can be nil for empty tables.
    public var mode: Array<SSElement>? {
        if !isEmpty {
            var result: Array<SSElement> = Array<SSElement>()
            let ft = self.frequencyTable(sortOrder: .frequencyDescending)
            let freq = ft.first?.frequency
            for tableItem in ft {
                if tableItem.frequency >= freq! {
                    result.append(tableItem.item)
                }
                else {
                    break
                }
            }
            return result
        }
        else {
            return nil
        }
    }
    
    /// Returns the q-quantile.
    /// Throws: SSSwiftyStatsError.invalidArgument if data are non-numeric.
    public func quantile(q: Double) throws -> Double? {
        if q.isZero || q < 0.0 || q >= 1.0 {
            os_log("p has to be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !numeric {
            os_log("Quantile is not defined for non-numeric data.", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var result: Double
        if !isEmpty {
            let k = Double(self.sampleSize) * q
            var a = self.elementsAsArray(sortOrder: .ascending)!
            if ceil(k).isEqual(to: floor(k)) {
                result = ((a[a.startIndex.advanced(by: Int(k))] as! Double) + (a[a.startIndex.advanced(by: Int(k + 1))] as! Double)) / 2.0
            }
            else {
                result = a[a.startIndex.advanced(by: Int(k))] as! Double
            }
            return result
        }
        else {
            return nil
        }
    }

    /// Returns a SSQuartile struct or nil for empty or non-numeric tables.
    public var quartile: SSQuartile? {
        get {
            if !isEmpty && numeric {
                var res = SSQuartile()
                do {
                    res.q25 = try self.quantile(q: 0.25)!
                    res.q75 = try self.quantile(q: 0.75)!
                    res.q50 = try self.quantile(q: 0.5)!
                }
                catch {
                    return nil
                }
                return res
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns the interquartile range
    public var interquartileRange: Double? {
        get {
            if !isEmpty && numeric {
                do {
                    return try interquantileRange(lowerQuantile: 0.25, upperQuantile: 0.75)!
                }
                catch {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the interquartile range between two quantiles
    /// - Parameter lower: Lower quantile
    /// - Parameter upper: Upper quantile
    public func interquantileRange(lowerQuantile upper: Double!, upperQuantile lower: Double!) throws -> Double? {
        if upper.isZero || upper < 0.0 || upper >= 1.0 || lower.isZero || lower < 0.0 || lower >= 1.0 {
            os_log("lower and upper quantile has to be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if upper < lower {
            os_log("lower quantile has to be less than upper quantile", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !numeric {
            os_log("Quantile is not defined for non-numeric data.", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if lower.isEqual(to: upper) {
            return 0.0
        }
        do {
            let q1 = try quantile(q: upper)
            let q2 = try quantile(q: lower)
            return q1! - q2!
        }
        catch {
            return nil
        }
    }
    
    
    /// The median. Can be nil for non-numeric data.
    public var median: Double? {
        get {
            var res: Double
            if !isEmpty && numeric {
                do {
                    res = try self.quantile(q: 0.5)!
                }
                catch {
                    return nil
                }
                return res
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the geometric mean.
    public var geometricMean: Double? {
        get {
            if !isEmpty && numeric {
                let a = self.logProduct
                let b = Double(self.sampleSize)
                let c = exp(a / b)
                return c
            }
            else {
                return nil
            }
        }
    }
    
    /// Harmonic mean. Can be nil for non-numeric data.
    public var harmonicMean: Double? {
        get {
            if !isEmpty && numeric {
                return Double(self.sampleSize) / self.inverseTotal
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the powered mean of order n
    /// - Parameter n: The order of the powered mean
    /// Returns: The powered mean, nan if the receiver contains non-numerical data.
    public func poweredMean(order: Double) -> Double? {
        if order <= 0.0 || !numeric {
            return nil
        }
        if !isEmpty {
            let sum = self.poweredTotal(power: order)
            return pow(sum / Double(self.sampleSize), 1.0 / order)
        }
        else {
            return nil
        }
    }
    
    /// Returns the trimmed mean of all elements after droping a fration of alpha of the smallest and largest elements.
    /// - Parameter alpha: Fraction to drop
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func trimmedMean(alpha: Double) throws -> Double? {
        if alpha <= 0.0 || alpha >= 0.5 {
            os_log("alpha has to be greater than zero and smaller than 0.5", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isEmpty {
            if numeric {
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    let l = a.count
                    let v = floor(Double(l) * alpha)
                    var s = 0.0
                    var k = 0.0
                    for i in Int(v)...l - Int(v) - 1  {
                        s = s + (a[i] as! Double)
                        k = k + 1
                    }
                    return s / k
                }
                else {
                    return nil
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

    /// Returns the mean after replacing given fraction (alpha) at the high and low end with the most extreme remaining values.
    /// - Parameter alpha: Fraction
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func winsorizedMean(alpha: Double) throws -> Double? {
        if alpha <= 0.0 || alpha >= 0.5 {
            os_log("alpha has to be greater than zero and smaller than 0.5", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isEmpty {
            if numeric {
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    let l = a.count
                    let v = floor(Double(l) * alpha)
                    var s = 0.0
                    for i in Int(v)...l - Int(v) - 1  {
                        s = s + (a[i] as! Double)
                    }
                    s = s + v * ((a[Int(v)] as! Double) + (a[Int(l - Int(v) - 1)] as! Double))
                    return s / Double(self.sampleSize)
                }
                else {
                    return nil
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
    
    /// Returns the r_th moment of the given type.
    /// If .central is specified, the r_th central moment of all elements with respect to their mean will be returned.
    /// If .origin is specified, the r_th moment about the origin will be returned.
    /// If .standardized is specified, the r_th standardized moment will be returned.
    /// - Parameter r: r
    public func moment(r: Int!, type: SSMomentType) -> Double? {
        switch type {
        case .central:
            return centralMoment(r: r)
        case .origin:
            return originMoment(r: r)
        case .standardized:
            return standardizedMoment(r: r)
        }
    }
    
    /// Returns the r_th central moment of all elements with respect to their mean. Will be Double.nan if isEmpty == true and data are not numerical
    /// - Parameter r: r
    private func centralMoment(r: Int!) -> Double? {
        if !isEmpty {
            if numeric {
                let m = self.arithmeticMean
                var diff = 0.0
                var sum = 0.0
                for (item, freq) in self.elements {
                    diff = (item as! Double) - m
                    sum = sum + pow(diff, Double(r)) * Double(freq)
                }
                return sum / Double(self.sampleSize)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }

    
    /// Returns the r_th moment about the origin of all elements. Will be Double.nan if isEmpty == true and data are not numerical
    /// - Parameter r: r
    private func originMoment(r: Int!) -> Double? {
        if !isEmpty {
            if numeric {
                var sum = 0.0
                for (item, freq) in self.elements {
                    sum = sum + pow((item as! Double), Double(r)) * Double(freq)
                }
                return sum / Double(self.sampleSize)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns then r_th standardized moment.
    private func standardizedMoment(r: Int!) -> Double? {
        if !isEmpty {
            if numeric {
                var sum = 0.0
                let m = self.arithmeticMean
                if let sd = self.standardDeviation(type: .biased) {
                    if !sd.isZero {
                        for (item, freq) in self.elements {
                            sum = sum + pow( ( (item as! Double) - m ) / sd, Double(r)) * Double(freq)
                        }
                        return sum / Double(self.sampleSize)
                    }
                    else {
                        return nil
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
        else {
            return nil
        }
    }
    
    /// Returns the sample variance.
    /// - Parameter type: Can be .sample and .unbiased
    public func variance(type: SSVarianceType) -> Double? {
        switch type {
        case .biased:
            return moment(r: 2, type: .central)
        case .unbiased:
            if !isEmpty {
                if numeric {
                    let m = self.arithmeticMean
                    var diff = 0.0
                    var sum = 0.0
                    for (item, freq) in self.elements {
                        diff = (item as! Double) - m
                        sum = sum + diff * diff * Double(freq)
                    }
                    return sum / Double(self.sampleSize - 1)
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
    }

    /// Returns the sample standard deviation.
    /// - Parameter type: .biased or .unbiased
    public func standardDeviation(type: SSStandardDeviationType) -> Double? {
        if let v = variance(type: SSVarianceType(rawValue: type.rawValue)!) {
            return sqrt(v)
        }
        else {
            return nil
        }
    }
    
    /// Returns the contraharmonic mean (== (mean of squared elements) / (arithmetic mean))
    public var contraharmonicMean: Double? {
        if !isEmpty {
            if numeric {
                let sqM = self.squareTotal / Double(self.sampleSize)
                let m = self.arithmeticMean
                if !m.isZero {
                    return sqM / m
                }
                else {
                    return Double.infinity * (-1.0)
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

    /// Returns the kurtosis excess
    public var kurtosisExcess: Double? {
        if !isEmpty {
            if numeric {
                if let m4 = moment(r: 4, type: .central), let m2 = moment(r: 2, type: .central) {
                    return m4 / pow(m2, 2) - 3.0
                }
                else {
                    return nil
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
    
    /// Returns the kurtosis.
    public var kurtosis: Double? {
        if let k = kurtosisExcess {
            return k + 3.0
        }
        else {
            return nil
        }
    }
    
    /// Returns the type of kurtosis.
    public var kurtosisType: SSKurtosisType? {
        get {
            if let ke = kurtosisExcess {
                if ke < 0 {
                    return .platykurtic
                }
                else if ke.isZero {
                    return .mesokurtic
                }
                else {
                    return .leptokurtic
                }
            }
            else {
                return nil
            }
        }
    }
    
    /// Returns the skewness.
    public var skewness: Double? {
        if !isEmpty {
            if numeric {
                if let m3 = moment(r: 3, type: .central), let s3 = standardDeviation(type: .biased) {
                    return m3 / pow(s3, 3)
                }
                else {
                    return nil
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
    
    
}
