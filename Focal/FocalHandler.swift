//
//  FocalHandler.swift
//  Focal
//
//  Created by Ferdinand Göldner on 12.05.17.
//  Copyright © 2017 Ferdinand Göldner. All rights reserved.
//

import Foundation

class FocalHandler {
    var firstTime = false
    var blockedWebsites: [String] = []
    var listName = "blacklist"
    var textifiedName: (String)->String  = { arg in return arg + ".txt" }
    
    // Setting the default variables necessary for the software to work.
    // (Backup directory and file, location of hosts file)
    let defaultBackupFilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/backup/"
    let defaultBackupFileName = "initialBackup.txt"
    let defaultProfilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/profiles/"
    let hostsFilePath = "/etc"
    let hostsFileFilename = "/hosts"
    
    
    /// Does an inital Backup if the app is launched the first time. After that it imports the list of websites that should be blocked.
    init() {
        // Implement using NSUserDefaults
        if firstTime {
            _ = doInitialBackup()
        }
        
        // TODO: Import list
        guard let blockedWebsites = importList(listName: listName) else {
            return
        }
        self.blockedWebsites = cleanupList(array: blockedWebsites)
    }
    
    
    /// Exports the currently loaded blacklist to the drive.
    ///
    /// - Parameter named: Name of the file that should be saved.
    /// - Returns: Returns wether the export was sucessful or not.
    func exportList(named: String) -> Bool {
        var content = ""
        for item in blockedWebsites {
            content += item + "\n"
        }
        if FileHandler.exportFile(filepath: defaultProfilePath, filename: textifiedName(listName), content: content) {
            return true
        } else { return false }
    }
    
    
    /// Imports the passed file as a list of websites that needs to be added to the hosts file. Returns array of lines separated by "\n" if the file exists and nil if file doesn't exist.
    ///
    /// - Parameter listName: The name of the List. ( which is listName + ".txt" as filename)
    /// - Returns: Array of lines in the text file (separated by "\n".
    func importList(listName: String) -> [String]? {
        let input = FileHandler.importFile(filepath: defaultProfilePath, filename: textifiedName(listName))
        let websites = input?.components(separatedBy: "\n")
        return websites
    }
    
    
    /// Removes empty lines from an array. Used to minimize memory allocation and cleans up the lists file as a result.
    ///
    /// - Parameter array: Array that should be cleaned up.
    /// - Returns: Returns the cleaned array.
    func cleanupList(array: [String]) -> [String] {
        return array.filter{$0 != ""}
    }
    
    
    /// Executes an initial Backup of the hosts file to the users Application Support folder. Security first.
    ///
    /// - Returns: Returns wether the backup was sucessful or not.
    func doInitialBackup() -> Bool {
        guard let content = FileHandler.importFile(filepath: hostsFilePath, filename: hostsFileFilename) else {
            debugPrint("File \(hostsFilePath + hostsFileFilename) doesn't exist or couldn't be opened.")
            return false
        }
        let success = FileHandler.exportFile(filepath: defaultBackupFilePath, filename: defaultBackupFileName, content: content)
        return success
    }
    
    // TODO: Check if file exists and is writeable.
    
    /// Restores the inital backup of the hosts file. Needs sudo.
    ///
    /// - Returns: Returns wether the backup was sucessful or not.
    func restoreBackup() -> Bool {
        let backup = FileHandler.importFile(filepath: defaultBackupFilePath, filename: defaultBackupFileName)
        return FileHandler.exportFile(filepath: hostsFilePath, filename: hostsFileFilename, content: backup!)
    }
    
    
    /// Creates an array of all the blocked websites on the list.
    ///
    /// - Returns: Resturns this creates array containing the URLs of all the blocked websites on the list.
    func listWebsites() -> [String] {
        return blockedWebsites
    }
    
    
    /// Adds a website to the blocked list. Checks for valid URLs and appedns necessary prefixes.
    ///
    /// - Parameter website: The URL of the website that should be added to the blocked list.
    func addWebsite(website: String) {
        // TODO: Check for valid URLs
        blockedWebsites.append(website)
    }
    
    
    /// Deletes a website from the array of the currently buffered list of websites.
    ///
    /// - Parameter website: Value that should be deleted.
    /// - Returns: Returns wether the deletion was successful or not.
    func removeWebsite(website: String) -> Bool {
        guard let index = blockedWebsites.index(of: website) else {
            return false
        }
        blockedWebsites.remove(at: index)
        return true
    }
}
