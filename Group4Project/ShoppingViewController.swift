//
//  ShoppingViewController.swift
//  Group4Project
//
//  Created by Arnett, Nicolai D. on 4/20/26.
//

import UIKit

class ShoppingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    

    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField{$0.placeholder = "Item name"}
        alert.addTextField{$0.placeholder = "Amount"}
        
        let addAction = UIAlertAction(title: "Add", style: .default){_ in
            let name = alert.textFields?[0].text ?? "Unknown"
            let amountText = alert.textFields?[1].text
            let amount = Int(amountText ?? "")
            
            let item = Item(name: name, amount: amount)
            self.shoppingItems.append(item)
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    var shoppingItems: [Item] = []
    weak var delegate: ShoppingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return shoppingItems.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of items in Shopping List"
    }
    
    //swipe to delete function
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {[weak self] _, _, completion in
            
            guard let self = self else{
                return
            }
            self.shoppingItems.remove(at: indexPath.row)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCell", for: indexPath)
        
        let item = shoppingItems[indexPath.row]
        cell.textLabel?.text = item.name
        if let amount = item.amount{
            cell.detailTextLabel?.text = "Amount: \(amount)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
        let alert = UIAlertController(title: "Remove Item", message: nil, preferredStyle: .alert)
        alert.addTextField{$0.placeholder = "Amount"}
        let addAction = UIAlertAction(title: "Remove", style: .default){_ in
            let amountText = alert.textFields?[0].text
            let amount = Int(amountText ?? "")
            
            let item = self.shoppingItems[indexPath.row]
            if let currentAmount = item.amount{
                let newAmount = currentAmount - (amount ?? 0)
                
                if newAmount > 0{
                    item.amount = newAmount
                    self.shoppingItems[indexPath.row].amount = newAmount
                    print(newAmount)
                    self.delegate?.moveItemBack(item: item,deleted: amount!)
//                    self.fridgeItems.append(item)
                    tableView.reloadData()
                }
                else{
//                    self.shoppingItems.append(item)
                    self.delegate?.moveItemBack(item: item, deleted: 0)
                    self.shoppingItems.remove(at:indexPath.row)
                    tableView.reloadData()
                }
            }
        }
        alert.addAction(addAction)
        present(alert, animated: true)
            
//        let item = shoppingItems[indexPath.row]
//        delegate?.moveItemBack(item: item)
    }
}
