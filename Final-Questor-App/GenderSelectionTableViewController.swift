//
//  GenderSelectionTableViewController.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 24/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class GenderSelectionTableViewController: UITableViewController {
    var reloaded = false
    var isLookingFor = false
    var selectedIndexPath: IndexPath? = IndexPath(row: 100, section: 100)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isLookingFor {
            return 3
        }else{
            return 2
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        // Configure the cell...
        if indexPath.row == 0 {
            cell.textLabel?.text = "Male"
        }else if indexPath.row == 1{
            cell.textLabel?.text = "Female"
        }else{
            cell.textLabel?.text = "Both"
        }
        if indexPath == selectedIndexPath {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        if reloaded == true{
            if indexPath.row == 0 {
                cell.textLabel?.text = "Dating"
            }else if indexPath.row == 1{
                cell.textLabel?.text = "Friends"
            }else{
                cell.textLabel?.text = "Both"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == selectedIndexPath {
            return
        }
        
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCellAccessoryType.none {
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        let oldCell = tableView.cellForRow(at: selectedIndexPath!)
        if oldCell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        selectedIndexPath = indexPath  // save the selected index path
        
        if isLookingFor == false {
            SessionManager.sharedInstance.user?.gender = indexPath.row as NSNumber!
        }else{
            SessionManager.sharedInstance.user?.lookingFor = indexPath.row as NSNumber!
        }
        
        if(isLookingFor == true){
            reloaded = true
            self.tableView.reloadData()
        }
        
        //Dismiss the view controller
        //self.dismissViewControllerAnimated(false, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
