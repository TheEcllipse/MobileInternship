//
//  ItemModel.swift
//  MobileInternship
//
//  Created by Serj on 28.03.2021.
//

import Foundation

struct ItemModel {
    
    var itemId: Int = 0
    var dateStart: String = ""
    var dateFinish: String = ""
    var itemName: String = ""
    var itemDescription: String = ""
    
    func timestampToDate(time: TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
    
}
