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
    var blockedWebsites = ["www.facebook.com"]
    
    // Setting the default variables necessary for the software to work.
    // (Backup directory and file, location of hosts file)
    let defaultBackupFilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/backup"
    let defaultBackupFileName = "/initialBackup.txt"
    let hostsFilePath = "/etc"
    let hostsFileFilename = "/hosts"
    
    
    /// Does an inital Backup if the app is launched the first time. After that it imports the list of websites that should be blocked.
    init() {
        // Implement using NSUserDefaults
        if firstTime {
            _ = doInitialBackup()
        }
        
        // TODO: Import list
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
}
