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
    var selectedDate: String = ""
    
    let firstHoursArray: [Int] = Array(0...23)
    let secondHoursArray: [Int] = Array(1...24)
    
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
        
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        calendar.appearance.todayColor = UIColor.systemBlue
        
        selectedDate = dateFormatter.string(from: Date())

        clearList()
        networkManager.performRequest()
        loadItems()
    }
    
    func loadItems() {
        todoItems = realm.objects(ItemData.self).filter("dateStart == %@", selectedDate)
        tableView.reloadData()
    }
    
    func clearList() {
        let result = realm.objects(ItemData.self)
        do {
            try realm.write {
                realm.delete(result)
            }
        } catch {
            print("Ошибка удаления: \(error)")
        }
    }
}

//MARK: - TableView Datasource Methods

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return todoItems?.count ?? 24
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ItemCell
        let hour = "\(firstHoursArray[indexPath.row]).00-\(secondHoursArray[indexPath.row]).00"
        
        cell.timeLabel.text = String(hour)
        
        
        if todoItems?.count != 0 {
            let newIndex = 24 + (todoItems!.count - 24)
            print(newIndex)
            if let item = todoItems?[newIndex - 1] {
                cell.itemLabel?.text = item.name
            } else {
                cell.itemLabel?.text = "Нет дел"
            }
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
    
    func didUpdateItem(_ networkManager: NetworkManager, item: ItemModel) {
        // Здесь можно получить заполненую модельку. Пока не придумал зачем:)
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
