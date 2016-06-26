//
//  AddToOrderTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import GMStepper

class AddToOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // TODO: get USER ID
    //let yourObject: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("userID")
    
    
    
    
    // Create struct to organize data
    struct SideItem {
        var sideName: String
        var sidePrice: String
        var sideRequired: String
    }
    
    // Create empty array of Restaurants to be filled in ViewDidLoad
    var sideItems: [SideItem] = []
    
    // DATA
    var sideNames = [String]()
    var sidePrices = [String]()
    var sideRequireds = [String]()
    
    // DATA
    var sectionNames = [String]() //["SIDES (PICK 2)", "EXTRAS", "SPECIAL INSTRUCTIONS"]
    var section1 = [String]()
    var section2 = [String]()
    var section2Prices = [String]()
    let section3 = "E.g. Easy on the mayo, add bacon"
    
    // MARK: - IBOutlets
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var foodDescriptionLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var stepper: GMStepper!
    
    // Data passed from previous View Controller
    var selectedFoodName = ""
    var selectedFoodDescription = ""
    var selectedFoodPrice = ""
    var selectedFoodID = ""
    var selectedFoodSidesNum = ""
    
    // Backend Data
    var sidesIDList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.title = selectedFoodName
        
        // Set food description label
        foodDescriptionLabel.text = selectedFoodDescription
        
        // Set custom nav bar font
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Display price in nav bar
        self.navigationItem.rightBarButtonItem?.title = selectedFoodPrice
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: TITLE_FONT,
            NSForegroundColorAttributeName: GREEN], forState: .Normal)
        
        // Set tableView cells to custom height and automatically resize if needed
        myTableView.estimatedRowHeight = 50
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Set stepper font
        stepper.labelFont = UIFont(name: "Avenir-Medium", size: 20)!
        stepper.buttonsFont = UIFont(name: "Avenir-Black", size: 20)!
        
        print("Selected Food ID: " + selectedFoodID)
        print("How many sides this food item can have: " + selectedFoodSidesNum)
        sectionNames.append("SIDES (PICK " + selectedFoodSidesNum + ")")
        sectionNames.append("EXTRAS")
        sectionNames.append("SPECIAL INSTRUCTIONS")
        
        // Open Connection to PHP Service to menuSides
        let requestURL1: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuSides.php")!
        let urlRequest1: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL1)
        let session1 = NSURLSession.sharedSession()
        let task1 = session1.dataTaskWithRequest(urlRequest1) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                let side_id = Restaurant["id"] as! String
                                if (self.sidesIDList.contains(side_id)) {
                                    print(Restaurant["name"] as! String)
                                    self.sideNames.append(Restaurant["name"] as! String)
                                    self.sidePrices.append(Restaurant["price"] as! String)
                                    self.sideRequireds.append(Restaurant["required"] as! String)
                                }
                            }
                            
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // Loop through DB data and append Restaurant objects into restaurants array
                                for i in 0..<self.sideNames.count {
                                    self.sideItems.append(SideItem(sideName: self.sideNames[i], sidePrice: self.sidePrices[i], sideRequired: self.sideRequireds[i]))
                                }
                                for i in 0..<self.sideItems.count {
                                    // If required and price == 0, Section 1
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice == "0") {
                                        self.section1.append(self.sideItems[i].sideName)
                                        print("S1:" + self.sideItems[i].sideName)
                                    }
                                    // If required and price !=0, Section 2
                                    if (self.sideItems[i].sideRequired == "1" && self.sideItems[i].sidePrice != "0") {
                                        self.section2.append(self.sideItems[i].sideName)
                                        print("S2:" + self.sideItems[i].sideName)
                                        self.section2Prices.append(self.sideItems[i].sidePrice)
                                        print("S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                    // If not required, Section 2
                                    if (self.sideItems[i].sideRequired == "0") {
                                        self.section2.append(self.sideItems[i].sideName)
                                        print("S2:" + self.sideItems[i].sideName)
                                        self.section2Prices.append(self.sideItems[i].sidePrice)
                                        print("S2Price:" + self.sideItems[i].sidePrice)
                                    }
                                }
                                
                                self.myTableView.reloadData()
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error:" + error.localizedDescription)
                }
            } else if let error = error {
                print("Error:" + error.localizedDescription)
            }
        }
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADmenuSidesItemLink.php")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            for Restaurant in json as! [Dictionary<String, AnyObject>] {
                                var item_id: String?
                                item_id = Restaurant["item_id"] as? String
                                if (item_id == nil) {
                                } else {
                                    // loop through item_id's and make an array of corresponding sides_id's
                                    if (self.selectedFoodID == item_id) {
                                        let sides_id = Restaurant["sides_id"] as! String
                                        self.sidesIDList.append(sides_id)
                                    }
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                for i in 0..<self.sidesIDList.count {
                                    print("SidesIDs: " + self.sidesIDList[i])
                                }
                                
                                // Only create list of actual sides after the ID's have been collected
                                task1.resume()
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error:" + error.localizedDescription)
                }
            } else if let error = error {
                print("Error:" + error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    override func viewWillAppear(animated: Bool) {
        // BUGGY - Add bottomView to bottom of screen
        /*self.tableView.tableFooterView = nil
         self.bottomView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.tableView.frame.size.height - self.tableView.contentSize.height - self.bottomView.frame.size.height)
         self.tableView.tableFooterView = self.bottomView*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TO-DO: FINISH THIS METHOD
    @IBAction func addToOrderButtonPressed(sender: UIButton) {
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNames.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section1.count
        } else if section == 1 {
            return section2.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            // ISSUE: If it says pick X, you can still pick as many or as few as you want
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section1[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = true
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addToOrderCell", forIndexPath: indexPath) as! AddToOrderTableViewCell
            
            cell.radioButton.multipleSelectionEnabled = true
            cell.radioButton.setTitle(section2[indexPath.row], forState: .Normal)
            cell.extraCostLabel.hidden = false
            cell.extraCostLabel.text = section2Prices[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("specialInstructionsCell", forIndexPath: indexPath) as! AddToOrderSpecialInstructionsTableViewCell
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    // Set up custom header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
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