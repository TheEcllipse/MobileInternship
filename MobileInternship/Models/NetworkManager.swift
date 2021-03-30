//
//  NetworkManager.swift
//  MobileInternship
//
//  Created by Serj on 27.03.2021.
//

import Foundation

protocol NetworkManagerDelegate {
    func didUpdateItem(_ networkManager: NetworkManager, item: [ItemModel])
    func didFailWithError(error: Error)
}

struct NetworkManager {
    
    var delegate: NetworkManagerDelegate?

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
    
    func performRequest() {
        if let safeData = readLocalFile(forName: "data") {
            if let item = parseJSON(safeData) {
                delegate?.didUpdateItem(self, item: item)
            }
        }
    }
    
    func parseJSON(_ jsonData: Data) -> [ItemModel]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([ItemData].self, from: jsonData)
                        
            let item = ItemModel()
            var itemArray: [ItemModel] = []
            
            for data in decodedData.enumerated() {
                let id = decodedData[data.offset].id
                let dateStart = item.timestampToDate(time: Double(decodedData[data.offset].dateStart) ?? 0.0)
                let dateFinish = item.timestampToDate(time: Double(decodedData[data.offset].dateFinish) ?? 0.0)
                let name = decodedData[data.offset].name
                let description = decodedData[data.offset].itemDescription

                itemArray.append(ItemModel(itemId: id, dateStart: dateStart, dateFinish: dateFinish, itemName: name, itemDescription: description))
            }
            
            return itemArray
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
