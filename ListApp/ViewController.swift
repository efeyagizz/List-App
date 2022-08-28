//
//  ViewController.swift
//  ListApp
//
//  Created by Efe Yağız on 28.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableWiew: UITableView!
    
    var data = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableWiew.delegate = self
        tableWiew.dataSource = self
        fetch()
        
    }
    
    
    
    @IBAction func didRemoveBarButtonBarItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "Warning",
                     message: "Are you sure you want to delete all items in your list?",
                     preferredStyle: .alert,
                     defaultButtonTitle: "Yes",
                     cancelButtonTitle: "Cancel") { _ in
            //self.data.removeAll()
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Listitem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            do {
                try! managedObjectContext!.execute(deleteRequest)
                self.fetch()
            } catch let error as NSError {
                // TODO: handle the error
            }
            
        }
                
    }
    
    @IBAction func didAddBarItemButtonTapped(_ sender: UIBarButtonItem) {
        
        presentAddAlert()
        
        
    }

    func presentAddAlert() {
        presentAlert(title: "Add New Item",
                     message: nil,
                     defaultButtonTitle: "Add" ,
                     cancelButtonTitle: "Cancel",
                     isTextFieldAvailable: true,
                     defaultButtunHandler: {_ in
            let  text = self.alertController.textFields?.first?.text
            
            if text != "" {
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "Listitem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext!)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        })
    }
    
    func presentWarningAlert() {
        presentAlert(title: "Warning!",
                     message: "This area cannot be empty!",
                     cancelButtonTitle: "Cancel")
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtunHandler: ((UIAlertAction) -> Void)? = nil)
                      {
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                          
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtunHandler)
            alertController.addAction(defaultButton)
        }
        
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
                          
        if isTextFieldAvailable {
            alertController.addTextField()
        }

        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    func fetch() {
        let appDelagete = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelagete?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Listitem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableWiew.reloadData()
    }

}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
            self.presentAlert(title: "Warning",
                         message: "Are you sure you want to delete this item?",
                         preferredStyle: .alert,
                         defaultButtonTitle: "Yes",
                         cancelButtonTitle: "Cancel") { _ in
                
                let appDelagete = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelagete?.persistentContainer.viewContext
                
                managedObjectContext?.delete(self.data.remove(at: indexPath.row))
                
                try? managedObjectContext?.save()
                
                self.fetch()
            }
            self.tableWiew.reloadData()
        }
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
                
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            
            self.presentAlert(title: "Edit",
                         message: nil,
                         defaultButtonTitle: "Edit" ,
                         cancelButtonTitle: "Cancel",
                         isTextFieldAvailable: true,
                         defaultButtunHandler: {_ in
                let  text = self.alertController.textFields?.first?.text
                
                if text != "" {
                    
                    let appDelagete = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelagete?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableWiew.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            })
            self.tableWiew.reloadData()
        }
        editAction.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [editAction])
        
        return config
    }
}
