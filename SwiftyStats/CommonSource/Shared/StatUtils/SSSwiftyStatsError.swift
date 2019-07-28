//
//  SSSwiftyStatsError.swift
//  SwiftyStats
//
//  Created by strike65 on 02.07.17.
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
        case unknownRowName
        /// Column name unknown
        case unknownColumnName
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
        /// internal error - contact developer
        case internalError
        /// singularity
        case singularity
        /// number to big (hypergeometricPFQ)
        case maxExponentExceeded
    }
    
    override public var description: String {
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
        case .unknownRowName:
            return "Unknown row name in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .unknownColumnName:
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
        case .internalError:
            return "Fatal internal error:" + self.file + " Line: \(self.line) in function: " + self.function + ". Contact developer."
        case .singularity:
            return "Argument singularity :" + self.file + " Line: \(self.line) in function: " + self.function + ". Function will return INF."
        case .maxExponentExceeded:
            return "Value of exponent required for summation (pFq):" + self.file + " Line: \(self.line) in function: " + self.function + ". Hints: (1) try using lnpfq = 1 or (2) use Float80."
            
        }
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
        case .unknownRowName:
            return "Unknown row name in: " + self.file + " Line: \(self.line) in function: " + self.function
        case .unknownColumnName:
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
        case .internalError:
            return "Fatal internal error:" + self.file + " Line: \(self.line) in function: " + self.function + ". Contact developer."
        case .singularity:
            return "Argument singularity :" + self.file + " Line: \(self.line) in function: " + self.function + ". Function will return INF."
        case .maxExponentExceeded:
            return "Value of exponent required for summation (pFq):" + self.file + " Line: \(self.line) in function: " + self.function + ". Hints: (1) try using lnpfq = 1 or (2) use Float80."

        }
    }
    
    /// A string describing the reason for failure
    override public var localizedFailureReason: String? {
        return "A Reason"
    }

    /// Init
    public init(type: ErrorType, file: String, line: Int, function: String) {
        super.init(domain: "de.strike65.SSSwiftyStats", code: type.rawValue, userInfo: nil)
        self.type = type
        self.line = line
        self.function = function
        self.file = file
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

