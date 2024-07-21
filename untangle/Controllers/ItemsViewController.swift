//
//  ViewController.swift
//  untangle
//
//  Created by Ben on 21.06.24.
//

import UIKit
import CoreData

class ItemsViewController: UITableViewController {

    
    var itemArray = [Item]()
    var selectedGroup : Group? {
        didSet {
            loadItems()
            self.title = selectedGroup!.title
        }
    }
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // generate table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemsCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let groupPredicate = NSPredicate(format: "parentGroup.title MATCHES %@", selectedGroup!.title!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [groupPredicate,additionalPredicate])
        } else {
            request.predicate = groupPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
    
    // add new item
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "füge deiner liste ein neues Item hinzu", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Item hinzufügen", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.text = ""
            newItem.done = false
            
            newItem.parentGroup = self.selectedGroup
            self.itemArray.append(newItem)
            self.saveItems()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "neues Item"
            textField = alertTextField
        }
        present(alert,animated: true,completion: nil)
    }
}


extension ItemsViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@",searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }
    
    // details on select
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    // Swipe
    

    private func handleMoveToTrash(indexPath: IndexPath) {
        print("Moved to trash")
        saveItems()
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        saveItems()
    }

    private func handleToggleDone(indexPath: IndexPath) {
        print("Toggle Done")
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! ItemViewController
        print("1")
            if let indexPath = tableView.indexPathForSelectedRow {
                print("2")
                print(itemArray[indexPath.row])
                destinationVC.selectedItem = itemArray[indexPath.row]
            }
        }
    
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Toggle Done") { [weak self] (action, view, completionHandler) in
                                            self?.handleToggleDone(indexPath: indexPath)
                                            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Trash") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToTrash(indexPath: indexPath)
                                        completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])

        return configuration
    }
}
