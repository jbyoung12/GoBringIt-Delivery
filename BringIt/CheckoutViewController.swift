//
//  CheckoutViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/26/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

var comingFromOrderPlaced = false

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var itemsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var subtotalCostLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    var cameFromVC = ""
    var deliverTo = ""
    var payWith = ""
    var totalCost = 0.0
    var selectedCell = 0
    var deliveryFee = 0.0
    
    var items_ordered: [String] = []
    var items = [Item]()
    var service_id = ""
    
    // TO-DO: CHAD! So I've created 3 more fields in the struct for you to put the sides, extras and special instructions in. The way you can format it is to pull all the sides and extras and special instructions associated with one item, and create a single string with all the sides/extras separated by commas. For example, "Mashed Potatoes, Fries, Mac & Cheese". I will deal with other formatting later!
    // Data structure
    struct Item {
        var name = ""
        var quantity = 0
        var price = 0.00
        var sides = ""
        var extras = ""
        var specialInstructions = ""
    }
    
    // Get USER ID
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start activity indicator
        myActivityIndicator.startAnimating()
        self.myActivityIndicator.hidden = false
        
        // Set title
        self.title = "Checkout"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Get Address of User
        // var userID: String?
        let userID = self.defaults.objectForKey("userID") as AnyObject! as! String
        var addressString: String?
        
        // Open Connection to PHP Service
        let requestURL4: NSURL = NSURL(string: "http://www.gobring.it/CHADrestaurantImage.php")!
        let urlRequest4: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL4)
        let session4 = NSURLSession.sharedSession()
        let task4 = session4.dataTaskWithRequest(urlRequest4) { (data, response, error) -> Void in
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
                                //var account_id: String?
                                let id = Restaurant["id"] as! String
                                if ( id == self.service_id ) {
                                    let delivery_fee = Restaurant["delivery_fee"] as AnyObject! as! String
                                    print(delivery_fee)
                                    self.deliveryFee = Double(delivery_fee)!
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                //THIS IS WHERE WE NEED TO RELOAD EVERYTHING
                                self.itemsTableView.reloadData()
                                self.detailsTableView.reloadData()
                                self.updateViewConstraints()
                                
                                // Calculate and display delivery Fee and totalCost
                                self.calculateTotalCost()
                                self.deliveryFeeLabel.text = String(format: "$%.2f", self.deliveryFee)
                                self.subtotalCostLabel.text = String(format: "$%.2f", self.totalCost)
                                self.totalCostLabel.text = String(format: "$%.2f", self.totalCost + self.deliveryFee)
                                
                                // Stop activity indicator
                                self.myActivityIndicator.stopAnimating()
                                self.myActivityIndicator.hidden = true
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
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADaccountAddresses.php")!
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
                                //var account_id: String?
                                let account_id = Restaurant["account_id"] as! String
                                if ( account_id.rangeOfString(userID) != nil ) {
                                    print(userID)
                                    print(Restaurant["street"] as? String)
                                    let street = Restaurant["street"] as AnyObject! as! String //+ ", " + Restaurant["apartment"] as AnyObject! as! String
                                    let apartment = Restaurant["apartment"] as AnyObject! as! String
                                    addressString = street + ", " + apartment
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                print(addressString!)
                                self.deliverTo = addressString!
                                self.detailsTableView.reloadData()
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
        
        let requestURL3: NSURL = NSURL(string: "http://www.gobring.it/CHADitems.php")!
        let urlRequest3: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL3)
        let session3 = NSURLSession.sharedSession()
        let task3 = session3.dataTaskWithRequest(urlRequest3) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            for Cart in json as! [Dictionary<String, AnyObject>] {
                                
                                let id = Cart["id"] as! String
                                
                                if self.items_ordered.contains(id) {
                                    print("this item id exists")
                                    print(Cart["name"] as! String)
                                    print(Cart["price"] as! String)
                                    
                                    //CHAD! Pull from the db and replace the dummy variables here
                                    self.items.append(Item(name: Cart["name"] as! String, quantity: 10, price: Double(Cart["price"] as! String)!, sides: "Mashed Potatoes, Truffle Fries", extras: "Extra sauce, Ranch wings", specialInstructions: "Please add a few bags of ketchup."))
                                    self.service_id = Cart["service_id"] as! String
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                task.resume()
                                task4.resume()
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
        
        // go through carts DB
        // filter by user_id
        // filter by active
        // save all the item_id's in an array
        // Open Connection to PHP Service to carts DB to find an active cart
        let requestURL2: NSURL = NSURL(string: "http://www.gobring.it/CHADcarts.php")!
        let urlRequest2: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL2)
        let session2 = NSURLSession.sharedSession()
        let task2 = session2.dataTaskWithRequest(urlRequest2) { (data, response, error) -> Void in
            if let data = data {
                do {
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    // Check HTTP Response
                    if (statusCode == 200) {
                        
                        do{
                            // Parse JSON
                            let json = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
                            
                            for Cart in json as! [Dictionary<String, AnyObject>] {
                                
                                //let order_id = Cart["order_id"] as! String
                                
                                let user_id = Cart["user_id"] as! String
                                
                                if (userID == user_id) {
                                    let active_cart = Cart["active"] as! String
                                    if (active_cart == "1") {
                                        //print(order_id)
                                        self.items_ordered.append(Cart["item_id"] as! String)
                                    }
                                }
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                for item in self.items_ordered {
                                    print("Item here:", item)
                                }

                                task3.resume()
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
        
        task2.resume();
        
        
        // go through menu_items DB
        // for all the elements with item_id matching in the previous array, save the name, price, and 1 service_id
        // this is done in task3
        
        // go through category_items DB
        // filter by service_id from previous
        // save delivery_fee
        
        /*var addressString: String?
        
        // Open Connection to PHP Service
        let requestURL: NSURL = NSURL(string: "http://www.gobring.it/CHADaccountAddresses.php")!
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
                                //var account_id: String?
                                let account_id = Restaurant["account_id"] as! String
                                    if ( account_id.rangeOfString(userID) != nil ) {
                                        print(userID)
                                        print(Restaurant["street"] as? String)
                                        let street = Restaurant["street"] as AnyObject! as! String //+ ", " + Restaurant["apartment"] as AnyObject! as! String
                                        let apartment = Restaurant["apartment"] as AnyObject! as! String
                                        addressString = street + ", " + apartment
                                    }
                                }
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                print(addressString!)
                                self.deliverTo = addressString!
                                self.detailsTableView.reloadData()
                                self.itemsTableView.reloadData();
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.itemsTableView.reloadData()
                                })
                                self.itemsTableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Error:" + error.localizedDescription)
                }
            } else if let error = error {
                print("Error:" + error.localizedDescription)
            }
        }*/
        
        //task.resume()

        // Set SAMPLE DATA
        //deliverTo = "1369 Campus Drive"
        payWith = "Food Points"

        /*self.itemsTableView.reloadData();
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.itemsTableView.reloadData()
        })
        self.itemsTableView.performSelectorOnMainThread(#selector(UITableView.reloadData), withObject: nil, waitUntilDone: true)*/

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        if comingFromOrderPlaced == true {
            comingFromOrderPlaced = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTotalCost() {
        totalCost = 0.0
        for item in items {
            totalCost += Double(item.price) * Double(item.quantity)
        }
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == itemsTableView {
            return items.count
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == itemsTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutCell", forIndexPath: indexPath) as! CheckoutTableViewCell
            
            cell.itemNameLabel.text = items[indexPath.row].name
            cell.itemQuantityLabel.text = String(items[indexPath.row].quantity)
            let totalItemCost = Double(items[indexPath.row].quantity) * items[indexPath.row].price
            cell.totalCostLabel.text = String(format: "%.2f", totalItemCost)
            
            let sides = "Sides: \(items[indexPath.row].sides)"
            let extras = "Extras: \(items[indexPath.row].extras)"
            let specialInstructions = "Special Instructions: \(items[indexPath.row].specialInstructions)"
            
            // Create attributed strings of the extras
            var sidesAS = NSMutableAttributedString()
            var extrasAS = NSMutableAttributedString()
            var specialInstructionsAS = NSMutableAttributedString()
            
            sidesAS = NSMutableAttributedString(
                string: sides,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            extrasAS = NSMutableAttributedString(
                string: extras,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            specialInstructionsAS = NSMutableAttributedString(
                string: specialInstructions,
                attributes: [NSFontAttributeName:UIFont(
                    name: "Avenir",
                    size: 13.0)!])
            
            sidesAS.addAttribute(NSFontAttributeName,
                                    value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                    range: NSRange(
                                    location: 0,
                                    length: 6))
            extrasAS.addAttribute(NSFontAttributeName,
                                 value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                 range: NSRange(
                                    location: 0,
                                    length: 7))
            specialInstructionsAS.addAttribute(NSFontAttributeName,
                                 value: UIFont(
                                    name: "Avenir-Heavy",
                                    size: 13.0)!,
                                 range: NSRange(
                                    location: 0,
                                    length: 21))
            
            cell.sidesLabel.attributedText = sidesAS
                cell.extrasLabel.attributedText = extrasAS
                cell.specialInstructionsLabel.attributedText = specialInstructionsAS
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("checkoutDetailsCell", forIndexPath: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Deliver To"
                cell.detailTextLabel?.text = deliverTo
            } else {
                cell.textLabel?.text = "Pay With"
                cell.detailTextLabel?.text = payWith
            }
            
            return cell
        }
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        itemsTableViewHeight.constant = itemsTableView.contentSize.height
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == itemsTableView {
            if editingStyle == .Delete {
                // Delete the row from the data source
                
                // TO-DO: CHAD! Please remove this item from the cart in the db. This needs to happen here (or we need to store the whole cart locally) in case the user deletes a couple of rows and then clicks X to browse a bit more or quits out of the app.
                // Write code hereeeeee
                
                items.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    // Find out which cell was selected and sent to prepareForSegue
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedCell = indexPath.row
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == itemsTableView {
            performSegueWithIdentifier("toChangeOrder", sender: self)
        }
    }
    
    
    @IBAction func checkoutButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Checkout", message: "Are you sure you want to checkout?", preferredStyle: .ActionSheet)
        let checkout = UIAlertAction(title: "Yes, bring me my food!", style: .Default, handler: { (action) -> Void in
            print("Checkout Button Pressed")
            
            // Start activity indicator again
            self.myActivityIndicator.hidden = false
            self.myActivityIndicator.startAnimating()
            
            // TO-DO: CHAD! When you get checkout working, this is where you should make the final call!
            // Write code hereeeeee
            
            // Stop activity indicator again
            self.myActivityIndicator.hidden = true
            self.myActivityIndicator.startAnimating()
            
            self.performSegueWithIdentifier("toOrderPlaced", sender: self)
        })
        let cancel = UIAlertAction(title: "No, cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        
        alertController.addAction(checkout)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true, completion: nil)

    }

    @IBAction func xButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "prepareForUnwind" {
            let VC = segue.destinationViewController as! MenuTableViewController
            VC.backToVC = cameFromVC
        } else if segue.identifier == "toDeliverToPayingWith" {
            let VC = segue.destinationViewController as! DeliverToPayingWithTableViewController
            if self.selectedCell == 0 {
                VC.selectedCell = "Deliver To"
            } else if self.selectedCell == 1 {
                VC.selectedCell = "Paying With"
            }
        } else if segue.identifier == "toChangeOrder" {
            let nav = segue.destinationViewController as! UINavigationController
            let VC = nav.topViewController as! AddToOrderViewController
            
            VC.comingFromCheckoutVC = true
            
            // TO-DO: CHAD! Get the item id (or whatever it is) of the selected cell so we can present the AddToOrderVC with all the fields already populated. Let me know what data will be sufficient so that when you pull it form AddToOrderVC, we'll know all about the item (selected sides, special instructions, etc.).
            // Write code hereeeee
            
            
        }
    }

}
