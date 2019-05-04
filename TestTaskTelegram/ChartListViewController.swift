//
//  ChartListViewController.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 11.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

class ChartListViewController: UITableViewController {
    
    private var columnsArray = [[[Any]]]()
    private var typesArray = [[String: Any]]()
    private var namesArray = [[String: Any]]()
    private var colorsArray = [[String: Any]]()
    private var dayColor = UIColor(hex: "#FEFEFE")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        importJSONData()        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barTintColor = dayColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue:
            NSAttributedString.Key.foregroundColor.rawValue): UIColor.black]
        navigationController?.navigationBar.barStyle = .default
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return columnsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Chart #\(indexPath.row)"
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChart", let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            let chartViewController = segue.destination as! ChartViewController
            chartViewController.columnsArray = columnsArray[indexPath.row]
            chartViewController.typesDict = typesArray[indexPath.row]
            chartViewController.namesDict = namesArray[indexPath.row]
            chartViewController.colorsDict = colorsArray[indexPath.row]
        }
    }
    
}

private extension ChartListViewController {
    
    func importJSONData() {
        if let jsonURL = Bundle.main.url(forResource: "chart_data", withExtension: "json") {
            let jsonData = try! Data(contentsOf: jsonURL)
            let jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [[String: Any]]
            
            for jsonDictionary in jsonArray {
                columnsArray.append(jsonDictionary["columns"] as! [[Any]])
                typesArray.append(jsonDictionary["types"] as! [String: Any])
                namesArray.append(jsonDictionary["names"] as! [String: Any])
                colorsArray.append(jsonDictionary["colors"] as! [String: Any])
            }
        }
        
    }
}
