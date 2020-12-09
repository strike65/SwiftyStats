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
import os.log
#endif



extension SSExamine {
    
    // MARK: File Management
    
    /// Saves the table to filePath using NSKeyedArchiver.
    /// - Parameter path: The full qualified filename.
    /// - Parameter overwrite: If yes an existing file will be overwritten.
    /// - Throws: SSSwiftyStatsError.posixError (file can'r be removed), SSSwiftyStatsError.directoryDoesNotExist, SSSwiftyStatsError.fileNotReadable
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
        let data = try jsonEncode.encode(self)
        do {
            try data.write(to: URL.init(fileURLWithPath: fullFilename), options: Data.WritingOptions.atomic)
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
    
    /// Initializes a new table from an archive saved by archiveTo(filePath path:overwrite:).
    /// - Parameter path: The full qualified filename.
    /// - Throws: SSSwiftyStatError.fileNotReadable
    public class func unarchiveFrom(filePath path: String!) throws -> SSExamine<SSElement, Double>? {
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
            let result = try jsonDecoder.decode(SSExamine<SSElement, Double>.self, from: data)
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
}
