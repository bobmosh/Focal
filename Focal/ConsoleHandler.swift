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
    let maxCharactersPerCommand = 7
    var arguments: [String] = []
    
    /// Print welcome message, then asks for user input in a loop and executes the entered commands. Also checks for valid input command or tells the user if the command doesn't exist.
    init() {
        // Creates and links all the commands to the commands dictionary.
        var commands = initCommands()
        
        // Prints out all the commands there currently are.
        print("Welcome to Focal. Glad you decided to get focused.")
        print("--------------------------------------------------")
        print()
        for (key, value) in commands {
            if value.duplicate { continue }
            print("  \(key):", separator: "", terminator: "")
            
            // Calculate how many spaces are missing to create proper alignment ...
            let numberOfMissingSpacesForAlignment = (maxCharactersPerCommand - key.characters.count)
            // ... and append them to the command
            for _ in 0...numberOfMissingSpacesForAlignment {
                print(" ", separator: "", terminator: "")
            }
            print("  \(value.description)")
        }
//        print("Please enter one of the following commands to get started:")
//        print("  block:    This command blocks access to all the websites in your list.")
//        print("  unblock:  Opens up access to all websites again.")
//        print("  list:     Lists all the websites that the access will be blocked to.")
//        print("  add:      Add Website to the list of blocked websites.")
//        print("  remove:   Removes Website from the list of blocked websites.")
//        print("  reset:    Allows access to all the websites again. This restores the initial Backup.")
//        print("  exit:     Kills the Application. This doesn't give you access to the websites again. Focal also works when it's shut down.")
//        print("  save:     Saves the current blacklist.")
        print()
        
        // Read userinput, check if valid, separate into command + argments and finally execute the given closure for the entered command.
        while(true) {
            let input = readLine()?.components(separatedBy: " ")
            if (input != nil && commands[input![0]] != nil) {
                if (input?.count)! <= 1 { arguments = [] } else {
                    arguments = input!
                    arguments.removeFirst()
                }
                commands[input![0]]!.closure()
            } else {
                print("Sorry, I didn't catch that. Maybe there was a typo or something. Please try again!")
            }
        }
    }
    
    // Future-TODO: Create interface for list manager (adjust all the other functions to be able to work with command type dictinaries so that I can easily adapt to future managers and changes easily).
    // I need a separate manager inside of the application that lets me create, adjust and delete lists.
    /// Creates a dictionary with all the known commands and returns it.
    func initCommands() -> [String: FocalCommand] {
        var commands = [String: FocalCommand]()
        
        var newCommand = FocalCommand(closure: blockWebsites,
                                      description: "This command blocks access to all the websites in your list.",
                                      duplicate: false)
        commands["block"] = newCommand
        
        newCommand = FocalCommand(closure: unblockWebsites,
                                  description: "Opens up access to all websites again.",
                                  duplicate: false)
        commands["unblock"] = newCommand
        
        
        newCommand = FocalCommand(closure: exitApplication,
                                  description: "Kills the Application. This doesn't give you access to the websites again. Focal also works when it's shut down.",
                                  duplicate: false)
        commands["exit"] = newCommand
        newCommand.duplicate = true
        commands["kill"] = newCommand
        
        
        newCommand = FocalCommand(closure: listWebsites,
                                  description: "Lists all the websites that the access will be blocked to.",
                                  duplicate: false)
        commands["list"] = newCommand
        newCommand.duplicate = true
        commands["ls"] = newCommand
        
        
        newCommand = FocalCommand(closure: addWebsites,
                                  description: "Add Website to the list of blocked websites.",
                                  duplicate: false)
        commands["add"] = newCommand
        
        
        newCommand = FocalCommand(closure: removeWebsite,
                                  description: "Removes Website from the list of blocked websites.",
                                  duplicate: false)
        commands["remove"] = newCommand
        newCommand.duplicate = true
        commands["rm"] = newCommand

        newCommand = FocalCommand(closure: saveBlacklist,
                                  description: "Saves the current blacklist.",
                                  duplicate: false)
        commands["save"] = newCommand
        
        newCommand = FocalCommand(closure: resetFocal,
                                  description: "llows access to all the websites again. This restores the initial Backup.",
                                  duplicate: false)
        commands["reset"] = newCommand
        return commands
    }
    
    
    // Section: Known commands
    /// Restores teh inital state of Focal (also resettign NSUserDefaults etc.)
    func resetFocal() {
        unblockWebsites()
        resetUserDefaults()
    }
    
    
    /// Reset UserDefaults to factory settings. Useful if we want Focal to create an initial backup again.
    func resetUserDefaults() {
        print("Reseting UserDefaults.")
        focalHandler.resetUserDefaults()
        print("Done.")
        print()
    }
    
    
    /// Calls the FoclaHanlder to block the currently buffered websites.
    func blockWebsites() {
        focalHandler.blockWebsites()
        print("The websites on your blacklist are now being blocked.")
        print()
    }
    
    /// Calls the FoclaHanlder to unblock the currently buffered websites.
    func unblockWebsites() {
        print("Restoring backup.")
        // If successfull print unblock successfull. Else print error.
        if focalHandler.restoreBackup() {
            print("Unblock sucessfull. You can now access all websites again.")
        } else {
            print("Action coudln't be completed.")
        }
        print()
        return
    }
    
    
    /// Kill sthe application with error code 0.
    func exitApplication() {
        print()
        if focalHandler.changesMadeToBlacklist() {
            // Ask user if changes should be saved.
            print("Do you want to save changes you made to the blacklist?\n n: No\n y: Yes")
            if readLine() == "y" {
                saveBlacklist()
            }
        }
        print("Exiting...")
        exit(0)
    }
    
    
    /// Prints out a list of all the websites on the current blocked list.
    func listWebsites() {
        print("The websites currently on the list are: ")
        // Lists out all the websites with an numeration that could potentially be used as item identification.
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
        
        // Checks if only the command was entered of if there are arguments to be processed.
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
        
        // Checks if only the command was entered of if there are arguments to be processed.
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
