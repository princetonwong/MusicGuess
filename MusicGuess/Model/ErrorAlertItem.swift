//
//  ErrorAlertItem.swift
//  
//
//  Created by Princeton Wong on 12/7/2022.
//

import Foundation

struct ErrorAlertItem: Identifiable {
    
    var id = "ALERT-\(UUID())"
    
    let title: String
    let message: String
}
