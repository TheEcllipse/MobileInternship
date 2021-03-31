//
//  Items.swift
//  MobileInternship
//
//  Created by Serj on 27.03.2021.
//

import Foundation
import RealmSwift

class ItemData: Object, Codable {
    
    @objc dynamic var id: Int = 0
    
    @objc dynamic var dateStart: String = ""
    @objc dynamic var timeStart: String = ""

    @objc dynamic var dateFinish: String = ""
    @objc dynamic var timeFinish: String = ""

    @objc dynamic var name: String = ""
    @objc dynamic var itemDescription: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateStart = "date_start"
        case dateFinish = "date_finish"
        case name
        case itemDescription = "description"
    }
    
}
