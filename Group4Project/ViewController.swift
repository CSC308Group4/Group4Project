import UIKit

//for data transsfer
protocol ShoppingDelegate: AnyObject{
    func moveItemBack(item: Item, deleted: Int)
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ShoppingDelegate {

    var fridgeItems: [Item] = []
    var shoppingItems: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Shopping List", style: .plain, target: self, action: #selector(openShopping)
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @objc func openShopping(){
        performSegue(withIdentifier: "toShopping", sender: self)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @objc func addItem(){
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField{$0.placeholder = "Item name"}
        alert.addTextField{$0.placeholder = "Amount"}
        
        let addAction = UIAlertAction(title: "Add", style: .default){_ in
            let name = alert.textFields?[0].text ?? "Unknown"
            let amountText = alert.textFields?[1].text
            
            guard let amount = Int(amountText ?? "1"), amount>0 else{
                return
            }
            print(name)
            print(amount)
            
            if !self.fridgeItems.isEmpty, let index = self.fridgeItems.firstIndex(where: {$0.name == name}){
                self.fridgeItems[index].amount! += amount
            }else{
                let fridgeItem = Item(name: name, amount: amount)
                self.fridgeItems.append(fridgeItem)
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    //tableview stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fridgeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeCell", for: indexPath)
        let item = fridgeItems[indexPath.row]
        cell.textLabel?.text = item.name
        
        if let amount = item.amount{
            cell.detailTextLabel?.text = "Amount: \(amount)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of items in fridge"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        let alert = UIAlertController(title: "Remove Item", message: nil, preferredStyle: .alert)
        alert.addTextField{$0.placeholder = "Amount"}
        let addAction = UIAlertAction(title: "Remove", style: .default){_ in
            let amountText = alert.textFields?[0].text
            let amount = Int(amountText ?? "")
            
            var item = self.fridgeItems[indexPath.row]
            if let currentAmount = item.amount{
                let newAmount = currentAmount - (amount ?? 0)
                
                if newAmount > 0{
                    item.amount = newAmount
                    if let index = self.shoppingItems.firstIndex(where: {$0.name == item.name}){
                        self.shoppingItems[index].amount! += amount!
                    }else{
                        let shoppingItem = Item(name: item.name, amount: amount)
                        self.shoppingItems.append(shoppingItem)
                    }
                    tableView.reloadData()
                }
                else{
                    self.shoppingItems.append(item)
                    self.fridgeItems.remove(at:indexPath.row)
                    tableView.reloadData()
                }
            }
        }
        alert.addAction(addAction)
        present(alert, animated: true)
      
    }
    
    
    
    //data transfer delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "toShopping"{
            let dest = segue.destination as! ShoppingViewController
            dest.shoppingItems = shoppingItems
            dest.delegate = self
        }
    }
    
    func moveItemBack(item: Item, deleted: Int){
        let shoppingItem = Item(name: item.name,amount: item.amount!)
        shoppingItems.append(shoppingItem)
        if deleted > 0{
            let fridgeItem = Item(name: item.name,amount: deleted)
            fridgeItems.append(fridgeItem)
        }
        tableView.reloadData()
    }
}

