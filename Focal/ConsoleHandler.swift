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
    var arguments: [String] = []
    
    /// Print welcome message, then asks for user input in a loop and executes the entered commands. Also checks for valid input command or tells the user if the command doesn't exist.
    init() {
        var commands = initCommands()
        print("Welcome to Focal. Glad you decided to get focused.")
        print("--------------------------------------------------")
        print()
        print("Please enter one of the following commands to get started:")
        print("  block:    This command blocks access to all the websites in your list.")
        print("  list:     Lists all the websites that the access will be blocked to.")
        print("  add:      Add Website to the list of blocked websites.")
        print("  remove:   Removes Website from the list of blocked websites.")
        print("  reset:    Allows access to all the websites again. This restores the initial Backup.")
        print("  exit:     Kills the Application. This doesn't give you access to the websites again. Focal also works when it's shut down.")
        print("  save:     Saves the current blacklist.")
        
        print()
        
        while(true) {
            let input = readLine()?.components(separatedBy: " ")
            if (input != nil && commands[input![0]] != nil) {
                if (input?.count)! <= 1 { arguments = [] } else {
                    arguments = input!
                    arguments.removeFirst()
                }
                commands[input![0]]!()
            } else {
                print("Sorry, I didn't catch that. Maybe there was a typo or something. Please try again!")
            }
        }
    }
    
    // TODO: Create interface for list manager (adjust all the other functions to be able to work with command type dictinaries so that I can easily adapt to future managers and changes easily).
    // I need a separate manager inside of the application that lets me create, adjust and delete lists.
    
    /// Creates a dictionary with all the known commands and returns it.
    func initCommands() -> [String: () -> Void] {
        var commands = [String: () -> Void]()
        commands["exit"] = exitApplication
        commands["kill"] = exitApplication
        
        commands["list"] = listWebsites
        commands["ls"] = listWebsites
        
        commands["add"] = addWebsites
        
        commands["remove"] = removeWebsite
        commands["rm"] = removeWebsite
        
        commands["save"] = saveBlacklist
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
            // Removes empty lines with just linebreaks.
            if site != "" {
                print("\(index): " + site)
                index += 1
            }
        }
        print()
    }
    
    
    /// Adds a website to the current blocked list, either using arguments of the call or by entering one in after entering the command.
    func addWebsites() {
        print()
        
        if arguments != [] {
            for item in arguments {
                self.focalHandler.addWebsite(website: item)
            }
        } else {
            print("Please enter the websites you want to add to the Blacklist: ")
            self.focalHandler.addWebsite(website: readLine()!)
        }

        print("Added!")
        print()
        listWebsites()
    }
    
    
    /// Saves the current blacklist to the file.
    func saveBlacklist() {
        _ = focalHandler.exportList(named: "blacklist")
        print()
        print("Exported the blacklist.")
        print()
    }
    
    
    /// Removes websites from the blacklist, either using the arguments array or by entering a single website after the command has been sent. 
    func removeWebsite() {
        print()
        
        if arguments != [] {
            for item in arguments {
                if !self.focalHandler.removeWebsite(website: item) {
                    print("Couldn't find the Website: \(item).")
                }
            }
        } else {
            print("Please enter the websites you want to remove from the Blacklist: ")
            if self.focalHandler.removeWebsite(website: readLine()!) {
                print("Removed!")
            } else {
                print("Couldn't find the Website.")
            }
        }
        
        print()
        listWebsites()
    }
}
