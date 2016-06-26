//
//  PaymentInfoViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/15/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import DLRadioButton
import B68UIFloatLabelTextField
import IQKeyboardManagerSwift
import Stripe

class PaymentInfoViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var creditRadioButton: DLRadioButton!
    @IBOutlet weak var debitRadioButton: DLRadioButton!
    @IBOutlet weak var cardNumberTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var zipTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var CVCTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var expirationDateTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    // Passed data
    var fullName = ""
    var email = ""
    var password = ""
    var phoneNumber = ""
    var campusLocation = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var zip = ""
    
    // Doing this and the two lines in viewDidLoad automatically handles all keyboard and textField problems!
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title
        self.title = "Payment Info"
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.Done
        
        // Hide activity indicator
        myActivityIndicator.stopAnimating()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveAndFinishButtonClicked(sender: UIButton) {
        // Show activity indicator
        myActivityIndicator.startAnimating()
        
        // Create JSON data and configure the request
        let params = ["name": fullName, // from SignUpVC
                      "email": email, // from SignUpVC
                      "phone": phoneNumber, // from SignUpVC
                      "password": password, // from SignUpVC
                      "address": address1, // from AddressInfoVC
                      "apartment": address2, // from AddressInfoVC
                      "city": city, // from AddressInfoVC
                      "state": "NC", // from AddressInfoVC
                      "zip": zip, // from AddressInfoVC
                      "campus_loc": campusLocation] // from AddressInfoVC
            as Dictionary<String, String>
        
        // This is not being saved anywhere: PaymentInfoVC: card_type, card_number, card_zip, card_cvc, card_exp
        
        // create the request & response
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.gobring.it/CHADaddUser.php")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)

        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = jsonData
        } catch let error as NSError {
            print(error)
        }
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
        }
        
        task.resume()
        
        // Update UserDefaults
        self.defaults.setBool(true, forKey: "loggedIn")
        
        // CHAD - PLEASE PUT USER ID INTO A VARIABLE CALLED userID and then uncomment the line below!
        //self.defaults.setObject(userID, forKey: "userID")
        
        // Stop animating activity indicator and enter app
        myActivityIndicator.stopAnimating()
        performSegueWithIdentifier("toHomeFromSignUp", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}