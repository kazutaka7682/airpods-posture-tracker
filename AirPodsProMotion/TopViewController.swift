//
//  TopViewController.swift
//
//  I created TopViewController with reference to the following repositories and articles.
//  GitHub          : https://github.com/tukuyo/AirPodsPro-Motion-Sampler
//  Article (Qiita) : https://qiita.com/tukutuku_tukuyo/items/ea949ee2dbb499d6e7ca
//

import UIKit

class TopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var table: UITableView = {
        let table = UITableView(frame: self.view.bounds, style: .plain)
        table.autoresizingMask = [
          .flexibleWidth,
          .flexibleHeight
        ]
        table.rowHeight = 60
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    private var items: [UIViewController] = [InformationViewController(), SK3DViewController(), ViewController(), ExportCSVViewController()]
    private var itemTitle: [String] = ["Information View", "Rotate the Cube View", "BLE", "Export CSV file"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "AirPodsProMotion Sampler"
        
        table.dataSource = self
        table.delegate = self
        view.addSubview(table)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = itemTitle[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(items[indexPath.row], animated: true)
    }

}
