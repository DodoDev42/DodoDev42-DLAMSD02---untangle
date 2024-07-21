//
//  CategoryViewController.swift
//  untangle
//
//  Created by Ben on 21.06.24.
//

import UIKit
import CoreData

class GroupsViewController: UITableViewController {
    
    var groupArray = [Group]()
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }

    
    // generate table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath)
        let item = groupArray[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
    
    // items on select
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! ItemsViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedGroup = groupArray[indexPath.row]
            }
        }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Group> = Group.fetchRequest()) {
        do {
            groupArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }

    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "erstelle eine neue Gruppe", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Gruppe hinzufügen", style: .default) { (action) in
            let newGroup = Group(context: self.context)
            newGroup.title = textField.text!
            self.groupArray.append(newGroup)
            self.saveItems()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "neues Gruppe"
            textField = alertTextField
        }
        present(alert,animated: true,completion: nil)
    }
    
    // Swipe

    private func handleMoveToTrash(indexPath: IndexPath) {
        print("Moved to trash")
        saveItems()
        context.delete(groupArray[indexPath.row])
        groupArray.remove(at: indexPath.row)
        saveItems()
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

