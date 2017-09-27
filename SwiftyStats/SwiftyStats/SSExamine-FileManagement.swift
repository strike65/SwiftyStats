//
//  SSExamine-FileManagement.swift
//  SwiftyStats
//
//  Created by volker on 23.08.17.
//  Copyright © 2017 VTSoftware. All rights reserved.
//

import Foundation
import os.log


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
        NSKeyedArchiver.setClassName("SwiftyStats.SSExamine" + ".\(SSElement.self)", for: SSExamine<SSElement>.classForKeyedArchiver()!)
        print(NSKeyedArchiver.className(for: SSExamine<SSElement>.self)!)
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
        NSKeyedUnarchiver.setClass(SSExamine<SSElement>.classForKeyedArchiver(), forClassName: "SwiftyStats.SSExamine" + ".\(SSElement.self)")
        print(NSKeyedUnarchiver.class(forClassName: "SwiftyStats.SSExamine" +  ".\(SSElement.self)")!)
        let result: SSExamine<SSElement>
        
        if let ex = NSKeyedUnarchiver.unarchiveObject(withFile: fullFilename) {
            result = ex as! SSExamine<SSElement>
            return result
        }
        else {
            return nil
        }
//        let result: SSExamine<SSElement>? = NSKeyedUnarchiver.unarchiveObject(withFile: fullFilename) as? SSExamine<SSElement>
    }
}
