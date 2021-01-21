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
import os.log
#endif

/** SSExamine
 This class contains all the data that you want to evaluate. SSExamine expects data that corresponds to the `Hashable`, `Comparable` and `Codable` protocols.
 Which statistics are available depends on the type of data. For nominal data, for example, an average will not be meaningful and will therefore not be calculated.
 If a certain statistical measure is not available, the result will be `nil`. It is therefore important that you check all results for this.
 
 SSExamine was primarily developed with Objective-C and had in particular the requirement to create frequency tables for the entered data and to update these
 tables whenever data was added or removed. Internally, the data is therefore stored in a kind of frequency table. If, for example, the element "A" occurs
 a 100 times in the data set to be evaluated, the element is not stored 100 times, but only once. At the same time, a reference to the frequency of thi
 element is saved.

 If elements are added to an SSExamine instance, the order of "arrival" is also registered. This makes it possible to reconstruct the "original data" from 
 an SSExamine instance.
 - Important:
    - `SSElement` = The Type of data to be processed.
    - `FPT` = The type of emitted statistics. Must conform to SSFloatingPoint
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
    Significance level to use, default: 0.05
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
    
    /** Indicates if there are changes
    */
    public var hasChanges: Bool! = false
    
    /** Defines the level of measurement
     */
    public var levelOfMeasurement: SSLevelOfMeasurement! = .interval
    
    /** If true, the instance contains numerical data
    */
    public var isNumeric: Bool! = true
    
    /** Returns the number of unique SSElements
     */
    public var length: Int {
        return items.count
    }
    
    /** Returns true, if count == 0, i.e. there are no data
    */
    public var isEmpty: Bool {
        return count == 0
    }
    
    /** The total number of observations (= sum of all absolute frequencies)
    */
    public var sampleSize: Int {
        return count
    }
    
    /** Returns a Dictionary<element<SSElement>,cumulative frequency<Double>>
    */
    public var cumulativeRelativeFrequencies: Dictionary<SSElement, FPT> {
        //        updateCumulativeFrequencies()
        return cumRelFrequencies
    }
    
    /**
    Returns a the hash for the instance.
    */
    public override var hash: Int {
        if !isEmpty {
            if let a = elementsAsArray(sortOrder: .raw) {
                var hasher = Hasher()
                hasher.combine(a)
                return hasher.finalize()
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    
    /// Overridden
    /// Two SSExamine objects are assumed to be equal, iff the arrays of all elements in unsorted order are equal.
    /// - Parameter object: The object to compare to
    /// - Important: Properties like "name" or "tag" are not included
    public override func isEqual(_ object: Any?) -> Bool {
        if let o: SSExamine<SSElement, FPT> = object as? SSExamine<SSElement, FPT> {
            if !self.isEmpty && !o.isEmpty {
                let a1 = self.elementsAsArray(sortOrder: .raw)!
                let a2 = o.elementsAsArray(sortOrder: .raw)!
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
        }
        else {
            self.tag = UUID.init().uuidString
            self.name = self.tag
        }
    }
    
    /// Initializes a SSExamine instance using a string or an array<SSElement>
    /// - Parameter object: The object used
    /// - Parameter name: The name of the instance.
    /// - Parameter characterSet: Set containing all characters to include by string analysis. If a type other than String is used, this parameter will be ignored. If a string is used to initialize the class and characterSet is nil, then all characters will be appended.
    /// - Parameter lom: Level of Measurement
    /// - Throws: SSSwiftyStatsError.missingData if object is not a string or an Array\<SSElement\>
    public init(withObject object: Any, levelOfMeasurement lom: SSLevelOfMeasurement, name: String?, characterSet: CharacterSet?) throws {
        // allow only arrays an strings as 'object'
        guard ((object is String && object is SSElement) || (object is Array<SSElement>)) else {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Error creating SSExamine instance", log: .log_dev, type: .error)
            }
            
            #endif
            
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
    
    /// Returns: New table by analyzing string. Taking characterSet into account, when set
    /// - Parameter array: The array containing the elements
    /// - Parameter characterSet: Set containing all characters to include by string analysis. If a type other than String is used, this parameter will be ignored. If a string is used to initialize the class and characterSet is nil, then all characters will be appended.
    public init(withArray array: Array<SSElement>, name: String?, characterSet: CharacterSet?) {
        super.init()
        createName(name: name)
        self.initializeWithArray(array)
    }
    
    
    /// Loads the content of a file interpreting the elements separated by `separator` as values using the specified encoding. Data are assumed to be numeric.
    ///
    /// The property `name`will be set to filename.
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter separator: The separator used in the file
    /// - Parameter stringEncoding: The encoding to use. Default: .utf8
    /// - Parameter elementsEnclosedBy: A string that encloses each element.
    /// - Throws: SSSwiftyStatsError if the file doesn't exist or can't be accessed.
    /// - Important: It is assumed that the elements are numeric.
    public class func examine(fromFile path: String, separator: String, elementsEnclosedBy: String? = nil, stringEncoding: String.Encoding = String.Encoding.utf8, _ parser: (String?) -> SSElement?) throws -> SSExamine<SSElement, FPT>? {
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
        let filename = NSURL(fileURLWithPath: fullFilename).lastPathComponent!
        var numberArray: Array<SSElement> = Array<SSElement>()
        var go: Bool = true
        do {
            let importedString = try String.init(contentsOfFile: fullFilename, encoding: stringEncoding)
            if importedString.contains(separator) {
                if importedString.count > 0 {
                    let temporaryStrings: Array<String> = importedString.components(separatedBy: separator)
                    let separatedStrings: Array<String>
                    if let e = elementsEnclosedBy {
                        separatedStrings = temporaryStrings.map( {
                            $0.replacingOccurrences(of: e, with: "")
                        } )
                    }
                    else {
                        separatedStrings = temporaryStrings
                    }
                    for string in separatedStrings {
                        if string.count > 0 {
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
            return SSExamine<SSElement, FPT>.init(withArray: numberArray, name: filename, characterSet: nil)
        }
        else {
            return nil
        }
    }
    
    /// Imitializes a new Instance from a json file created by `exportJSONString(fileName:, atomically:, overwrite:, stringEncoding:)`
    /// - Parameter path: The path to the file (e.g. ~/data/data.dat)
    /// - Parameter stringEncoding: The encoding to use.
    /// - Throws: if the file doesn't exist or can't be accessed or a the json file is invalid
    public class func examine(fromJSONFile path: String, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> SSExamine<SSElement, FPT>? {
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
        let url = URL.init(fileURLWithPath: fullFilename)
        if let jsonString = try? String.init(contentsOf: url), let data = jsonString.data(using: stringEncoding) {
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
    /// - Throws: SSSwiftyStatsError if the file could not be written
    public func exportJSONString(fileName path: String, atomically: Bool = true, overwrite: Bool, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
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
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Unable to write json", log: .log_fs, type: .error)
            }
            
            #endif
            
            return false
        }
    }
    
    /// TODO: enclose elements in ""
    /// Saves the object to the given path using the specified encoding.
    /// - Parameter path: Path to the file
    /// - Parameter atomically: If true, the object will be written to a temporary file first. This file will be renamed upon completion.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Parameter separator: Separator to use.
    /// - Parameter stringEncoding: String encoding
    /// - Parameter encloseElementsBy: Defaulf = nil
    /// - Throws: SSSwiftyStatsError if the file could not be written
    public func saveTo(fileName path: String, atomically: Bool = true, overwrite: Bool, separator: String = ",", encloseElementsBy: String? = nil, asRow: Bool = true, stringEncoding: String.Encoding = String.Encoding.utf8) throws -> Bool {
        var result = true
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
        if let s = elementsAsString(withDelimiter: separator, asRow: asRow, encloseElementsBy: encloseElementsBy) {
            do {
                try s.write(toFile: fullName, atomically: atomically, encoding: stringEncoding)
            }
            catch {
                #if os(macOS) || os(iOS)
                
                if #available(macOS 10.12, iOS 13, *) {
                    os_log("File could not be written", log: .log_fs, type: .error)
                }
                
                #endif
                
                result = false
            }
        }
        return result
    }
    
    /// Returns a SSExamine instance initialized using the string provided. Level of measurement will be set to .nominal.
    /// - Parameter string: String
    /// - Parameter characterSet: If characterSet is not nil, only characters contained in the set will be appended
    public class func examineWithString(_ string: String, name: String?, characterSet: CharacterSet?) -> SSExamine<String, FPT>? {
        do {
            let result:SSExamine<String, FPT> = try SSExamine<String, FPT>(withObject: string, levelOfMeasurement: .nominal, name: name,  characterSet: characterSet)
            return result
        }
        catch {
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Error creating SSExamine instance", log: .log_dev, type: .error)
            }
            
            #endif
            
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
        var offset: Int = 0
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
                for c: Character in string {
                    append(String(c) as! SSElement)
                }
            }
        }
    }
    
    
    /// Initializes a new instance using an array
    /// - Parameter array: The array containing the elements
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
    
    
    /// # Danger!!
    /// Sets default values, removes all items, reset all statistics.
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.name, forKey: CodingKeys.name)
        try container.encodeIfPresent(self.tag, forKey: CodingKeys.tag)
        try container.encodeIfPresent(self.descriptionString, forKey: CodingKeys.descriptionString)
        try container.encodeIfPresent(self._alpha, forKey: CodingKeys.alpha)
        try container.encodeIfPresent(self.levelOfMeasurement.rawValue, forKey: CodingKeys.levelOfMeasurement)
        try container.encodeIfPresent(self.isNumeric, forKey: CodingKeys.isNumeric)
        try container.encodeIfPresent(self.elementsAsArray(sortOrder: .raw), forKey: CodingKeys.data)
    }
    
    
    
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try container.decodeIfPresent(String.self, forKey: CodingKeys.tag)
        self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
        self.descriptionString = try container.decodeIfPresent(String.self, forKey: CodingKeys.descriptionString)
        self._alpha = try container.decodeIfPresent(FPT.self, forKey: CodingKeys.alpha) ?? FPT.zero
        if let lm = try container.decodeIfPresent(String.self, forKey: CodingKeys.levelOfMeasurement) {
            self.levelOfMeasurement = SSLevelOfMeasurement(rawValue:lm)
        }
        self.isNumeric = try container.decodeIfPresent(Bool.self, forKey: .isNumeric)
        if let data: Array<SSElement> = try container.decodeIfPresent(Array<SSElement>.self, forKey: CodingKeys.data) {
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
            let a: Array<SSElement> = elementsAsArray(sortOrder: .raw)!
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
            let temp = self.uniqueElements(sortOrder: .ascending)!
            var i: Int = 0
            cumRelFrequencies.removeAll()
            for key in temp {
                if i == 0 {
                    cumRelFrequencies[key] = rFrequency(key)
                }
                else {
                    cumRelFrequencies[key] = cumRelFrequencies[temp[i - 1]]! + rFrequency(key)
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
            let test = items.contains(where: { (key: SSElement, value: Int) -> Bool in
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
    /// - Parameter element: Item
    public func rFrequency(_ element: SSElement) -> FPT {
        //
        if let rf = self.elements[element] {
            return  Helpers.makeFP(rf) /  Helpers.makeFP(self.sampleSize)
        }
        else {
            return 0
        }
    }
    
    /// Returns the absolute frequency of item
    /// - Parameter element: Item
    public func frequency(_ element: SSElement) -> Int {
        if contains(element) {
            return items[element]!
        }
        else {
            return 0
        }
    }
    
    /// Appends <item> and updates frequencies
    /// - Parameter element: Item
    public func append(_ element: SSElement) {
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
            sequence[element]!.append(count)
        }
        else {
            items[element] = 1
            count = count + 1
            tempPos = Array()
            tempPos.append(count)
            sequence[element] = tempPos
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends n elements
    /// - Parameter n: Count of elements to append
    /// - Parameter elements: Item to append
    public func append(repeating n: Int, element: SSElement) {
        for _ in 1...n {
            append(element)
        }
        updateCumulativeFrequencies()
    }
    
    /// Appends elements from an array
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
            #if os(macOS) || os(iOS)
            
            if #available(macOS 10.12, iOS 13, *) {
                os_log("Can only append strings", log: .log_stat, type: .error)
            }
            
            #endif
            
            throw SSSwiftyStatsError(type: .invalidArgument, file: #file, line: #line, function: #function)
        }
        else {
            var index: String.Index = text.startIndex
            var offset: Int = 0
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
                    for c: Character in text {
                        append(String(c) as! SSElement)
                    }
                }
            }
        }
    }
    
    /// Removes item from the table.
    /// - Parameter item: Item
    /// - Parameter allOccurences: If false, only the first item found will be removed. Default: false
    public func remove(_ element: SSElement, allOccurences all: Bool = false) {
        if !isEmpty {
            if contains(element) {
                var temp: Array<SSElement> = elementsAsArray(sortOrder: .raw)!
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
    /// - Parameter del: The delimiter. Can be nil or empty.
    /// - Parameter asRow: If true, the parameter `del` will be omitted. The Name of the instance will ve used as header for the row
    /// - Parameter encloseElementsBy: Default: nil.
    public func elementsAsString(withDelimiter del: String?, asRow: Bool = true, encloseElementsBy: String? = nil) -> String? {
        let a: Array<SSElement> = elementsAsArray(sortOrder: .raw)!
        var res: String = String()
        if !asRow {
            if let n = self.name {
                res = res + n + "\n"
            }
        }
        for item in a {
            if let e = encloseElementsBy {
                res = res + e + "\(item)" + e
            }
            else {
                res = res + "\(item)"
            }
            if asRow {
                if let d = del {
                    res = res + d
                }
            }
            else {
                res = res + "\n"
            }
        }
        if let d = del {
            if d.count > 0 {
                for _ in 1...d.count {
                    res = String(res.dropLast())
                }
            }
        }
        if res.count > 0 {
            return res
        }
        else {
            return nil
        }
    }
    
    /// Returns true, if index is valid
    private func isValidIndex(index: Int) -> Bool {
        return index >= 0 && index < self.sampleSize
    }
    
    
    /// Returns the indexed element
    subscript(_ index: Int) -> SSElement? {
        if isValidIndex(index: index) {
            if !self.isEmpty {
                let a = self.elementsAsArray(sortOrder: .raw)!
                return a[index]
            }
            else {
                return nil
            }
        }
        else {
            fatalError("Index out of range")
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
            case .raw:
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
    /// - Parameter sortOrder: Sorting order
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

