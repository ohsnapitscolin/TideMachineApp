//
//  CustomDate.swift
//  TideMachineApp
//
//  Created by Colin Dunn on 3/27/22.
//

import Foundation

let Internal = 2

class CustomDate {
    private var customDate: Date? = nil;
    
    init(date: Date?) {
        customDate = date;
    }
    
    var date: Date  {
        get { return customDate ?? Date() }
    }
    
    func tick() {
        if customDate != nil {
            customDate = Calendar.current.date(
                byAdding: .minute,
                value: Internal,
                to: customDate!)
        }
    }
}
