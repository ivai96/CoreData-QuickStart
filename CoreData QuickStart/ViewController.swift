//
//  ViewController.swift
//  CoreData QuickStart
//
//  Created by Ivana Krivchevska on 7/26/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Data for the table
    var items:[Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //Get items from Core Data
        fetchPeople()
    }
    
    func fetchPeople() {
        
        //Fetch the data from Core Data to display it in the tableview
        do {
            
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            //Set filtering and sorting on the request
            let predicate = NSPredicate(format: "name CONTAINS %@", "Ivana")
            //request.predicate = predicate
            
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            self.items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }
    
    func relationshipDemo() {
        
        //Create a family
        let family = Family(context: context)
        family.name = "X Family"
      
        //Create a person
        let person = Person(context: context)
        person.name = "Neo"
        
        //One way to set a relationship
       // person.family = family
        
        //Another wat to set a relationship
        family.addToPeople(person)
        
        //Save the context
        try! context.save()
    }

    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Person", message: "what is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        //Configure button handler
        let submitButton = UIAlertAction(title: "Add", style: .default) {
            (action) in
            
            //Get the textfield for the alert
            let textField = alert.textFields![0]
            
            //Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = textField.text
            newPerson.age = 24
            newPerson.gender = "Female"
            
            //Save the data
            do {
               try self.context.save()
            }
            catch {
                //TODO: Catch possible errors
            }
            
            //Re-fetch the data
            self.fetchPeople()
        }
        
        //Add button
        alert.addAction(submitButton)
        
        //Show alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Return the number of people
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        //Get person from the array and set the label
        let person = self.items?[indexPath.row]
        
        cell.textLabel?.text = person?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Selected person
        let person = self.items![indexPath.row]
        
        //Create aler
        let alert = UIAlertController(title: "Edit Person", message: "Edit name", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0]
        textField.text = person.name
        
        //Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) {  (action) in
        
            let textField = alert.textFields![0]
            
            person.name = textField.text
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchPeople()
        }
        
        //Add button
        alert.addAction(saveButton)
        
        //Show the aler
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complitionHandler) in
            
            //Witch person to remove
            let personToRemove = self.items![indexPath.row]
            
            //Remove the person
            self.context.delete(personToRemove)
            
            //Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            //Re-fetch the data
            self.fetchPeople()
        }
        
        //Return swipe action
        return UISwipeActionsConfiguration(actions: [action])
    }
}

