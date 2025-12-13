//
//  Item.swift
//  theWarmth
//
//  Created by An Tran on 12/14/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
