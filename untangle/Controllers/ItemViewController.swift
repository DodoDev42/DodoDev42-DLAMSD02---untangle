import UIKit
import CoreData

class ItemViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var myTextView: UITextView!
    
    var selectedItem: Item? {
        didSet {
            if let selectedItem = selectedItem {
                self.title = selectedItem.title
                let text = selectedItem.text ?? ""
                
                if isViewLoaded {
                    myTextView.text = text
                }
                saveItem()
            }
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTextView.delegate = self
        
        // Setze den Text des Textfeldes, falls selectedItem schon initialisiert wurde
        if let selectedItem = selectedItem {
            myTextView.text = selectedItem.text ?? ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Aktion ausführen, wenn der Text im TextView geändert wird
        let updatedText = textView.text
        // print("Text updated to: \(updatedText ?? "")")
        
        // Aktualisiere das ausgewählte Item
        selectedItem?.text = updatedText
        saveItem()
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
}
