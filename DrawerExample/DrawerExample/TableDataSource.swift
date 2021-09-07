//
//  TableDataSource.swift
//  DrawerExample
//
//  Created by Roman Filippov on 15.08.2021.
//

import UIKit

final class TableDataSource: NSObject {
    
}

extension TableDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UIFont.familyNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let name = UIFont.familyNames[indexPath.row]
        cell.textLabel?.text = name
        cell.textLabel?.font = UIFont(name: name, size: 17)
        cell.textLabel?.textColor = .white
        return cell
    }
    
    
}
