//
//  VegetableTableViewController.swift
//  FoodTrackerPL1
//
//  Created by Jose Ribeiro on 10/11/2020.
//

import UIKit
import os.log
import Firebase

class AllVegetableTableViewController: UITableViewController{
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    
    
    var vegetables = [Vegetable]()
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredVegetables: [Vegetable] = []
    
    
    
    
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /***Zona de pesquisa*/
        
        // 1
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Vegetables"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        
        //*************************
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
       // storeDataDummy()
        loadAllVegetablesFromWeb()
        
      
        
    }
    
    private func storeDataDummy(){
        func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in letters.randomElement()! })
        }
        let array = ["Alface", "Tomate", "Pepino", "Couve","Courgete","Cenoura","Beterraba","Couve-Coracao-Boi","Batata","Batata Doce","Broculos"]
        
        for item in 1...250 {
            db.collection("vegetables").addDocument(data:[
                "batchID": randomString(length: 8),
                "co2": String(Int.random(in: 0...100)),
                "cultivation":                "Tradicional",
                "eDate":                "13/12/2020",
                "hDate":                "12/11/2020",
                "humidity":                String(Int.random(in: 0...100)),
                "localization":           "Coimbra",
                "name":   array.randomElement()!,
                "origin":                "Holanda",
                "shock": String(Int.random(in: 0...10)),
                "temperature": String(Int.random(in: 0...50)),
                "tilt": String(Int.random(in: 0...10)),
                "weight":String(Int.random(in: 0...100000))
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        
    }
    
    private func loadAllVegetablesFromWeb() {
        
        var myVegetablesToRemoveFromAll = [String]()
        let user = "6OUXNouLZ84WQVYneeqM"
        print(1)
        self.db.collection("users").document(user).getDocument{ (document, error) in
            if let document = document, document.exists {
                myVegetablesToRemoveFromAll = document.data()!["myFavoriteVegetables"]! as! [String]
                myVegetablesToRemoveFromAll += document.data()!["myPurchasedVegetables"]! as! [String]
                

                self.db.collection("vegetables").whereField("batchID", notIn: myVegetablesToRemoveFromAll)
                    .getDocuments() { (querySnapshot, err)   in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                //
                                //
                                let photo1 = UIImage(named: "vegetable1")
                                let batchID = document.get("batchID") as! String
                                let name = document.get("name") as! String
                                print("name: " , name)
                                print("batchID: " , batchID)
                                
                                guard let vegetable = Vegetable(batchID: batchID, name: name, photo: photo1) else {
                                    fatalError("Unable to instantiate vegetable")
                                }
                                self.vegetables += [vegetable]
                                print("Nivel 1: ",self.vegetables.count)
                                
                                
                                
                            }
                            self.tableView.reloadData()
                        }
                    }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    private func loadSampleVegetables() {
        
        
        let photo1 = UIImage(named: "vegetable1")
        
        let photo2 = UIImage(named: "vegetable2")
        let photo3 = UIImage(named: "vegetable3")
        
        guard let vegetable1 = Vegetable(batchID:"3213123", name: "Caprese Salad", photo: photo1) else {
            fatalError("Unable to instantiate vegetable1")
        }
        
        guard let vegetable2 = Vegetable(batchID:"32131df23", name: "Chicken and Potatoes", photo: photo2) else {
            fatalError("Unable to instantiate vegetable2")
        }
        
        guard let vegetable3 = Vegetable(batchID:"321312ku3", name: "Pasta with Meatballs", photo: photo3) else {
            fatalError("Unable to instantiate vegetable2")
        }
        guard let vegetable4 = Vegetable(batchID:"321312ku3", name: "Pasta with Meatballs", photo: photo3) else {
            fatalError("Unable to instantiate vegetable2")
        }
        
        
        vegetables += [vegetable1, vegetable2, vegetable3, vegetable4]
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredVegetables.count
        }
        
        return vegetables.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FavoriteVegetableTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoriteVegetableTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavoriteVegetableTableViewCell.")
        }
        
        // Fetches the appropriate vegetable for the data source layout.
        let vegetable:Vegetable
        
        if isFiltering {
            vegetable = filteredVegetables[indexPath.row]
        } else {
            vegetable = vegetables[indexPath.row]
        }
        
        cell.nameLabel.text = vegetable.name
        cell.photoImageView.image = vegetable.photo

        
        cell.favButtonAction = { [unowned self] in
             
            let alert = UIAlertController(title: "Add to favorites!", message: "Added  \(vegetable.name)", preferredStyle: .alert)
             let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
             alert.addAction(okAction)
                   
             self.present(alert, animated: true, completion: nil)
            
            removeFavoriteFromList(batchID: vegetable.batchID,position: indexPath.row)
            
           }
        
        
        return cell
    }
    private func removeFavoriteFromList(batchID: String, position: Int){
        let user = "6OUXNouLZ84WQVYneeqM"
        db.collection("users").document(String(user)).updateData(["myFavoriteVegetables": FieldValue.arrayUnion([batchID])])
        self.vegetables.remove(at: position)
        
        tableView.reloadData()
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            vegetables.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new vegetable.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let vegetableDetailViewController = segue.destination as? VegetableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedVegetableCell = sender as? FavoriteVegetableTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedVegetableCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedVegetable = vegetables[indexPath.row]
            vegetableDetailViewController.vegetable = selectedVegetable
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    
    
    
    
    @IBAction func unwindToVegetableList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? VegetableViewController,
           let vegetable = sourceViewController.vegetable {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing vegetable.
                vegetables[selectedIndexPath.row] = vegetable
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new vegetable.
                let newIndexPath = IndexPath(row: vegetables.count, section: 0)
                vegetables.append(vegetable)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
            }
        }
    }
    
    
    func filterContentForSearchText(_ searchText: String,
                                    category: String? = nil) {
        filteredVegetables = vegetables.filter { (vegetable: Vegetable) -> Bool in
            return vegetable.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
}
extension AllVegetableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = "vategory"
        filterContentForSearchText(searchBar.text!, category: category)
    }
}

extension AllVegetableTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = "vategory"
        filterContentForSearchText(searchBar.text!, category: category)
    }
}
