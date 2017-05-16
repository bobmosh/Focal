//
//  FocalHandler.swift
//  Focal
//
//  Created by Ferdinand Göldner on 12.05.17.
//  Copyright © 2017 Ferdinand Göldner. All rights reserved.
//

import Cocoa
import Foundation

import SecurityFoundation
import ServiceManagement


class FocalHandler {
    var firstTime = false
    var blockedWebsites: [String] = []
    var listName = "blacklist"
    let redirectTo = ["0.0.0.0", "::"]
    
    /// Closure textifying a name. Generates a string that contains the name entered + ".txt".
    var textifiedName: (String)->String  = { arg in return arg + ".txt" }
    
    // Setting the default variables necessary for the software to work.
    // (Backup directory and file, location of hosts file)
    let defaultBackupFilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/backup/"
    let defaultBackupFileName = "initialBackup"
    let defaultProfilePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] + "/Focal/profiles/"
    let hostsFilePath = "/etc/"
    let hostsFileFilename = "hosts"
    
    
    /// Does an inital Backup if the app is launched the first time using NSUserDefaults. After that it imports the list of websites that should be blocked.
    init() {
        // Implement using a plist that is stored inside of the project bundle to make it easier to maintain in the future.
        var dict = [String: Any]()
        dict["firstTimeLaunch"] = true
        let defaults = UserDefaults()
        defaults.register(defaults: dict)
        
        if defaults.bool(forKey: "firstTimeLaunch") {
            _ = doInitialBackup()
            
            defaults.set(false, forKey: "firstTimeLaunch")
            defaults.synchronize()
        }
        
        guard let blockedWebsites = importList(listName: listName) else {
            return
        }
        self.blockedWebsites = cleanupList(array: blockedWebsites)
    }
    
    
    /// Generates a string from the default Backup of the hosts file + the items in the blockedWebsites array using the redirectTo array as parameters. Thoe entries are wrpaed in a block of comments that indicate that the are part of the focal app.  Number of entries cenerated: blockedWebsites.count * retirectTo.count
    ///
    /// - Returns: Generated string containing the backup of the hosts file + generated entrys wraped in a comment.
    func generateHostsFile() -> String {
        guard var blockedString: String = FileHandler.importFile(filepath: defaultBackupFilePath, filename: textifiedName(defaultBackupFileName)) else {
            debugPrint("Couldn't read hosts Backup file.")
            return ""
        }
        blockedString += "\n\n# Focal block starts here\n"
        for item in blockedWebsites {
            for redirection in redirectTo {
                blockedString += "\(redirection) \(item)\n"
            }
        }
        blockedString += "# Focal block ends here"
        return blockedString
    }
    
    
    /// Creates an authentication process. If successfull, fileHandler exports the hosts file to the destination, and afterwardsfrees the auhentication reference. If authorization fails, it prints an error message.
    func blockWebsites() {
        guard let authRef: AuthorizationRef = authorize() else {
            print("Couldn't block the websites. No access to the hosts file granted.")
            return
        }
        
        _ = FileHandler().exportFile(filepath: "/etc/", filename: "hosts", content: generateHostsFile())
        
        freeAuthorization(authRef: authRef)
    }
    
    
    /// Creates an authorization by using AuthorizationCreate.
    ///
    /// - Returns: Returns the authorization reference.
    func authorize() -> AuthorizationRef? {
        var myItems = [
            AuthorizationItem(name: kAuthorizationRuleAuthenticateAsAdmin,
                              valueLength: 0, value: nil, flags: 0)]
        
        var myRights = AuthorizationRights(count: UInt32(myItems.count), items: &myItems)
        let myFlags : AuthorizationFlags = [[], .interactionAllowed, .extendRights]
        
        var authRef: AuthorizationRef?
        let osStatus = AuthorizationCreate(&myRights, nil, myFlags, &authRef)
        
        if (osStatus == errAuthorizationSuccess) {
            return authRef
        } else {
            debugPrint("Failed to Authorize.")
            return authRef
        }
    }
    
    
    /// Freea an aothorization based on its reference.
    ///
    /// - Parameter authRef: Authorization reference that shoul be freed.
    func freeAuthorization(authRef: AuthorizationRef?) {
        AuthorizationFree(authRef!, AuthorizationFlags(rawValue: 0))
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
        let success = FileHandler.exportFile(filepath: defaultBackupFilePath, filename: textifiedName(defaultBackupFileName), content: content)
        return success
    }
    
    // TODO: Check if file exists and is writeable.
    
    /// Restores the inital backup of the hosts file. Needs sudo.
    ///
    /// - Returns: Returns wether the backup was sucessful or not.
    func restoreBackup() -> Bool {
        guard let authRef: AuthorizationRef = authorize() else {
            debugPrint("Couldn't block the websites. No access to the hosts file granted.")
            return false
        }
        
        let backup = FileHandler.importFile(filepath: defaultBackupFilePath, filename: textifiedName(defaultBackupFileName))
        let successfulExport = FileHandler.exportFile(filepath: hostsFilePath, filename: hostsFileFilename, content: backup!)
        
        freeAuthorization(authRef: authRef)
        return successfulExport
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
