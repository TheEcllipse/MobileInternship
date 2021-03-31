//
//  NetworkManager.swift
//  MobileInternship
//
//  Created by Serj on 27.03.2021.
//

import Foundation
import RealmSwift

protocol NetworkManagerDelegate {
    func didUpdateItem(_ networkManager: NetworkManager, item: ItemModel)
    func didFailWithError(error: Error)
}

struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    let convertDate = ItemModel()

    func performRequest() {
        if let safeData = readLocalFile(forName: "data") {
            if let item = parseJSON(safeData) {
                delegate?.didUpdateItem(self, item: item)
            }
        }
    }
    
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            delegate?.didFailWithError(error: error)
        }
        return nil
    }
    
    func parseJSON(_ jsonData: Data) -> ItemModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([ItemData].self, from: jsonData)
            
            var itemsArray = ItemModel()
            for data in decodedData.enumerated() {
                itemsArray.itemId = decodedData[data.offset].id
                itemsArray.dateStart = convertDate.timestampToDate(time: Double(decodedData[data.offset].dateStart) ?? 0.0)
                itemsArray.dateFinish = convertDate.timestampToDate(time: Double(decodedData[data.offset].dateFinish) ?? 0.0)
                itemsArray.itemName = decodedData[data.offset].name
                itemsArray.itemDescription = decodedData[data.offset].itemDescription
                
                insertOrUpdate(itemsArray)
            }
            
            return itemsArray
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func insertOrUpdate(_ items: ItemModel) {
        let realm = try! Realm()
        try! realm.write({
            let itemRealm = ItemData()
            
            itemRealm.id = items.itemId
            
            itemRealm.dateStart = convertDate.formatDate(items.dateStart)
            itemRealm.timeStart = convertDate.formatDate(items.dateStart, choice: "Time")
            
            itemRealm.dateFinish = convertDate.formatDate(items.dateFinish)
            itemRealm.timeFinish = convertDate.formatDate(items.dateFinish, choice: "Time")
            
            itemRealm.name = items.itemName
            itemRealm.itemDescription = items.itemDescription

            realm.add(itemRealm)
            })
    }
}
