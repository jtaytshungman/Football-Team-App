//
//  DetailsViewController.swift
//  Football Team
//
//  Created by Jeremy Tay on 24/08/2017.
//  Copyright © 2017 Jeremy Tay. All rights reserved.
//

import UIKit
import CoreData

protocol DeleteTeamDelegate {
    func deleteTeam (at : Int)
}

class DetailsViewController: UIViewController {

    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var primaryLeagueTextField: UITextField!
    @IBOutlet weak var managerNameTextField: UITextField!
    
    
    var fbTeam : FootballTeam?
    var index : Int?
    var delegate : DeleteTeamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamNameTextField.text = fbTeam?.footballTeamName
        countryTextField.text = fbTeam?.country
        primaryLeagueTextField.text = fbTeam?.primaryLeague
        managerNameTextField.text = fbTeam?.managerName
        
        
    }
    

    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let fbT = fbTeam else { return }
        
        if let i = index {
            delegate?.deleteTeam(at: i)
        }
        
        DataController.moc.delete(fbT)
        DataController.saveContext()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let fbTeamName = teamNameTextField.text else { return }
        guard let fbTeamCountry = countryTextField.text else { return }
        guard let fbTeamLeague = primaryLeagueTextField.text else { return }
        guard let fbManagerName = managerNameTextField.text else { return }
        
        if fbTeamName == "" {
            return emptyWarningPrompt()
        }
        
        if (fbTeam?.footballTeamName == fbTeamName && fbTeam?.country == fbTeamCountry && fbTeam?.primaryLeague == fbTeamLeague) {
            print("User data unchanged")
            return
        }
        
        fbTeam?.footballTeamName = fbTeamName
        fbTeam?.country = fbTeamCountry
        fbTeam?.primaryLeague = fbTeamLeague
        fbTeam?.managerName = fbManagerName
        
        DataController.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
    func emptyWarningPrompt () {
        let errorPrompt = UIAlertController(title: "Warning", message: "Don't leave text field blank", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        errorPrompt.addAction(cancel)
        present(errorPrompt, animated: true, completion:  nil)
    }

}
