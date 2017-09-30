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
/// The available statistics depend on whether the data are numeric or non-numeric. If statistics are requested that are not available for the data type actually being used, Double.nan or nil is returned. Some methods throws an error in such circumstances.0
public class SSExamine<SSElement>:  NSObject, SSExamineContainer, NSCopying, Codable where SSElement: Hashable, SSElement: Comparable {
    
    // MARK: OPEN/PUBLIC VARS

    /// User defined tag
    public var tag: String?
    
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
//            self.tag = n
        }
//        else {
//            self.tag = UUID.init().uuidString
//            self.name = self.tag
//        }
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
//            self.tag = n
        }
//        else {
//            self.name = UUID.init().uuidString
//            self.tag = self.name
//        }
        self.initializeWithArray(array)
    }
    
    
    /// Loads the content of a file interpreting the elements separated by separator as double values using the specified encoding.
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter separator: The separator used in the file
    /// - Parameter stringEncoding: The encoding to use.
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed
    public class func examine(fromFile path: String!, separator: String!, stringEncoding: String.Encoding!, _ parser: (String!) -> SSElement?) throws -> SSExamine<SSElement>? {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            os_log("File not found", log: log_stat, type: .error)
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        let filename = NSURL(fileURLWithPath: fullFilename).lastPathComponent!
        var numberArray: Array<SSElement> = Array<SSElement>()
        var go: Bool = true
        do {
            let importedString = try String.init(contentsOfFile: fullFilename, encoding: stringEncoding)
            if importedString.contains(separator) {
                if importedString.characters.count > 0 {
                    let separatedStrings: Array<String> = importedString.components(separatedBy: separator)
                    for string in separatedStrings {
                        if string.characters.count > 0 {
                            if let value = parser(string) {
                                numberArray.append(value)
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
            return SSExamine<SSElement>.init(withArray: numberArray, name: filename, characterSet: nil)
        }
        else {
            return nil
        }
    }
    
    /// Exports the object as JSON to the given path using the specified encoding.
    /// - Parameter path: Path to the file
    /// - Parameter atomically: If true, the object will be written to a temporary file first. This file will be renamed upon completion.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Parameter stringEncoding: String encoding
    /// - Throws: SSSwiftyStatsError if the file could not be written
    public func exportJSONString(fileName path: String!, atomically: Bool! = true, overwrite: Bool!, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
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
        let jsonEncode = JSONEncoder()
        do {
            let data = try jsonEncode.encode(self)
            if let jsonString = String.init(data: data, encoding: stringEncoding) {
                try jsonString.write(to: URL.init(fileURLWithPath: fullName), atomically: true, encoding: stringEncoding)
                return true
            }
            else {
                return false
            }
        }
        catch {
            os_log("Unable to write json", log: log_stat, type: .error)
            return false
        }
    }

    
    /// Saves the object to the given path using the specified encoding.
    /// - Parameter path: Path to the file
    /// - Parameter atomically: If true, the object will be written to a temporary file first. This file will be renamed upon completion.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Parameter separator: Separator to use.
    /// - Parameter stringEncoding: String encoding
    /// - Throws: SSSwiftyStatsError if the file could not be written
    public func saveTo(fileName path: String!, atomically: Bool! = true, overwrite: Bool!, separator: String! = ",", asRow: Bool = true, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
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
        if let s = elementsAsString(withDelimiter: separator, asRow: asRow) {
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
    
//    // MARK: Codable protocol
    private enum CodingKeys: String, CodingKey {
        case tag = "TAG"
        case name
        case descriptionString
        case alpha
        case levelOfMeasurement
        case isNumeric
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.tag, forKey: .tag)
        try container.encodeIfPresent(self.descriptionString, forKey: .descriptionString)
        try container.encodeIfPresent(self.alpha, forKey: .alpha)
        try container.encodeIfPresent(self.levelOfMeasurement.rawValue, forKey: .levelOfMeasurement)
        try container.encodeIfPresent(self.isNumeric, forKey: .isNumeric)
        try container.encodeIfPresent(self.elementsAsArray(sortOrder: .original), forKey: .data)
    }


    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try container.decodeIfPresent(String.self, forKey: .tag)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.descriptionString = try container.decodeIfPresent(String.self, forKey: .descriptionString)
        self.alpha = try container.decodeIfPresent(Double.self, forKey: .alpha)
        if let lm = try container.decodeIfPresent(Int.self, forKey: .levelOfMeasurement) {
            self.levelOfMeasurement = SSLevelOfMeasurement(rawValue:lm)
        }
        self.isNumeric = try container.decodeIfPresent(Bool.self, forKey: .isNumeric)
        if let data: Array<SSElement> = try container.decodeIfPresent(Array<SSElement>.self, forKey: .data) {
            self.initializeWithArray(data)
        }
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
    public func rFrequency(_ element: SSElement) -> Double {
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
    
    // MARK: Elements

    /// Returns all elements as one string. Elements are delimited by del.
    /// Paramater del: The delimiter. Can be nil or empty.
    public func elementsAsString(withDelimiter del: String?, asRow: Bool = true) -> String? {
        let a: Array<SSElement> = elementsAsArray(sortOrder: .original)!
        var res: String = String()
        if !asRow {
            if let n = self.name {
                res = res + n + "\n"
            }
        }
        for item in a {
            res = res + "\(item)"
            if asRow {
                if let _ = del {
                    res = res + del!
                }
            }
            else {
                res = res + "\n"
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
    
    /// Returns true, if index is valif
    private func isValidIndex(index: Int) -> Bool {
        return index >= 0 && index < self.sampleSize
    }

    
    /// Returns the indexed element
    subscript(_ index: Int) -> SSElement? {
        assert(isValidIndex(index: index), "Index out of range")
        if !self.isEmpty {
            let a = self.elementsAsArray(sortOrder: .original)!
            return a[index]
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
    public func eCDF(_ item: SSElement) -> Double {
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

