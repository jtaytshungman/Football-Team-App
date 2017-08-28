//
//  HomeViewController.swift
//  Football Team
//
//  Created by Jeremy Tay on 24/08/2017.
//  Copyright © 2017 Jeremy Tay. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    var footballTeams : [FootballTeam] = []
    var fetchRC : NSFetchedResultsController<FootballTeam>!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @IBAction func addNewTeamButtonTapped(_ sender: Any) {
        addNewFootballTeamPrompt()
    }
    
    func addNewFootballTeamPrompt () {
        // Alert Controller implementation
        let addNewTeamAlert = UIAlertController(title: "New Team", message: "Add a new team", preferredStyle: .alert)
        
        // TextField
        addNewTeamAlert.addTextField(configurationHandler: { (teamName) -> Void in
            teamName.placeholder = "Team Name"
        })
        addNewTeamAlert.addTextField { (teamManager) in
            teamManager.placeholder = "Team Manager"
        }
        addNewTeamAlert.addTextField { (teamCountry) in
            teamCountry.placeholder = "Team Country"
        }
        addNewTeamAlert.addTextField { (teamPrimaryLeague) in
            teamPrimaryLeague.placeholder = "Primary League"
        }
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addNewTeamAlert.addAction(cancel)
        
        // Add button
        let add = (UIAlertAction(title: "Save", style: .default, handler: { (action) in
            guard let newName = addNewTeamAlert.textFields?[0], let fbTeamName = newName.text else { return }
            guard let teamPrimaryLeague = addNewTeamAlert.textFields?[1], let fbPrimaryLeague = teamPrimaryLeague.text else { return }
            guard let newCountry = addNewTeamAlert.textFields?[2], let fbTeamCountry = newCountry.text else { return }
            guard let newManager = addNewTeamAlert.textFields?[3], let fbTeamManager = newManager.text else { return }
            
            
            
            
            if fbTeamName.replacingOccurrences(of: " ", with: "") == "" {
                return self.emptyWarningPrompt()            }
            if fbTeamManager.replacingOccurrences(of: " ", with: "") == "" {
                return self.emptyWarningPrompt()
            }
            if fbTeamCountry.replacingOccurrences(of: " ", with: "") == "" {
                return self.emptyWarningPrompt()
            }
            if fbPrimaryLeague.replacingOccurrences(of: " ", with: "") == "" {
                return self.emptyWarningPrompt()
            }
                
            guard let desc = NSEntityDescription.entity(forEntityName: "FootballTeam", in: DataController.moc) else { return }
            let newTeam = FootballTeam(entity: desc, insertInto: DataController.moc)
        
            newTeam.footballTeamName = fbTeamName
            newTeam.managerName = fbTeamManager
            newTeam.country = fbTeamCountry
            newTeam.primaryLeague = fbPrimaryLeague
            
            DataController.saveContext()
                
        }))
        addNewTeamAlert.addAction(add)
        
        // Show in VC
        present (addNewTeamAlert, animated: true, completion: nil)
    }
    
    func emptyWarningPrompt () {
        let errorPrompt = UIAlertController(title: "Warning", message: "Don't leave text field blank", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Understand", style: .default, handler: nil)
        errorPrompt.addAction(cancel)
        present(errorPrompt, animated: true, completion:  nil)
    }
    
    func loadData() {
        let request = NSFetchRequest<FootballTeam>(entityName: "FootballTeam")
        
        let sort = NSSortDescriptor(key: "footballTeamName", ascending: true)
        request.sortDescriptors = [sort]

        fetchRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataController.moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchRC.delegate = self
        //tableView.reloadData()
        
        do {
            try fetchRC.performFetch()
            tableView.reloadData()
            
        }
        catch {
            
        }
        
    }

}

extension HomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRC.fetchedObjects?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let fbTeam = fetchRC.fetchedObjects?[indexPath.row]
        
        // cell.textLabel?.text = fbTeam.footballTeamName
        cell.textLabel?.text = fbTeam?.footballTeamName
        cell.detailTextLabel?.text = fbTeam?.country
        
        return cell
    }
}

extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fbTeamSelected = fetchRC.object(at: indexPath) //footballTeams[indexPath.row]
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else { return }
        
        detailVC.delegate = self 
        detailVC.fbTeam = fbTeamSelected
        detailVC.index = indexPath.row
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController : DeleteTeamDelegate {
    func deleteTeam (at index : Int) {
        fetchRC.object(at: )
    }
}

extension HomeViewController : NSFetchedResultsControllerDelegate {
    open override func willChangeValue(forKey key: String) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            guard let ip = newIndexPath else {
                return
            }
            tableView.insertRows(at: [ip], with: .right)
        case .update:
            print("update")
            guard let ip = newIndexPath else {
                return
            }
            tableView.reloadRows(at: [ip], with: .bottom)
        case .move:
            print("move")
            guard let oldIndex = indexPath,
                let newIndex = newIndexPath
                else { return }
            tableView.moveRow(at: oldIndex, to: newIndex)
        case .delete:
            print("delete")
            guard let ip = indexPath else {
                return
            }
            tableView.deleteRows(at: [ip], with: .fade)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}






