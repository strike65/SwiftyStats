//
//  SSExamine-FileManagement.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
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



extension SSExamine {
    
    // MARK: File Management
    
    /// Saves the table to `filePath` using `JSONEncoder`.
    /// - Parameter path: The fully qualified filename.
    /// - Parameter overwrite: If true, an existing file will be overwritten.
    /// - Throws: `SSSwiftyStatsError.posixError` (file can't be removed), `SSSwiftyStatsError.directoryDoesNotExist`, `SSSwiftyStatsError.fileNotReadable`.
    public func archiveTo(filePath path: String, overwrite: Bool) throws -> Bool {
        let fm = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        let dirPath: String = NSString(string: fullFilename).deletingLastPathComponent
        var isDir = ObjCBool(false)
        guard fm.fileExists(atPath: dirPath, isDirectory: &isDir), isDir.boolValue else {
            SSLog.fsError("No writable path found")
            throw SSSwiftyStatsError(type: .directoryDoesNotExist, file: #file, line: #line, function: #function)
        }

        if fm.fileExists(atPath: fullFilename) {
            if overwrite {
                if fm.isWritableFile(atPath: fullFilename) {
                    do {
                        try fm.removeItem(atPath: fullFilename)
                    } catch {
                        SSLog.fsError("Unable to remove file prior to saving new file: \(error.localizedDescription)")
                        throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                    }
                } else {
                    SSLog.fsError("Unable to remove file prior to saving new file")
                    throw SSSwiftyStatsError(type: .fileNotWriteable, file: #file, line: #line, function: #function)
                }
            } else {
                SSLog.fsError("File exists: \(fullFilename)")
                throw SSSwiftyStatsError(type: .fileExists, file: #file, line: #line, function: #function)
            }
        }

        let jsonEncode = JSONEncoder()
        let data = try jsonEncode.encode(self)
        do {
            try data.write(to: URL(fileURLWithPath: fullFilename), options: .atomic)
            return true
        } catch {
            SSLog.fsError("Unable to write data")
            return false
        }
    }
    
    /// Initializes a new table from an archive saved by `archiveTo(filePath:overwrite:)`.
    /// - Parameter path: The fully qualified filename.
    /// - Throws: `SSSwiftyStatsError.fileNotReadable`.
    public class func unarchiveFrom(filePath path: String) throws -> SSExamine<SSElement, Double>? {
        let fm = FileManager.default
        let fullFilename: String = NSString(string: path).expandingTildeInPath
        if !fm.isReadableFile(atPath: fullFilename) {
            SSLog.fsError("File not readable")
            throw SSSwiftyStatsError(type: .fileNotFound, file: #file, line: #line, function: #function)
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: fullFilename))
            let jsonDecoder = JSONDecoder()
            let result = try jsonDecoder.decode(SSExamine<SSElement, Double>.self, from: data)
            return result
        }
        catch {
            SSLog.fsError("Failure")
            return nil
        }
    }
}
