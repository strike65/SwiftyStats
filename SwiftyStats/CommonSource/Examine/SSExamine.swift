//
//  SSExamine.swift
//  SwiftyStats
//
//  Created by strike65 on 01.07.17.
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
import OSLog
#endif

/** SSExamine
 Holds the data to be analyzed. `SSExamine` expects elements that conform to the `Hashable`, `Comparable`, and `Codable` protocols.
 Which statistics are available depends on the element type. For nominal data, for example, a mean is not meaningful and is therefore not calculated.
 If a particular statistic is not available, the result is `nil`. Ensure you check results for `nil` where appropriate.

 `SSExamine` was originally developed in Objective‑C with a focus on creating frequency tables for the provided data and keeping them up to date as
 elements are added or removed. Internally, the data is stored in a frequency‑table–like structure. For example, if the element "A" occurs 100 times,
 it is stored only once together with a reference to its frequency.

 When elements are added to an `SSExamine` instance, their insertion order is recorded as well. This allows you to reconstruct the original data sequence
 from an `SSExamine` instance.
 - Important:
    - `SSElement`: The type of data to be processed.
    - `FPT`: The type used for computed statistics. Must conform to `SSFloatingPoint`.
 */
public class SSExamine<SSElement, FPT>:  NSObject, SSExamineContainer, NSCopying, Codable where SSElement: Hashable & Comparable & Codable, FPT: SSFloatingPoint, FPT: Codable {
    
    
    // MARK: OPEN/PUBLIC VARS
    
    /**
        An object representing the content of the SSExamine instance (experimental).
        A placeholder to specify the type of stored data.
     */
    public var rootObject: Any?
    
    /**
     User defined tag
    */
    public var tag: String?
    
    /**
     Human readable description
     */
    public var descriptionString: String?
    
    /**
    Name of the table
     */
    public var name: String?
    
    /**
    Significance level to use. Default: 0.05
     */
    private var _alpha: FPT = FPT.zero
    
    public var alpha: FPT {
        get {
            return _alpha
        }
        set(newAlpha) {
            _alpha = newAlpha
        }
    }
    
    /** Indicates whether there are changes. */
    public var hasChanges: Bool = false
    
    /** Defines the level of measurement. */
    public var levelOfMeasurement: SSLevelOfMeasurement = .interval
    
    /** If true, the instance contains numerical data. */
    public var isNumeric: Bool = true
    
    /** Returns the number of unique elements. */
    public var length: Int {
        return items.count
    }
    
    /** Returns true if `count == 0`, i.e., there is no data. */
    public var isEmpty: Bool {
        return count == 0
    }
    
    /** The total number of observations (= sum of all absolute frequencies). */
    public var sampleSize: Int {
        return count
    }
    
    /** Returns a `Dictionary<element<SSElement>, cumulative frequency<FPT>>`. */
    public var cumulativeRelativeFrequencies: Dictionary<SSElement, FPT> {
        updateCumulativeFrequencies()
        return cumRelFrequencies
    }
    
    /** Returns the hash for the instance. */
    public override var hash: Int {
        if !isEmpty {
            let a = elementsAsArray(sortOrder: .raw)
            var hasher = Hasher()
            hasher.combine(a)
            return hasher.finalize()
        } else {
            return 0
        }
    }
    
    
    /// Overridden.
    /// Two `SSExamine` objects are considered equal if the arrays of all elements in unsorted order are equal.
    /// - Parameter object: The object to compare to
    /// - Important: Properties like `name` or `tag` are not considered.
    public override func isEqual(_ object: Any?) -> Bool {
        if let o: SSExamine<SSElement, FPT> = object as? SSExamine<SSElement, FPT> {
            if !self.isEmpty && !o.isEmpty {
                let a1 = self.elementsAsArray(sortOrder: .raw)
                let a2 = o.elementsAsArray(sortOrder: .raw)
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
    
    
    /// Returns all unique elements as a Dictionary \<element\<SSElement\>:frequency\<Int\>\>
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
    private var relFrequencies: Dictionary<SSElement, FPT> = [:]
    private var cumRelFrequencies: Dictionary<SSElement, FPT> = [:]
    private var cumulativeFrequenciesDirty: Bool = true
    private var allItemsAscending: Array<SSElement> = []
    
    internal var aMean: FPT? = nil
    
    // sum over all absolute frequencies (= sampleSize)
    private var count: Int = 0
    
    // MARK: INITIALIZERS
    
    //: General initializer.
    public override init() {
        super.init()
        initializeSSExamine()
    }
    
    
    private func createName(name: String?) {
        if let n = name {
            self.name = n
        } else {
            self.tag = UUID().uuidString
            self.name = self.tag
        }
    }
    
    /// Initializes an `SSExamine` instance from a `String` or `Array<SSElement>`.
    /// - Parameter object: The source object
    /// - Parameter name: The name of the instance.
    /// - Parameter characterSet: Set containing all characters to include by string analysis. If a type other than String is used, this parameter will be ignored. If a string is used to initialize the class and characterSet is nil, then all characters will be appended.
    /// - Parameter lom: Level of Measurement
    /// - Throws: SSSwiftyStatsError.missingData if object is not a string or an Array\<SSElement\>
    public init(withObject object: Any, levelOfMeasurement lom: SSLevelOfMeasurement, name: String?, characterSet: CharacterSet?) throws {
        // allow only arrays and strings as 'object'
        guard ((object is String && object is SSElement) || (object is Array<SSElement>)) else {
            SSLog.devError("Error creating SSExamine instance")
            
            throw SSSwiftyStatsError(type: .missingData, file: #file, line: #line, function: #function)
        }
        super.init()
        createName(name: name)
        self.levelOfMeasurement = lom
        if object is String  {
            self.levelOfMeasurement = .nominal
            self.initializeWithString(string: object as! String, characterSet: characterSet)
        }
        else if object is Array<SSElement> {
            self.initializeWithArray((object as! Array<SSElement>))
        }
    }
    
    /// Initializes an `SSExamine` instance from an array.
    /// - Parameter array: The array containing the elements.
    /// - Parameter name: Name of the instance
    ///- Parameter characterSet: Only used when initialized from a string; ignored here.
    public init(withArray array: Array<SSElement>, name: String?, characterSet: CharacterSet?) {
        super.init()
        createName(name: name)
        self.initializeWithArray(array)
    }
    
    
    /// Loads the content of a file, interpreting elements separated by `separator` as values using the specified encoding. Data are assumed to be numeric.
    ///
    /// The property `name` will be set to the filename.
    /// - Parameter path: The path to the file (e.g., `~/data/data.dat`).
    /// - Parameter separator: The separator used in the file
    /// - Parameter stringEncoding: The encoding to use. Default: .utf8
    /// - Parameter elementsEnclosedBy: A string that encloses each element.
    /// - Parameter parser: Closure that converts each extracted String token into an `SSElement` (return `nil` to skip/abort)
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed.
    /// - Important: It is assumed that the elements are numeric.
    public class func examine(fromFile path: String, separator: String, elementsEnclosedBy: String? = nil, stringEncoding: String.Encoding = String.Encoding.utf8, _ parser: (String?) -> SSElement?) throws -> SSExamine<SSElement, FPT>? {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            SSLog.fsError("File not found")
            
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        let filename = URL(fileURLWithPath: fullFilename).lastPathComponent
        var numberArray: Array<SSElement> = Array<SSElement>()
        var go: Bool = true
        do {
            let importedString = try String(contentsOfFile: fullFilename, encoding: stringEncoding)
            if importedString.contains(separator) {
                if !importedString.isEmpty {
                    let temporaryStrings: Array<String> = importedString.components(separatedBy: separator)
                    let separatedStrings: Array<String>
                    if let e = elementsEnclosedBy {
                        separatedStrings = temporaryStrings.map { $0.replacingOccurrences(of: e, with: "") }
                    } else {
                        separatedStrings = temporaryStrings
                    }
                    for string in separatedStrings where !string.isEmpty {
                        if let value = parser(string) {
                            numberArray.append(value)
                        } else {
                            go = false
                            break
                        }
                    }
                }
            } else {
                return nil
            }
        }
        catch {
            return nil
        }
        if go {
            return SSExamine<SSElement, FPT>.init(withArray: numberArray, name: filename, characterSet: nil)
        }
        else {
            return nil
        }
    }
    
    /// Initializes a new instance from a JSON file created by `exportJSONString(fileName:atomically:overwrite:stringEncoding:)`.
    /// - Parameter path: The path to the file (e.g., `~/data/data.dat`).
    /// - Parameter stringEncoding: The encoding to use.
    /// - Throws: If the file doesn't exist, can't be accessed, or the JSON is invalid.
    public class func examine(fromJSONFile path: String, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> SSExamine<SSElement, FPT>? {
        let fileManager = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fileManager.fileExists(atPath: fullFilename) || !fileManager.isReadableFile(atPath: fullFilename) {
            SSLog.fsError("File not found")
            
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        let url = URL(fileURLWithPath: fullFilename)
        if let jsonString = try? String(contentsOf: url, encoding: stringEncoding), let data = jsonString.data(using: stringEncoding) {
            do {
                let result = try JSONDecoder().decode(SSExamine<SSElement, FPT>.self, from: data)
                return result as SSExamine<SSElement, FPT>
            }
            catch {
                throw error
            }
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
    /// - Throws: `SSSwiftyStatsError` if the file could not be written or directory is invalid/unwritable
    public func exportJSONString(fileName path: String, atomically: Bool = true, overwrite: Bool, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
        let fileManager = FileManager.default
        let fullName = NSString(string: path).expandingTildeInPath
        let dir = NSString(string: fullName).deletingLastPathComponent
        // Ensure parent directory exists (failsafe)
        var isDir = ObjCBool(false)
        if !fileManager.fileExists(atPath: dir, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                SSLog.fsError("Unable to create directory for export: \(dir)")
                throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
            }
        } else if !isDir.boolValue {
            SSLog.fsError("Parent path is not a directory: \(dir)")
            throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
        }

        if fileManager.fileExists(atPath: fullName) {
            if !overwrite {
                SSLog.fsError("File already exists")
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            } else {
                do {
                    try fileManager.removeItem(atPath: fullName)
                } catch {
                    SSLog.fsError("Can't remove file before writing")
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            }
        }

        let jsonEncode = JSONEncoder()
        let data = try jsonEncode.encode(self)
        guard let jsonString = String(data: data, encoding: stringEncoding) else { return false }
        do {
            try jsonString.write(to: URL(fileURLWithPath: fullName), atomically: atomically, encoding: stringEncoding)
            return true
        } catch {
            SSLog.fsError("Unable to write JSON: \(error.localizedDescription)")
            throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
        }
    }
    
    /// TODO: Enclose elements in quotes.
    /// Saves the object to the given path using the specified encoding.
    /// - Parameter path: Path to the file
    /// - Parameter atomically: If true, the object will be written to a temporary file first. This file will be renamed upon completion.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Parameter separator: Separator to use.
    /// - Parameter stringEncoding: String encoding
    /// - Parameter encloseElementsBy: Default = nil
    /// - Parameter asRow: If true, writes elements on a single line; otherwise includes a header row with `name` and line breaks
    /// - Throws: SSSwiftyStatsError if the file could not be written
    public func saveTo(fileName path: String, atomically: Bool = true, overwrite: Bool, separator: String = ",", encloseElementsBy: String? = nil, asRow: Bool = true, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
        let fileManager = FileManager.default
        let fullName = NSString(string: path).expandingTildeInPath
        let dir = NSString(string: fullName).deletingLastPathComponent
        // Ensure parent directory exists (failsafe)
        var isDir = ObjCBool(false)
        if !fileManager.fileExists(atPath: dir, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                SSLog.fsError("Unable to create directory for export: \(dir)")
                throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
            }
        } else if !isDir.boolValue {
            SSLog.fsError("Parent path is not a directory: \(dir)")
            throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
        }

        if fileManager.fileExists(atPath: fullName) {
            if !overwrite {
                SSLog.fsError("File already exists")
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            } else {
                do {
                    try fileManager.removeItem(atPath: fullName)
                } catch {
                    SSLog.fsError("Can't remove file before writing")
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            }
        }

        guard let s = elementsAsString(withDelimiter: separator, asRow: asRow, encloseElementsBy: encloseElementsBy) else { return false }
        do {
            try s.write(toFile: fullName, atomically: atomically, encoding: stringEncoding)
            return true
        } catch {
            SSLog.fsError("File could not be written: \(error.localizedDescription)")
            throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
        }
    }
    
    /// Returns a SSExamine instance initialized using the string provided. Level of measurement will be set to .nominal.
    /// - Parameter string: Input string
    /// - Parameter name: Optional name for the created instance
    /// - Parameter characterSet: If not nil, only characters contained in the set will be appended
    public class func examineWithString(_ string: String, name: String?, characterSet: CharacterSet?) -> SSExamine<String, FPT>? {
        do {
            let result:SSExamine<String, FPT> = try SSExamine<String, FPT>(withObject: string, levelOfMeasurement: .nominal, name: name,  characterSet: characterSet)
            return result
        }
        catch {
            SSLog.devError("Error creating SSExamine instance")
            
            return nil
        }
    }
    
    
    
    /// Initializes the table using a string. Appends only characters contained in `characterSet`.
    /// - Parameter string: String
    /// - Parameter characterSet: If not nil, only characters contained in the set will be appended.
    private func initializeWithString(string: String, characterSet: CharacterSet?) {
        initializeSSExamine()
        isNumeric = false
        if !string.isEmpty {
            if let cs: CharacterSet = characterSet {
                for scalar in string.unicodeScalars where cs.contains(scalar) {
                    append(String(scalar) as! SSElement)
                }
            } else {
                for c in string {
                    append(String(c) as! SSElement)
                }
            }
        }
    }
    
    
    /// Initializes a new instance using an array.
    /// - Parameter array: The array containing the elements.
    private func initializeWithArray(_ array: Array<SSElement>) {
        initializeSSExamine()
        if array.count > 0 {
            if Helpers.isNumber(array.first) {
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
    
    
    /// Danger: Resets state.
    /// Sets default values, removes all items, and resets all statistics.
    fileprivate func initializeSSExamine() {
        sequence.removeAll()
        items.removeAll()
        relFrequencies.removeAll()
        cumRelFrequencies.removeAll()
        count = 0
        descriptionString = "SSExamine Instance - standard"
        alpha = Helpers.makeFP(0.05)
        hasChanges = false
        isNumeric = true
        aMean = nil
        cumulativeFrequenciesDirty = true
    }
    
    // MARK: Codable protocol
    
    /// All the coding keys to encode
    private enum CodingKeys: String, CodingKey {
        case tag = "TAG"
        case name
        case descriptionString
        case alpha
        case levelOfMeasurement
        case isNumeric
        case data
    }
    
    /// Encodes the receiver into the given encoder.
    /// - Parameter encoder: The encoder to write data to
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.tag, forKey: .tag)
        try container.encodeIfPresent(self.descriptionString, forKey: .descriptionString)
        try container.encode(self._alpha, forKey: .alpha)
        try container.encode(self.levelOfMeasurement, forKey: .levelOfMeasurement)
        try container.encode(self.isNumeric, forKey: .isNumeric)
        if !self.isEmpty {
            try container.encode(self.elementsAsArray(sortOrder: .raw), forKey: .data)
        }
    }
    
    
    
    /// Creates a new instance by decoding from the given decoder.
    /// - Parameter decoder: The decoder to read data from
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try container.decodeIfPresent(String.self, forKey: CodingKeys.tag)
        self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
        self.descriptionString = try container.decodeIfPresent(String.self, forKey: CodingKeys.descriptionString)
        self._alpha = try container.decodeIfPresent(FPT.self, forKey: .alpha) ?? FPT.zero
        self.levelOfMeasurement = try container.decodeIfPresent(SSLevelOfMeasurement.self, forKey: .levelOfMeasurement) ?? .interval
        self.isNumeric = try container.decodeIfPresent(Bool.self, forKey: .isNumeric) ?? true
        if let data: Array<SSElement> = try container.decodeIfPresent(Array<SSElement>.self, forKey: CodingKeys.data) {
            self.initializeWithArray(data)
        }
    }
    
    
    
    // MARK: NSCopying
    /// Returns a copy of the instance.
    /// - Parameter zone: Memory zone to use (ignored)
    public func copy(with zone: NSZone? = nil) -> Any {
        let res: SSExamine = SSExamine()
        if !isEmpty {
            res.tag = self.tag
            res.descriptionString = self.descriptionString
            res.name = self.name
            res.alpha = self.alpha
            res.levelOfMeasurement = self.levelOfMeasurement
            res.hasChanges = self.hasChanges
            let a: Array<SSElement> = elementsAsArray(sortOrder: .raw)
            for item in a {
                res.append(item)
            }
        }
        return res
    }
    
    /// Updates cumulative frequencies
    private func updateCumulativeFrequencies() {
        // Lazy recomputation only when needed
        guard cumulativeFrequenciesDirty else { return }
        guard !isEmpty else {
            cumRelFrequencies.removeAll()
            cumulativeFrequenciesDirty = false
            return
        }
        let temp = self.uniqueElements(sortOrder: .ascending)
        cumRelFrequencies.removeAll(keepingCapacity: true)
        var previousKey: SSElement? = nil
        for key in temp {
            if let prev = previousKey, let prevVal = cumRelFrequencies[prev] {
                cumRelFrequencies[key] = prevVal + rFrequency(key)
            } else {
                cumRelFrequencies[key] = rFrequency(key)
            }
            previousKey = key
        }
        allItemsAscending = temp
        cumulativeFrequenciesDirty = false
    }
    
    // MARK: SSExamineContainer Protocol
    
    /// Returns true if the table contains the given element.
    /// - Parameter element: Element to search for
    public func contains(_ element: SSElement) -> Bool {
        return items[element] != nil
    }
    
    
    /// Returns the relative frequency of the given element.
    /// - Parameter element: Element
    public func rFrequency(_ element: SSElement) -> FPT {
        if let rf = self.elements[element] {
            return Helpers.makeFP(rf) / Helpers.makeFP(self.sampleSize)
        } else {
            return 0
        }
    }
    
    /// Returns the absolute frequency of the given element.
    /// - Parameter element: Element
    public func frequency(_ element: SSElement) -> Int {
        return items[element] ?? 0
    }
    
    /// Appends the given element and updates frequencies.
    /// - Parameter element: Element to append
    public func append(_ element: SSElement) {
        var tempPos: Array<Int>
        if let current = items[element] {
            let newFrequency = current + 1
            items[element] = newFrequency
            count += 1
            sequence[element]!.append(count)
        } else {
            items[element] = 1
            count += 1
            tempPos = [count]
            sequence[element] = tempPos
        }
        cumulativeFrequenciesDirty = true
    }
    
    /// Appends the given element `n` times and updates frequencies.
    /// - Parameter n: Number of times to append
    /// - Parameter element: Element to append repeatedly
    public func append(repeating n: Int, element: SSElement) {
        guard n > 0 else { return }
        for _ in 0..<n {
            append(element)
        }
        cumulativeFrequenciesDirty = true
    }
    
    /// Appends elements from an array.
    /// - Parameter array: Array containing elements to add
    public func append(contentOf array: Array<SSElement>) {
        if array.count > 0 {
            if isEmpty {
                if Helpers.isNumber(array.first) {
                    isNumeric = true
                }
                else {
                    isNumeric = false
                }

            }
            for item in array {
                append(item)
            }
        }
    }
    
    /// Appends the characters of the given string. Only characters contained in the character set are appended.
    /// - Parameter text: The text
    /// - Parameter characterSet: A CharacterSet containing the characters to include. If nil, all characters of text will be appended.
    /// - Throws: SSSwiftyStatsError if <SSElement> of the receiver is not of type String
    public func append(text: String, characterSet: CharacterSet?) throws {
        if !(SSElement.self is String.Type) {
            SSLog.statError("Can only append strings")
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        else {
            if !text.isEmpty {
                if let cs: CharacterSet = characterSet {
                    for scalar in text.unicodeScalars where cs.contains(scalar) {
                        append(String(scalar) as! SSElement)
                    }
                } else {
                    for c in text {
                        append(String(c) as! SSElement)
                    }
                }
            }
        }
    }
    
    /// Removes an element from the table.
    /// - Parameter element: Element to remove
    /// - Parameter all: If true, remove all occurrences; if false, remove only the first match (default: false)
    public func remove(_ element: SSElement, allOccurences all: Bool = false) {
        if !isEmpty {
            if contains(element) {
                var temp: Array<SSElement> = elementsAsArray(sortOrder: .raw)
                // remove all elements
                if all {
                    temp = temp.filter({ $0 != element})
                }
                else {
                    // remove only the first occurrence
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
                cumulativeFrequenciesDirty = true
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
        cumulativeFrequenciesDirty = true
    }
    
    
    
}


extension SSExamine {
    
    // MARK: Elements
    
    /// Returns all elements as one string. Elements are delimited by `del`.
    /// - Parameter del: The delimiter. Can be nil or empty.
    /// - Parameter asRow: If true, writes a single line; otherwise a header line with `name` is included and elements are written on separate lines.
    /// - Parameter encloseElementsBy: Optional string used to enclose every element (default: nil)
    public func elementsAsString(withDelimiter del: String?, asRow: Bool = true, encloseElementsBy: String? = nil) -> String? {
        let a = elementsAsArray(sortOrder: .raw)
        let parts: [String] = a.map { item in
            let itemString = "\(item)"
            if let e = encloseElementsBy, !e.isEmpty {
                // Escape any enclosure characters inside the element by doubling them (CSV-style)
                let escaped = itemString.replacingOccurrences(of: e, with: e + e)
                return e + escaped + e
            } else {
                return itemString
            }
        }
        var res: String
        if asRow {
            res = parts.joined(separator: del ?? "")
        } else {
            var lines: [String] = []
            if let n = self.name {
                lines.append(n)
            }
            lines.append(contentsOf: parts)
            res = lines.joined(separator: "\n")
        }
        return res.isEmpty ? nil : res
    }
    
    /// Returns true if index is valid.
    private func isValidIndex(index: Int) -> Bool {
        return index >= 0 && index < self.sampleSize
    }
    
    
    /// Returns the indexed element
    subscript(_ index: Int) -> SSElement? {
        if isValidIndex(index: index), !self.isEmpty {
            let a = self.elementsAsArray(sortOrder: .raw)
            return a[index]
        } else {
            return nil
        }
    }
    
    /// Returns an array containing all elements.
    /// - Parameter sortOrder: The sort sortOrder.
    /// - Returns: An array containing all elements sortOrdered as specified.
    public func elementsAsArray(sortOrder: SSDataArraySortOrder) -> Array<SSElement> {
        if isEmpty { return [] }
        var temp: Array<SSElement> = []
        var result: Array<SSElement>
        for (item, freq) in self.elements {
            for _ in 1...freq { temp.append(item) }
        }
        switch sortOrder {
        case .ascending:
            result = temp.sorted(by: { $0 < $1 })
        case .descending:
            result = temp.sorted(by: { $0 > $1 })
        case .none:
            result = temp
        case .raw:
            temp.removeAll(keepingCapacity: true)
            for _ in 1...self.sampleSize {
                temp.append(self.elements.keys[self.elements.keys.startIndex])
            }
            for (item, seq) in self.sequences {
                for i in seq { temp[i - 1] = item }
            }
            result = temp
        }
        return result
    }
    
    /// Returns an array containing all unique elements.
    /// - Parameter sortOrder: Sorting order
    public func uniqueElements(sortOrder: SSSortUniqeItems) -> Array<SSElement> {
        if isEmpty { return [] }
        var temp: [SSElement] = []
        for (item, _) in self.elements { temp.append(item) }
        switch sortOrder {
        case .ascending:
            return temp.sorted(by: { $0 < $1 })
        case .descending:
            return temp.sorted(by: { $0 > $1 })
        case .none:
            return temp
        }
    }
    
    // MARK: Frequencies
    
    /// Returns the frequency table as an array, ordered as speciefied.
    /// - Parameter sortOrder: SSFrequencyTableSortsortOrder
    public func frequencyTable(sortOrder: SSFrequencyTableSortOrder) -> Array<SSFrequencyTableItem<SSElement, FPT>> {
        var result = Array<SSFrequencyTableItem<SSElement,FPT>>()
        var tableItem: SSFrequencyTableItem<SSElement,FPT>
        if self.sampleSize > 0 {
            let n = Double(self.sampleSize)
            for (item, freq) in self.elements {
                let f: Double = Double(freq)
                tableItem = SSFrequencyTableItem<SSElement,FPT>(withItem: item, relativeFrequency:  Helpers.makeFP(f) /  Helpers.makeFP(n), frequency: freq)
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
    public func cumulativeFrequencyTable(format: SSCumulativeFrequencyTableFormat) -> Array<SSCumulativeFrequencyTableItem<SSElement, FPT>> {
        var tableItem: SSCumulativeFrequencyTableItem<SSElement,FPT>
        var cumRelFreq: FPT = 0
        var cumAbsFreq: FPT = 0
        var result = Array<SSCumulativeFrequencyTableItem<SSElement,FPT>>()
        let frequencyTable = self.frequencyTable(sortOrder: .valueAscending)
        switch format {
        case .eachUniqueItem:
            for fItem:SSFrequencyTableItem<SSElement,FPT> in frequencyTable {
                cumAbsFreq = cumAbsFreq +  Helpers.makeFP(fItem.frequency)
                cumRelFreq = cumRelFreq + fItem.relativeFrequency
                for _ in (Helpers.integerValue(cumAbsFreq) - fItem.frequency)...(Helpers.integerValue(cumAbsFreq) - 1) {
                    tableItem = SSCumulativeFrequencyTableItem<SSElement,FPT>(withItem: fItem.item, cumulativeRelativeFrequency: cumRelFreq, cumulativefrequency: Helpers.integerValue(cumAbsFreq))
                    result.append(tableItem)
                }
            }
        case .eachItem:
            for fItem:SSFrequencyTableItem<SSElement, FPT> in frequencyTable {
                cumAbsFreq = cumAbsFreq +  Helpers.makeFP(fItem.frequency)
                cumRelFreq = cumRelFreq + fItem.relativeFrequency
                tableItem = SSCumulativeFrequencyTableItem<SSElement, FPT>(withItem: fItem.item, cumulativeRelativeFrequency: cumRelFreq, cumulativefrequency: Helpers.integerValue(cumAbsFreq))
                result.append(tableItem)
            }
        }
        return result
    }
    
    /// Empirical CDF of item
    /// - Parameter item: The item for which the cdf will be returned.
    public func eCDF(_ item: SSElement) -> FPT {
        var result: FPT = FPT.nan
        if let min = self.minimum, let max = self.maximum {
            if item < min {
                return 0
            }
            else if item > max {
                return 1
            }
            if self.contains(item) {
                result = self.cumulativeRelativeFrequencies[item]!
            } else {
                for itm in self.uniqueElements(sortOrder: .ascending) where itm < item {
                    result = self.cumulativeRelativeFrequencies[itm]!
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
