//
//  SSSwiftyStatsError.swift
//  SwiftyStats
//
//  Created by Volker Thieme on 02.07.17.
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



/// Custom error class
public class SSSwiftyStatsError: NSError, LocalizedError {
    public var type: ErrorType = .none
    public var line: Int = 0
    public var function: String = ""
    public var file: String = ""
    /// Error codes
    public enum ErrorType: Int {
        /// No error
        case none
        /// Invalid argments
        case invalidArgument
        /// Index out of range
        case indexOutOfRange
        /// Row-Index out of range
        case rowIndexOutOfRange
        /// Column-Index out of range
        case columnIndexOutOfRange
        /// Row-name unknown
        case rowNameUnknown
        /// Column name unknown
        case columnNameUnknown
        /// Function called is not available for the parameter given
        case functionNotDefinedInDomainProvided
        /// Missing data
        case missingData
        /// Wrong data format
        case wrongDataFormat
        /// Size mismatch
        case sizeMismatch
        /// Max. Iteration count reached
        case maxNumberOfIterationReached
        /// Only available for numerical elements
        case availableOnlyForNumbers
        /// Posix error
        case posixError
        /// File not accessible
        case fileNotWriteable
        /// Directory does not exist
        case directoryDoesNotExist
        /// File doesn't exist
        case fileNotFound
        /// File exists
        case fileExists
        /// Can't create object
        case errorCreatingObject
    }

    /// A string describing the error
    override public var localizedDescription: String {
        switch self.type {
        case .none:
            return "No error"
        case .invalidArgument:
            return "Invalid argument in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .indexOutOfRange:
            return "Index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .rowIndexOutOfRange:
            return "Row index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .columnIndexOutOfRange:
            return "Column index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .rowNameUnknown:
            return "Unknown row name in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .columnNameUnknown:
            return "Unknown column name in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .functionNotDefinedInDomainProvided:
            return "Called function is not defined in that domain in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .missingData:
            return "Missing data in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .wrongDataFormat:
            return "Wrong data format in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .sizeMismatch:
            return "Size mismatch in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .maxNumberOfIterationReached:
            return "Maximum number of iterations reached in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .availableOnlyForNumbers:
            return "Only available for numbers in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .posixError:
            return "POSIX error in:" + self.file + " Line: \(self.line) in function: " + self.function
        case .fileNotWriteable:
            return "File not writeable error in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .fileExists:
            return "File not writeable because file already exists in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .directoryDoesNotExist:
            return "Directory does not exist in :" + self.file + " Line: \(self.line) in function: " + self.function
        case .fileNotFound:
            return "File does not exist in :" + self.file + " Line: \(self.line) in function: " + self.function
        case .errorCreatingObject:
            return "Unable to create examine object :" + self.file + " Line: \(self.line) in function: " + self.function
        }
    }
    
    /// A string describing the reason for failure
    override public var localizedFailureReason: String? {
        return "A Reason"
    }

//    override public var localizedRecoverySuggestion: String? {
//        return "try it again"
//    }
    
    /// Init
    public init(type: ErrorType, file: String, line: Int, function: String) {
        super.init(domain: "de.swiftystats.SSSwiftyStats", code: type.rawValue, userInfo: nil)
        self.type = type
        self.line = line
        self.function = function
        self.file = file
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    public override var userInfo: [AnyHashable : Any] {
//        switch type {
//            case .none:
//                return ["description":"No error", "originalError": ""]
//            case .invalidArgument:
//                return ["description": "Invalid argument in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .indexOutOfRange:
//            return "Index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .rowIndexOutOfRange:
//            return "Row index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .columnIndexOutOfRange:
//            return "Column index out of range in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .rowNameUnknown:
//            return "Unknown row name in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .columnNameUnknown:
//            return "Unknown column name in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .functionNotDefinedInDomainProvided:
//            return "Called function is not defined in that domain in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .missingData:
//            return "Missing data in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .wrongDataFormat:
//            return "Wrong data format in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .sizeMismatch:
//            return "Size mismatch in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .maxNumberOfIterationReached:
//            return "Maximum number of iterations reached in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .availableOnlyForNumbers:
//            return "Only available for numbers in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .posixError:
//            return "POSIX error in:" + self.file + " Line: \(self.line) in function: " + self.function
//            case .fileNotReadable:
//            return "File not readable error in: " + self.file + " Line: \(self.line) in function: " + self.function
//            case .directoryDoesNotExist:
//            return "Directory does not exist in :" + self.file + " Line: \(self.line) in function: " + self.function
//        }
//    }
}

