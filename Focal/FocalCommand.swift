//
//  FocalCommand.swift
//  Focal
//
//  Created by Ferdinand Göldner on 18.05.17.
//  Copyright © 2017 Ferdinand Göldner. All rights reserved.
//

import Foundation

struct FocalCommand {
    var closure: () -> (Void)
    var description: String
    var duplicate: Bool
}
