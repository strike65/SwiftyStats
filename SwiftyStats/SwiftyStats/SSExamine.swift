//
//  SSExamine.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 01.07.17.
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

/// SSExamine
/// This class offers the possibility to store, manipulate and analyze data of any type. The only prerequisite is that the data conform to the protocols "Hashable" and "Comparable".
/// The available statistics depend on whether the data are numeric or non-numeric. If statistics are requested that are not available for the data type actually being used, Double.nan or nil is returned. Some methods throws an error in such circumstances.
public class SSExamine<SSElement>:  NSObject, SSExamineContainer, NSCopying, NSCoding where SSElement: Hashable, SSElement: Comparable {
    
    // MARK: OPEN/PUBLIC VARS
    
    /// User defined tag
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
    public var isNumeric: Bool! = true
    
    /// Returns the count of unique SSElements
    public var length: Int {
        return items.count
    }
    
    /// Returns true, if count == 0
    public var isEmpty: Bool {
        return count == 0
    }
    
    /// The total number of observations (= sum of all absolute frequencies)
    public var sampleSize: Int {
        return count
    }
    
    /// Returns a Dictionary<element<SSElement>,cumulative frequency<Double>>
    public var cumulativeRelativeFrequencies: Dictionary<SSElement, Double> {
//        updateCumulativeFrequencies()
        return cumRelFrequencies
    }
    
    /// Returns the hash value
    public override var hashValue: Int {
        var temp: Int
        if !isEmpty {
            var a = elementsAsArray(sortOrder: .original)!
            let strings = self.elementsAsString(withDelimiter: "")!
            temp = (a[a.startIndex].hashValue)
            for item in a {
                temp = temp ^ item.hashValue ^ strings.hash
            }
            return temp
        }
        else {
            return 0
        }
    }
    
    /// Two SSExamine objects are supposed to be equal, iff the arrays of all elements in unsorted order are equal.
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
    
    
    /// Returns all unique elements as a Dictionary<element<SSElement>:frequency<Int>>
    public var elements: Dictionary<SSElement, Int> {
        return items
    }
    
    /// Returns a dictionary containing one array for each element. This array contains the order in which the elements were appended.
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
    /// - Parameter object: The object used
    /// - Parameter characterSet: Set containing all characters to include by string analysis. If a type other than String is used, this parameter will be ignored. If a string is used to initialize the class and characterSet is nil, then all characters will be appended.
    /// - Throws: SSSwiftyStatsError.missingData if object is not a string or an array<SSElement>
    public init(withObject object: Any!, levelOfMeasurement lom: SSLevelOfMeasurement!, name: String?, characterSet: CharacterSet?) throws {
        // allow only arrays an strings as 'object'
        guard ((object is String && object is SSElement) || (object is Array<SSElement>)) else {
            os_log("Error creating SSExamine instance", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .missingData, file: #file, line: #line, function: #function)
        }
        super.init()
        if let n = name {
            self.name = n
        }
        self.levelOfMeasurement = lom
        if object is String  {
            self.levelOfMeasurement = .nominal
            self.initializeWithString(string: object as! String, characterSet: characterSet)
        }
        else if object is Array<SSElement> {
            self.initializeWithArray(object as! Array<SSElement>)
        }
    }
    
    /// Returns: New table by analyzing string. Taking characterSet into account, when set
    /// - Parameter array: The array containing the elements
    /// - Parameter characterSet: Set containing all characters to include by string analysis. If a type other than String is used, this parameter will be ignored. If a string is used to initialize the class and characterSet is nil, then all characters will be appended.
    public init(withArray array: Array<SSElement>!, name: String?, characterSet: CharacterSet?) {
        super.init()
        if let n = name {
            self.name = n
        }
        else {
            self.name = nil
        }
        self.initializeWithArray(array)
    }
    
    
    /// Loads the content of a file interpreting the elements separated by separator as double values using the specified encoding.
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter separator: The separator used in the file
    /// - Parameter stringEncoding: The encoding to use.
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed
    public class func examine(fromFile path: String!, separator: String!, stringEncoding: String.Encoding!) throws -> SSExamine<Double>? {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            os_log("File not found", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        let filename = NSURL(fileURLWithPath: fullFilename).lastPathComponent!
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
            return SSExamine<Double>.init(withArray: numberArray, name: filename, characterSet: nil)
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
    /// - Throws: SSSwiftyStatsError if the file could not be written
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
    public class func examineWithString(_ string: String!, name: String?, characterSet: CharacterSet?) -> SSExamine<String>? {
        do {
            let result:SSExamine<String> = try SSExamine<String>(withObject: string, levelOfMeasurement: .nominal, name: name,  characterSet: characterSet)
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
        isNumeric = false
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
    private func initializeWithArray(_ array: Array<SSElement>!) {
        initializeSSExamine()
        if array.count > 0 {
            if isNumber(array[0]) {
                isNumeric = true
            }
            else {
                isNumeric = false
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
        isNumeric = true
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
        aCoder.encode(isNumeric, forKey: "isNumeric")
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
        isNumeric = aDecoder.decodeObject(forKey: "isNumeric") as! Bool
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
    public func contains(_ element: SSElement) -> Bool {
        if !isEmpty {
            let test = items.contains(where: { (key: SSElement, value: Int) in
                if key == element {
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
    public func relativeFrequency(_ element: SSElement) -> Double {
        if contains(element) {
            return Double(self.elements[element]!) / Double(self.sampleSize)
        }
        else {
            return 0.0
        }
    }
    
    /// Returns the absolute frequency of item
    /// - Parameter item: Item
    public func frequency(_ element: SSElement) -> Int {
        if contains(element) {
            return items[element]!
        }
        else {
            return 0
        }
    }
    
    /// Appends <item> and updates frequencies
    /// - Parameter item: Item
    public func append(_ element: SSElement!) {
        var tempPos: Array<Int>
        let test = items.contains(where: { (key: SSElement, value: Int) in
            if key == element {
                return true
            }
            else {
                return false
            }
        })
        var currentFrequency: Int
        if test {
            currentFrequency = items[element]! + 1
            items[element] = currentFrequency
            count = count + 1
            // update relative frequencies
            for (itm, freq) in items {
                relFrequencies[itm] = Double(freq) / Double(self.sampleSize)
            }
            sequence[element]!.append(count)
        }
        else {
            items[element] = 1
            count = count + 1
            for (itm, freq) in items {
                relFrequencies[itm] = Double(freq) / Double(self.sampleSize)
            }
            tempPos = Array()
            tempPos.append(count)
            sequence[element] = tempPos
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends n elements
    /// - Paramater n: Count of elements to add
    /// - Parameter item: Item to append
    public func append(repeating n: Int!, element: SSElement!) {
        for _ in 1...n {
            append(element)
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends elements from an array
    /// - Parameter array: Array containing elements to add
    public func append(contentOf array: Array<SSElement>!) {
        if array.count > 0 {
            if isEmpty {
                isNumeric = isNumber(array[array.startIndex])
            }
            for item in array {
                append(item)
            }
        }
        //        updateCumulativeFrequencies()
    }
    
    /// Appends the characters of the given string. Only characters contained in the character set are appended.
    /// - Parameter text: The text
    /// - Parameter characterSet: A CharacterSet containing the characters to include. If nil, all characters of text will be appended.
    /// - Throws: SSSwiftyStatsError if <SSElement> of the receiver is not of type String
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
    /// - Parameter allOccurences: If false, only the first item found will be removed.
    public func remove(_ element: SSElement!, allOccurences all: Bool!) {
        if !isEmpty {
            if contains(element) {
                var temp: Array<SSElement> = elementsAsArray(sortOrder: .original)!
                // remove all elements
                if all {
                    temp = temp.filter({ $0 != element})
                }
                else {
                    // remove only the first occurence
                    let s: Array<Int> = sequence[element]!
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
    
    /// Removes all elements leaving an empty object
    public func removeAll() {
        count = 0
        items.removeAll()
        sequence.removeAll()
        relFrequencies.removeAll()
        cumRelFrequencies.removeAll()
        isNumeric = true
        hasChanges = true
    }
    
    
    
}

extension SSExamine {
    
    // MARK: File Management

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

extension SSExamine {
    
    // MARK: Elements

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
            for (item, freq) in self.elements {
                for _ in 1...freq {
                    temp.append(item)
                }
            }
            switch sortOrder {
            case .ascending:
                result = temp.sorted(by: {$0 < $1})
            case .descending:
                result = temp.sorted(by: {$0 > $1})
            case .none:
                result = temp
            case .original:
                temp.removeAll(keepingCapacity: true)
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
    
    // MARK: Frequencies
    
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
    
    /// Empirical CDF of item
    /// - Parameter item: The item for which the cdf will be returned.
    public func empiricalCDF(_ item: SSElement) -> Double {
        var result: Double = Double.nan
        if let min = self.minimum, let max = self.maximum {
            if item < min {
                return 0.0
            }
            else if item > max {
                return 1.0
            }
            if self.contains(item) {
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


}

extension SSExamine {
    
    // MARK: Totals
    
    /// Sum over all squared elements. Returns Double.nan iff data are non-numeric.
    public var squareTotal: Double {
        if isNumeric && !isEmpty {
            var s: Double = 0.0
            var temp: Double
            for (item, freq) in self.elements {
                if item is Int {
                    temp = Double(item as! Int)
                }
                else {
                    temp = item as! Double
                }
                s = s + pow(temp ,2.0) * Double(freq)
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
        if isNumeric && !isEmpty {
            var s: Double = 0.0
            var temp: Double
            for (item, freq) in self.elements {
                if item is Int {
                    temp = Double(item as! Int)
                }
                else {
                    temp = item as! Double
                }
                s = s + pow(temp, p) * Double(freq)
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    
    /// Total of all elements. Returns Double.nan iff data are non-numeric.
    public var total: Double {
        if isNumeric && !isEmpty {
            var s: Double = 0.0
            var temp: Double
            for (item, freq) in self.elements {
                if item is Int {
                    temp = Double(item as! Int)
                }
                else {
                    temp = item as! Double
                }
                s = s + temp * Double(freq)
            }
            return s
        }
        else {
            return Double.nan
        }
    }
    
    /// Returns the sum of all inversed elements
    public var inverseTotal: Double {
        if isNumeric && !isEmpty {
            var s = 0.0
            var temp: Double
            for (item, freq) in self.elements {
                if item is Int {
                    temp = Double(item as! Int)
                }
                else {
                    temp = item as! Double
                }
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
    
    // MARK: Location
    
    /// Arithemtic mean. Will be Double.nan for non-numeric data.
    public var arithmeticMean: Double? {
        if isNumeric && !isEmpty {
            return total / Double(sampleSize)
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
    
    /// The most common value. Same as mode. Can contain more than one item. Can be nil for empty tables.
    public var commonest: Array<SSElement>? {
        return mode
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
    
    /// Returns the q-quantile.
    /// Throws: SSSwiftyStatsError.invalidArgument if data are non-numeric.
    public func quantile(q: Double) throws -> Double? {
        if q.isZero || q < 0.0 || q >= 1.0 {
            os_log("p has to be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isNumeric {
            os_log("Quantile is not defined for non-numeric data.", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        var result: Double
        if !isEmpty && self.sampleSize >= 2 {
            let k = Double(self.sampleSize) * q
            var a = self.elementsAsArray(sortOrder: .ascending)!
            var temp1: Double
            var temp2: Double
            var temp3: SSElement
            if k.truncatingRemainder(dividingBy: 1).isZero {
                temp3 = a[a.startIndex.advanced(by: Int(k - 1))]
                if temp3 is Int {
                    temp1 = Double(temp3 as! Int)
                }
                else {
                    temp1 = temp3 as! Double
                }
                temp3 = a[a.startIndex.advanced(by: Int(k))]
                if temp3 is Int {
                    temp2 = Double(temp3 as! Int)
                }
                else {
                    temp2 = temp3 as! Double
                }
                result = (temp1 + temp2) / 2.0
            }
            else {
                temp3 = a[a.startIndex.advanced(by: Int(ceil(k - 1)))]
                if temp3 is Int {
                    result = Double(temp3 as! Int)
                }
                else {
                    result = temp3 as! Double
                }
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
            if !isEmpty && isNumeric {
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
    
    /// Returns the geometric mean.
    public var geometricMean: Double? {
        get {
            if !isEmpty && isNumeric {
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
            if !isEmpty && isNumeric {
                return Double(self.sampleSize) / self.inverseTotal
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns the contraharmonic mean (== (mean of squared elements) / (arithmetic mean))
    public var contraHarmonicMean: Double? {
        if !isEmpty && isNumeric {
            let sqM = self.squareTotal / Double(self.sampleSize)
            let m = self.arithmeticMean!
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

    /// Returns the powered mean of order n
    /// - Parameter n: The order of the powered mean
    /// - Returns: The powered mean, nil if the receiver contains non-numerical data.
    public func poweredMean(order: Double) -> Double? {
        if order <= 0.0 || !isNumeric {
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
    
    /// Returns the trimmed mean of all elements after dropping a fraction of alpha of the smallest and largest elements.
    /// - Parameter alpha: Fraction to drop
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func trimmedMean(alpha: Double) throws -> Double? {
        if alpha <= 0.0 || alpha >= 0.5 {
            os_log("alpha has to be greater than zero and smaller than 0.5", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isEmpty {
            if isNumeric {
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    let l = a.count
                    let v = floor(Double(l) * alpha)
                    var s = 0.0
                    var k = 0.0
                    var temp: Double
                    for i in Int(v)...l - Int(v) - 1  {
                        if a[i] is Int {
                            temp = Double(a[i] as! Int)
                        }
                        else {
                            temp = a[i] as! Double
                        }
                        s = s + temp
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
    
    /// Returns the mean after replacing a given fraction (alpha) at the high and low end with the most extreme remaining values.
    /// - Parameter alpha: Fraction
    /// - Throws: Throws an error if alpha <= 0 or alpha >= 0.5
    public func winsorizedMean(alpha: Double) throws -> Double? {
        if alpha <= 0.0 || alpha >= 0.5 {
            os_log("alpha has to be greater than zero and smaller than 0.5", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isEmpty && isNumeric {
            if let a = self.elementsAsArray(sortOrder: .ascending) {
                let l = a.count
                let v = floor(Double(l) * alpha)
                var s = 0.0
                var temp: Double
                for i in Int(v)...l - Int(v) - 1  {
                    if a[i] is Int {
                        temp = Double(a[i] as! Int)
                    }
                    else {
                        temp = a[i] as! Double
                    }
                    s = s + temp
                }
                var temp1: Double
                if a[Int(v)] is Int {
                    temp = Double(a[Int(v)] as! Int)
                }
                else {
                    temp = a[Int(v)] as! Double
                }
                if a[Int(l - Int(v) - 1)] is Int {
                    temp1 = Double(a[Int(l - Int(v) - 1)] as! Int)
                }
                else {
                    temp1 = a[Int(l - Int(v) - 1)] as! Double
                }
                s = s + v * (temp + temp1)
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
    
    /// The median. Can be nil for non-numeric data.
    public var median: Double? {
        get {
            var res: Double
            if !isEmpty && isNumeric {
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
    
    // MARK: Products
    
    /// Product of all elements. Will be Double.nan for non-numeric data.
    public var product: Double {
        if isNumeric && !isEmpty {
            var p: Double = 1.0
            var temp: Double
            for (item, freq) in self.elements {
                if item is Int {
                    temp = Double(item as! Int)
                }
                else {
                    temp = item as! Double
                }
                if temp.isZero {
                    return 0.0
                }
                else {
                    p = p * pow(temp, Double(freq))
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
    
    /// The log-Product. Will be Double.nan for non-numeric data or if there is at least one item lower than zero. Returns -inf if there is at least one item equals to zero.
    public var logProduct: Double {
        var sp : Double = 0.0
        var temp: Double
        if isNumeric && !isEmpty {
            if isEmpty {
                return 0.0
            }
            else {
                for (item, freq) in self.elements {
                    if item is Int {
                        temp = Double(item as! Int)
                    }
                    else {
                        temp = item as! Double
                    }
                    if temp > 0 {
                        sp = sp + log(temp) * Double(freq)
                    }
                    else if temp.isZero {
                        return -Double.infinity
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
    
    
    
    // MARK: Dispersion
    
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
            if !isEmpty && isNumeric {
                if self.maximum is Int {
                    return Double((self.maximum as! Int) - (self.minimum as! Int))
                }
                else {
                    return (self.maximum as! Double) - (self.minimum as! Double)
                }
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns the quartile devation (interquartile range / 2.0)
    public var quartileDeviation: Double? {
        if let _ = self.interquartileRange {
            return self.interquartileRange! / 2.0
        }
        else {
            return nil
        }
    }
    
    /// Returns the relative quartile distance
    public var relativeQuartileDistance: Double? {
        if let q: SSQuartile = self.quartile {
            return (q.q75 - q.q25) / q.q50
        }
        else {
            return nil
        }
    }
    
    /// Returns the mid-range
    public var midRange: Double? {
        if !isEmpty {
            if isNumeric {
                if self.maximum is Int {
                    return Double((self.maximum as! Int) + (self.minimum as! Int)) / 2.0
                }
                else {
                    return ((self.maximum as! Double) + (self.minimum as! Double)) / 2.0
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
    
    
    /// Returns the interquartile range
    public var interquartileRange: Double? {
        get {
            if !isEmpty && isNumeric {
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
    /// - Throws: SSSwiftyStatsError.invalidArgument if upper.isZero || upper < 0.0 || upper >= 1.0 || lower.isZero || lower < 0.0 || lower >= 1.0 || upper < lower
    public func interquantileRange(lowerQuantile upper: Double!, upperQuantile lower: Double!) throws -> Double? {
        if upper.isZero || upper < 0.0 || upper >= 1.0 || lower.isZero || lower < 0.0 || lower >= 1.0 {
            os_log("lower and upper quantile has to be > 0.0 and < 1.0", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if upper < lower {
            os_log("lower quantile has to be less than upper quantile", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        if !isNumeric {
            return nil
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
    
    /// Returns the sample variance.
    /// - Parameter type: Can be .sample and .unbiased
    public func variance(type: SSVarianceType) -> Double? {
        switch type {
        case .biased:
            return moment(r: 2, type: .central)
        case .unbiased:
            if !isEmpty && isNumeric && self.sampleSize >= 2 {
                let m = self.arithmeticMean
                var diff = 0.0
                var sum = 0.0
                for (item, freq) in self.elements {
                    if item is Int {
                        diff = Double(item as! Int) - m!
                    }
                    else {
                        diff = (item as! Double) - m!
                    }
                    sum = sum + diff * diff * Double(freq)
                }
                return sum / Double(self.sampleSize - 1)
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
    
    /// Returns the standard error of the sample
    public var standardError: Double? {
        if !isEmpty && isNumeric {
            let sd = self.standardDeviation(type: .unbiased)!
            return sd / Double(self.sampleSize)
        }
        else {
            return nil
        }
    }

    
    /// Returns the entropy of the sample. Defined only for nominal or ordinal data
    public var entropy: Double? {
        if !isEmpty && isNumeric {
            if self.levelOfMeasurement == .ordinal || self.levelOfMeasurement == .nominal {
                var s: Double = 0.0
                for item in self.uniqueElements(sortOrder: .none)! {
                    s += self.relativeFrequency(item) * log2(self.relativeFrequency(item))
                }
                return -s
            }
            else {
                // entropy is not defined for levels other than .nominal or .ordinal
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the relative entropy of the sample. Defined only for nominal or ordinal data
    public var relativeEntropy: Double? {
        if let e = self.entropy {
            return e / log2(Double(self.sampleSize))
        }
        else {
            return nil
        }
    }
    
    // Returns the Herfindahl index
    public var herfindahlIndex: Double? {
        if !isEmpty && isNumeric {
            if self.levelOfMeasurement == .ordinal || self.levelOfMeasurement == .nominal {
                var s: Double = 0.0
                var p: Double = 0.0
                for item in self.uniqueElements(sortOrder: .none)! {
                    p = self.relativeFrequency(item)
                    s += p * p
                }
                return 1.0 - p
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    // Returns the normalized Herfindahl index
    public var herfindahlIndexNormalized: Double? {
        if let hi = self.herfindahlIndex {
            return hi * Double(self.length) / Double(self.length - 1)
        }
        else {
            return nil
        }
    }
    
    /// Returns the Gini coefficient
    public var giniCoeff: Double? {
        if let md = meanDifference {
            return md / (2.0 * arithmeticMean!)
        }
        else {
            return nil
        }
    }

    /// Returns the alpha-confidence interval of the mean when the population variance is known
    /// - Parameter a: Alpha
    /// - Parameter sd: Standard deviation of the population
    public func normalCI(alpha a: Double!, populationSD sd: Double!) -> SSConfIntv? {
        if alpha <= 0.0 || alpha >= 1.0 {
            return nil
        }
        if !isEmpty && isNumeric {
            var upper: Double
            var lower: Double
            var width: Double
            var t1: Double
            var u: Double
            do {
                let m = self.arithmeticMean
                u = try SSProbabilityDistributions.quantileStandardNormalDist(p: 1.0 - alpha / 2.0)
                t1 = sd / sqrt(Double(self.sampleSize))
                width = u * t1
                upper = m! + width
                lower = m! - width
                var result = SSConfIntv()
                result.lowerBound = lower
                result.upperBound = upper
                result.intervalWidth = width
                return result
            }
            catch {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the alpha-confidence interval of the mean when the population variance is unknown
    /// - Parameter a: Alpha
    public func studentTCI(alpha a: Double!) -> SSConfIntv? {
        if alpha <= 0.0 || alpha >= 1.0 {
            return nil
        }
        if !isEmpty && isNumeric {
            var upper: Double
            var lower: Double
            var width: Double
            var m: Double
            var u: Double
            m = arithmeticMean!
            if let s = self.standardDeviation(type: .unbiased) {
                do {
                    u = try SSProbabilityDistributions.quantileStudentTDist(p: 1.0 - alpha / 2.0 , degreesOfFreedom: Double(self.sampleSize) - 1.0)
                }
                catch {
                    return nil
                }
                lower = m - u * s / sqrt(Double(self.sampleSize))
                upper = m + u * s / sqrt(Double(self.sampleSize))
                width = u * s / sqrt(Double(self.sampleSize))
                var result = SSConfIntv()
                result.lowerBound = lower
                result.upperBound = upper
                result.intervalWidth = width
                return result
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the 0.95-confidence interval of the mean using Student's T distribution.
    public var meanCI: SSConfIntv? {
        get {
            return self.studentTCI(alpha: 0.05)
        }
    }
    
    /// Returns the coefficient of variation. A shorctut for coefficientOfVariation:
    public var cv: Double? {
        return coefficientOfVariation
    }
    
    
    /// Returns the coefficient of variation
    public var coefficientOfVariation: Double? {
        if !isEmpty && isNumeric {
            if let s = self.standardDeviation(type: .unbiased) {
                return s / arithmeticMean!
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns the mean absolute difference
    public var meanDifference: Double? {
        if !isEmpty && isNumeric {
            if self.sampleSize < 2 {
                return nil
            }
            var s1: Double = 0.0
            var s2: Double = 0.0
            let c: Double = Double(self.sampleSize)
            let a = elementsAsArray(sortOrder: .ascending)!
            var v: Int = 1
            var k: Int
            var t1: Double
            var t2: Double
            while v <= (self.sampleSize - 1) {
                k = v + 1
                while k <= self.sampleSize {
                    if a[v - 1] is Int {
                        t1 = Double(a[v - 1] as! Int)
                        t2 = Double(a[k - 1] as! Int)
                    }
                    else {
                        t1 = a[v - 1] as! Double
                        t2 = a[k - 1] as! Double
                    }
                    s1 = s1 + fabs(t1 - t2)
                    k = k + 1
                }
                s2 = s2 + s1
                s1 = 0.0
                v = v + 1
            }
            return (s2 * 2.0 / (c * (c - 1.0)))
        }
        else {
            return nil
        }
    }
    
    /// Returns the median absolute deviation around the reference point given. If you would like to know the median absoulute deviation from the median, you can do so by setting the reference point to the median
    /// - Parameter rp: Reference point
    public func medianAbsoluteDeviation(aroundReferencePoint rp: Double!) -> Double? {
        if isEmpty && !isNumeric && !rp.isNaN {
            return nil
        }
        var diffArray:Array<Double> = Array<Double>()
        let values = self.elementsAsArray(sortOrder: .ascending)!
        var t1: Double
        let result: Double
        for item in values  {
            if item is Int {
                t1 = Double(item as! Int)
            }
            else {
                t1 = item as! Double
            }
            diffArray.append(fabs(t1 - rp))
        }
        let sortedDifferences = diffArray.sorted(by: {$0 < $1})
        let k = Double(sortedDifferences.count) * 0.5
        if k.truncatingRemainder(dividingBy: 1).isZero {
            result = (sortedDifferences[sortedDifferences.startIndex.advanced(by: Int(k - 1))] + sortedDifferences[sortedDifferences.startIndex.advanced(by: Int(k))]) / 2.0
        }
        else {
            result = sortedDifferences[sortedDifferences.startIndex.advanced(by: Int(ceil(k - 1)))]
        }
        return result
    }
    
    /// Returns the mean absolute deviation around the reference point given. If you would like to know the mean absoulute deviation from the median, you can do so by setting the reference point to the median
    /// - Parameter rp: Reference point
    public func meanAbsoluteDeviation(aroundReferencePoint rp: Double!) -> Double? {
        if isEmpty && !isNumeric && !rp.isNaN {
            return nil
        }
        var sum: Double = 0.0
        var t1: Double
        var f1: Double
        var c: Int = 0
        for (item, freq) in self.elements {
            if item is Int {
                t1 = Double(item as! Int)
            }
            else {
                t1 = item as! Double
            }
            f1 = Double(freq)
            sum = sum + fabs(t1 - rp) * f1
            c = c + freq
        }
        return sum / Double(c)
    }
    
    
    /// Returns the relative mean absolute difference
    public var meanRelativeDifference: Double? {
        if let md = meanDifference {
            return md / arithmeticMean!
        }
        else {
            return nil
        }
    }
    
    /// Returns the semi-variance
    /// - Parameter type: SSSemiVariance.lower or SSSemiVariance.upper
    public func semiVariance(type: SSSemiVariance) -> Double? {
        if !isEmpty && isNumeric {
            switch type {
            case .lower:
                if let a = self.elementsAsArray(sortOrder: .ascending) {
                    let m = self.arithmeticMean!
                    var t: Double
                    var s = 0.0
                    var k: Double = 0
                    for itm in a {
                        if itm is Int {
                            t = Double(itm as! Int)
                        }
                        else {
                            t = itm as! Double
                        }
                        if t < m {
                            s = s + pow(t - m, 2.0)
                            k = k + 1.0
                        }
                        else {
                            break
                        }
                    }
                    return s / k
                }
                else {
                    return nil
                }
            case .upper:
                if let a = self.elementsAsArray(sortOrder: .descending) {
                    let m = self.arithmeticMean!
                    var t: Double
                    var s = 0.0
                    var k: Double = 0
                    for itm in a {
                        if itm is Int {
                            t = Double(itm as! Int)
                        }
                        else {
                            t = itm as! Double
                        }
                        if t > m {
                            s = s + pow(t - m, 2.0)
                            k = k + 1.0
                        }
                        else {
                            break
                        }
                    }
                    return s / k
                }
                else {
                    return nil
                }
            }
        }
        else {
            return nil
        }
    }


    // MARK: Empirical Moments
    
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
    fileprivate func centralMoment(r: Int!) -> Double? {
        if !isEmpty && isNumeric {
            let m = self.arithmeticMean!
            var diff = 0.0
            var sum = 0.0
            var t: Double
            for (item, freq) in self.elements {
                if item is Int {
                    t = Double(item as! Int)
                }
                else {
                    t = item as! Double
                }
                diff = t - m
                sum = sum + pow(diff, Double(r)) * Double(freq)
            }
            return sum / Double(self.sampleSize)
        }
        else {
            return nil
        }
    }
    
    
    /// Returns the r_th moment about the origin of all elements. Will be Double.nan if isEmpty == true and data are not numerical
    /// - Parameter r: r
    fileprivate func originMoment(r: Int!) -> Double? {
        if !isEmpty && isNumeric {
            var sum = 0.0
            var t: Double
            for (item, freq) in self.elements {
                if item is Int {
                    t = Double(item as! Int)
                }
                else {
                    t = item as! Double
                }
                sum = sum + pow(t, Double(r)) * Double(freq)
            }
            return sum / Double(self.sampleSize)
        }
        else {
            return nil
        }
    }
    
    /// Returns then r_th standardized moment.
    fileprivate func standardizedMoment(r: Int!) -> Double? {
        if !isEmpty && isNumeric {
            var sum = 0.0
            let m = self.arithmeticMean
            if let sd = self.standardDeviation(type: .biased) {
                if !sd.isZero {
                    var t: Double
                    for (item, freq) in self.elements {
                        if item is Int {
                            t = Double(item as! Int)
                        }
                        else {
                            t = item as! Double
                        }
                        sum = sum + pow( ( t - m! ) / sd, Double(r)) * Double(freq)
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
    
    // MARK: Empirical distribution parameters
    
    /// Returns the kurtosis excess
    public var kurtosisExcess: Double? {
        if !isEmpty && isNumeric {
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
        if !isEmpty && isNumeric {
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
    
    /// Returns the type of skewness
    public var skewnessType: SSSkewness? {
        get {
            if let sk = skewness {
                if sk < 0 {
                    return .leftSkewed
                }
                else if sk.isZero {
                    return .symmetric
                }
                else {
                    return .rightSkewed
                }
            }
            else {
                return nil
            }
        }
    }
    
    
    /// Returns true, if there are outliers.
    /// - Parameter testType: SSOutlierTest.grubbs or SSOutlierTest.esd (Rosner Test)
    public func hasOutliers(testType: SSOutlierTest) -> Bool? {
        if !isEmpty && isNumeric {
            switch testType {
            case .grubbs:
//                var tempArray = Array<Double>()
//                let a:Array<SSElement> = self.elementsAsArray(sortOrder: .original)!
//                if SSElement.self is Int.Type {
//                    for itm in a {
//                        tempArray.append(Double(itm as! Int))
//                    }
//                }
//                else {
//                    for itm in a {
//                        tempArray.append(itm as! Double)
//                    }
//                }
                do {
                    let res = try SSHypothesisTesting.grubbsTest(data:self, alpha: 0.05)
                    return res.hasOutliers
                }
                catch {
                    return nil
                }
            case .esd:
                var tempArray = Array<Double>()
                let a:Array<SSElement> = self.elementsAsArray(sortOrder: .original)!
                if SSElement.self is Int.Type {
                    for itm in a {
                        tempArray.append(Double(itm as! Int))
                    }
                }
                else {
                    for itm in a {
                        tempArray.append(itm as! Double)
                    }
                }
                if let res = SSHypothesisTesting.esdOutlierTest(array: tempArray, alpha: 0.05, maxOutliers: self.sampleSize / 2, testType: .bothTails) {
                    if res.countOfOutliers! > 0 {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else {
                    return nil
                }
            }
        }
        else {
            return nil
        }
    }
    
    /// Returns an Array containing outliers if those exist. Uses the ESD statistics,
    /// - Parameter alpha: Alpha
    /// - Parameter max: Maximum number of outliers to return
    /// - Parameter testType: SSOutlierTest.grubbs or SSOutlierTest.esd (Rosner Test)
    public func outliers(alpha: Double!, max: Int!, testType t: SSESDTestType) -> Array<SSElement>? {
        if !isEmpty && isNumeric {
            var tempArray = Array<Double>()
            let a:Array<SSElement> = self.elementsAsArray(sortOrder: .original)!
            if SSElement.self is Int.Type {
                for itm in a {
                    tempArray.append(Double(itm as! Int))
                }
            }
            else {
                for itm in a {
                    tempArray.append(itm as! Double)
                }
            }
            if let res = SSHypothesisTesting.esdOutlierTest(array: tempArray, alpha: alpha, maxOutliers: max, testType: t) {
                if res.countOfOutliers! > 0 {
                    return res.outliers as? Array<SSElement>
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
    
    /// Returns true, if the sammple seems to be drawn from a normally distributed population with mean = mean(sample) and sd = sd(sample)
    public var isGaussian: Bool? {
        if isEmpty || !isNumeric {
            return nil
        }
        else {
            do {
                if let r = try SSHypothesisTesting.ksGoFTest(array: self.elementsAsArray(sortOrder: .ascending)! as! Array<Double>, targetDistribution: .gaussian) {
                    return r.pValue! > self.alpha
                }
                else {
                    return nil
                }
            }
            catch {
                return nil
            }
        }
    }
    
    /// Tests, if the sample was drawn from population with a particular distribution function
    // - Parameter target: Distribution to test
    public func testForDistribution(targetDistribution target: SSGoFTarget) throws -> SSKSTestResult? {
        if isEmpty || !isNumeric {
            return nil
        }
        else {
            do {
                return try SSHypothesisTesting.ksGoFTest(array: self.elementsAsArray(sortOrder: .ascending)! as! Array<Double>, targetDistribution: target)
            }
            catch {
                throw error
            }
        }
    }
    
    
}
