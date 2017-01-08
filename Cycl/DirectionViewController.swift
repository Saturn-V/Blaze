//
//  DirectionViewController.swift
//  Cycl
//
//  Created by Miriam Hendler on 12/27/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import UIKit

class DirectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var destinationLabel: UILabel!
    
    var directions: [String] = []
    var destination = "To "
    override func viewDidLoad() {
        super.viewDidLoad()
        
        destinationLabel.text = destination
        
        tableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TableView Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DirectionTableViewCell
        
        if directions != [] {
            
            let direction = directions[indexPath.row]
            cell.directionDescriptionLabel.text = direction
            cell.directionDescriptionLabel.textColor = .white
            
            if direction.contains("Continue") {
                cell.directionImageView.image = UIImage(named: "north")
            }
            else if direction.contains("south") || direction.contains("U-turn") {
                cell.directionImageView.image = UIImage(named: "south")
            }
            else if direction.contains("right") {
                cell.directionImageView.image = UIImage(named: "right")
            }
            else if direction.contains("left") {
                cell.directionImageView.image = UIImage(named: "left")
            }
            else {
                cell.directionImageView.image = UIImage(named: "north")
            }
        }
        
        if indexPath.item % 2 == 0 {
            cell.backgroundColor = colorWithHexString(hex: "#F99273")
        } else {
            cell.backgroundColor = colorWithHexString(hex: "#FFA991")
        }
        return cell
    }
}
