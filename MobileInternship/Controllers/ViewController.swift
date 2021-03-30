//
//  ViewController.swift
//  MobileInternship
//
//  Created by Serj on 27.03.2021.
//

import UIKit
import FSCalendar
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let realm = try! Realm()
    var networkManager = NetworkManager()

    let firstHoursArray: [Int] = Array(0...23)
    let secondHoursArray: [Int] = Array(1...24)
    
    var datesWithEvent: Results<DateData>?
    var todoItems: Results<ItemData>?
    
    var selectedDate: String = ""
    var dateStart = ""
    var itemName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        tableView.delegate = self
        networkManager.delegate = self
        datesWithEvent = realm.objects(DateData.self)
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        calendar.appearance.todayColor = UIColor.systemBlue

        
        selectedDate = dateFormatter.string(from: Date())
        networkManager.performRequest()
        loadItems()
    }
    
    func loadItems() {
        let dateExist = realm.objects(DateData.self).filter("date == %@", selectedDate).count
        if dateExist != 0 {
            clearList()
            
            networkManager.performRequest()
            todoItems = datesWithEvent?[0].items.sorted(byKeyPath: "id", ascending: true)
            tableView.reloadData()
        } else {
            clearList()
            
            tableView.reloadData()
            print("Нет дел на эту дату")
        }
    }
    
    func clearList() {
        
        if let item = datesWithEvent?[0].items.sorted(byKeyPath: "id", ascending: true) {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Ошибка удаления: \(error)")
            }
        }
    }

}

//MARK: - TableView Datasource Methods

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ItemCell
        let hour = "\(firstHoursArray[indexPath.row]).00-\(secondHoursArray[indexPath.row]).00"
        
        cell.timeLabel.text = String(hour)
    
        if let item = todoItems?[indexPath.row] {
            cell.itemLabel?.text = item.name
        } else {
            cell.itemLabel?.text = "Нет дел"
        }
        return cell
    }
    
}

//MARK: - TableView Manipulation Methods

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDetail", sender: ViewController.self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetaiIViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedItem = todoItems?[indexPath.row]
        }
    }
}


//MARK: - Calendar Methods

extension ViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = self.dateFormatter.string(from: date)
        loadItems()
        
    }
    
}

extension ViewController: NetworkManagerDelegate {
    
    func didUpdateItem(_ networkManager: NetworkManager, item: [ItemModel]) {
        let dateData = DateData()
        let newItem = ItemData()
        
        for i in item.enumerated() {
            let explodedDate = item[i.offset].dateStart.components(separatedBy: " ")
            let onlyDate = explodedDate[0]
                                
            let dateExist = realm.objects(DateData.self).filter("date == %@", onlyDate).count
            if selectedDate == onlyDate {
                print("Даты сошлись")
                if dateExist == 0 {
                    do {
                        try realm.write {
                            realm.add(dateData)
                            newItem.name = item[i.offset].itemName
                            datesWithEvent?[0].items.append(newItem)
                        }
                    } catch {
                        print(error)
                    }
                } else {
                    do {
                        try realm.write {
                            newItem.name = item[i.offset].itemName
                            datesWithEvent?[0].items.append(newItem)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
