//
//  FileHandler.swift
//  Focal
//
//  Created by Ferdinand Göldner on 11.05.17.
//  Copyright © 2017 Ferdinand Göldner. All rights reserved.
//

import Cocoa

class FileHandler {
    
    var defaultBackupFilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/backup"
    var defaultBackupFileName = "/initialBackup.txt"
    var hostsFilePath = "/etc"
    var hostsFileFilename = "/hosts"
    
    init() {
        guard let content = importFile(filepath: hostsFilePath, filename: hostsFileFilename) else {
            debugPrint("File \(hostsFilePath + hostsFileFilename) doesn't exist or couldn't be opened.")
            return
        }
        let success = exportFile(filepath: defaultBackupFilePath, filename: defaultBackupFileName, content: content)
        debugPrint(success)
    }
    
    
    /// Imports the content of a file with the given filepath.
    ///
    /// - Parameter filepath: A string containing the path that the file lies in.
    /// - Parameter filename: A string containing the filename that should be opened.
    /// - Returns: Content of the file, or nil of the file couldn't be opened or doesn't exist.
    func importFile(filepath: String, filename: String) -> String? {
        do {
            let content = try String(contentsOf: URL(fileURLWithPath: filepath + filename))
            return content
        } catch {
            debugPrint(error.localizedDescription)
            return nil
        }
    }
    
    
    /// Exports the content passed to the function into a file at the give filepath and filename. Function creates folders and files if necessary and possible.
    ///
    /// - Parameters:
    ///   - filepath: The folder that the file should be saved in.
    ///   - filename: The filename of the file that the content should be saved in.
    ///   - content: The content string that should be saved to the file.
    /// - Returns: Returns a flag wether the export was sucessfull or not. False: failed, True: succeeded.
    func exportFile(filepath: String, filename: String, content: String) -> Bool {
        do {
            let fileManager = FileManager()
            if (!fileManager.fileExists(atPath: (filepath + filename))) {
                debugPrint("Path or file doesn't exist. Trying to create it now.")
                do {
                    try fileManager.createDirectory(atPath: (filepath), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
            
            try content.write(toFile: (filepath + filename), atomically: false, encoding: .utf8)
            debugPrint(filepath+filename)
            return true
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
    }
    
    
}
