//
//  DateData.swift
//  MobileInternship
//
//  Created by Serj on 28.03.2021.
//

import Foundation
import RealmSwift

class DateData: Object {
    @objc dynamic var date: String = ""
    let items = List<ItemData>()
    
}

