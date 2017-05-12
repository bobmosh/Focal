//
//  ConsoleHandler.swift
//  Focal
//
//  Created by Ferdinand Göldner on 12.05.17.
//  Copyright © 2017 Ferdinand Göldner. All rights reserved.
//

import Foundation

class ConsoleHandler {
    
    let focalHandler = FocalHandler()
    
    /// Print welcome message, then asks for user input in a loop and executes the entered commands. Also checks for valid input command or tells the user if the command doesn't exist.
    init() {
        var commands = initCommands()
        print("Welcome to Focal. Glad you decided to get focused.")
        print("--------------------------------------------------")
        print()
        print("Please enter one of the following commands to get started:")
//        print("block: This command blocks access to all the websites in your list.")
        print("list:  Lists all the websites that the access will be blocked to.")
        print("add:   Add Website to the list of blocked websites.")
        print("reset: Allows access to all the websites again. This restores the initial Backup.")
        print("exit:  Kills the Application. This doesn't give you access to the websites again. Focal also works when it's shut down.")
        print()
        
        while(true) {
            let input = readLine()
            if (input != nil && commands[input!] != nil) {
                commands[input!]!()
            } else {
                print("Sorry, I didn't catch that. Maybe there was a typo or something. Please try again!")
            }
        }
    }
    
    /// Creates a dictionary with all the known commands and returns it.
    func initCommands() -> [String: () -> Void] {
        var commands = [String: () -> Void]()
        commands["exit"] = exitApplication
        commands["list"] = listWebsites
        commands["add"] = addWebsites
        commands["reset"] = resetHosts
        return commands
    }
    
    
    // Section: Known commands
    /// Restores the inital Backup of the hosts file. Needs sudo.
    func resetHosts() {
        print("Restoring backup.")
        if focalHandler.restoreBackup() {
            print("Restore sucessfull. You can now access all websites again.")
        } else {
            print("Action coudln't be completed.")
        }
        print()
        return
    }
    
    
    /// Kill sthe application with error code 0.
    func exitApplication() {
        print("Exiting...")
        exit(0)
    }
    
    
    /// Prints out a list of all the websites on the current blocked list.
    func listWebsites() {
        print("The websites currently on the list are: ")
        let websites = focalHandler.listWebsites()
        var index = 1
        for site in websites {
            print("\(index): " + site)
            index += 1
        }
        print()
    }
    
    
    /// Adds a website to the current blocked list.
    func addWebsites() {
        print()
        print("Please enter the websites you want to add to the Blacklist: ")
        self.focalHandler.addWebsite(website: readLine()!)
        print("Added!")
        print()
        listWebsites()
    }
}
