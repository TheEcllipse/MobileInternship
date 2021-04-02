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
    
    let realm = try! Realm()
    var networkManager = NetworkManager()
    var todoItems: Results<ItemData>?
    var datesWithEvents: ItemData?
    var selectedDate: String = ""
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        tableView.delegate = self
        networkManager.delegate = self
        
        overrideUserInterfaceStyle = .light
        calendar.appearance.todayColor = UIColor.systemBlue
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        selectedDate = dateFormatter.string(from: Date())
        
        clearList()
        networkManager.performRequest()
        loadItems()
    }
    
    func loadItems() {
        todoItems = realm.objects(ItemData.self)
            .filter("dateStart == %@", selectedDate)
            .sorted(byKeyPath: "timeStart", ascending: false)
        
        tableView.reloadData()
    }
    
    func clearList() {
        let result = realm.objects(ItemData.self)
        do {
            try realm.write {
                realm.delete(result)
            }
        } catch {
            print("Ошибка удаления из базы данных: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetaiIViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            var index = 1
            while index <= todoItems!.count {
                let explodedTimeStart = todoItems![index - 1].timeStart.components(separatedBy: ":")
                if String(indexPath.row) == explodedTimeStart[0] {
                    destinationVC.selectedItem = todoItems?[index - 1]
                    break
                }
                index += 1
            }
        }
    }
    
}

//MARK: - TableView's Methods

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! ItemCell
        
        let hoursArray = Array(0...23)
        let hour = "\(hoursArray[indexPath.row]):00-\(hoursArray[indexPath.row] + 1):00"
        cell.timeLabel.text = String(hour)
        cell.itemLabel?.text = "Нет дел"
        
        var index = 1
        while index <= todoItems!.count {
            let explodedTimeStart = todoItems![index - 1].timeStart.components(separatedBy: ":")
            if String(indexPath.row) == explodedTimeStart[0] {
                cell.itemLabel?.text = todoItems![index-1].name
                cell.timeLabel.text = "\(todoItems![index-1].timeStart)-\(todoItems![index-1].timeFinish)"
            }
            index += 1
        }
        
//        Оставлю, на всякий случай. Выводит дела в первых строчках.
//        if let item = todoItems?[safe: indexPath.row] {
//            cell.itemLabel?.text = item.name
//            cell.timeLabel.text = "\(item.timeStart)-\(item.timeFinish)"
//        } else {
//            cell.itemLabel?.text = "Нет дел"
//        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index = 1
        while index <= todoItems!.count {
            let explodedTimeStart = todoItems![index - 1].timeStart.components(separatedBy: ":")
            if String(indexPath.row) == explodedTimeStart[0] {
                performSegue(withIdentifier: K.detailSegue, sender: ViewController.self)
                break
            }
            index += 1
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Calendar's Methods

extension ViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = self.dateFormatter.string(from: date)
        loadItems()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        
        datesWithEvents = realm.objects(ItemData.self)
            .filter("dateStart == %@", dateString)
            .sorted(byKeyPath: "dateStart", ascending: false).first
                
        if dateString == datesWithEvents?.dateStart {
            return 1
        }

        return 0
    }
    
}

//MARK: - Delegate's Methods

extension ViewController: NetworkManagerDelegate {
    func didUpdateItem(_ networkManager: NetworkManager, item: ItemModel) {
        // Здесь можно получить заполненую модельку. Пока не придумал зачем:)
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - Чтобы индекс массива мог быты опционалом

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
