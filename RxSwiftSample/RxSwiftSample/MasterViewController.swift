//
//  MasterViewController.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/04/29.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    struct Item {
        let title: String
        let segue: String

        static func simple(segue:String) -> Item {
            return Item(title: segue, segue: segue)
        }
    }
    private let items: [Item] = [
        Item.simple(segue: "RxCocoaSample"),
        Item.simple(segue: "Detail"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = items[indexPath.row]
        performSegue(withIdentifier: object.segue, sender: self)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = items[indexPath.row]
        cell.textLabel!.text = object.title
        return cell
    }

}
