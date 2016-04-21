//
//  MainViewController.swift
//  twitter
//
//  Created by McTavish Wang on 15/10/4.
//  Copyright (c) 2015年 McTavish Wang. All rights reserved.
//


import UIKit
import CoreLocation // for location, request in plist as well
import AVFoundation

class MainViewController: UITableViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var tv: UITableView!
    
    let locationManager = CLLocationManager()
    var city = ""
    var longi:CLLocationDegrees = 0.0
    var lati:CLLocationDegrees = 0.0
    var rc: UIRefreshControl!

    var url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music", ofType:"mp3")!)
    
    var music = AVAudioPlayer()
    var imagePicker: UIImagePickerController!
    var image:UIImage!
    
    var familyMembers = [String:String]()
    var userInfo:[String:String] = [String:String]()
    var ref = Firebase(url: "https://testrealtime.firebaseio.com/")
    var uid = ""
    var family = ""
    
    class familyMember {
        var longi:CLLocationDegrees = 0.0
        var lati:CLLocationDegrees = 0.0
        var role=""
        var name=""
        init(newLongi: Double, newLati: Double, newRole: String, newName: String){
            longi = newLongi
            lati = newLati
            role = newRole
            name = newName
        }
    }
    
    var members = [familyMember]()
    var names = [String]()
    var imageString = [String]()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //returns the number of rows in a section
        
        //return post.count
        return userInfo.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // returns the actual cell

        
//        print("get cell \(Int(indexPath.row))")
        if(Int(indexPath.row) == 0)
        {
            var cell = UITableViewCell()
            cell.textLabel?.text = "Current Location: \(city) longi \(longi) lati \(lati)"
            return cell
        }
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell")! as! CustomTableViewCell
       
        var row = indexPath.row-1
        
        var imageData = NSData(base64EncodedString: imageString[row], options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        var memberLongi:CLLocationDegrees = members[row].longi
        var memberLati:CLLocationDegrees = members[row].lati
        var memberRole = members[row].role
        var memberName = members[row].name
        let from = CLLocation(latitude: memberLati, longitude: memberLongi)
        let to = CLLocation(latitude: lati, longitude: longi)
        var dist = from.distanceFromLocation(to)
        
        var nearby = ""
        
//        print("cur lati:\(lati) longi:\(longi)")
        
        
        if dist > 20.0{
            nearby = "far away!"
            cell.status.backgroundColor = UIColor.redColor()
            }
        else{
            nearby = "nearby!"
            cell.status.backgroundColor = UIColor.greenColor()
            
            let alert: UIAlertController = UIAlertController(title: "Caretaker Nearby!", message: "say something?", preferredStyle: .Alert)
            let okButton = UIAlertAction(title: "Sure", style: .Default){ action in self.music.play() }
            let noButton = UIAlertAction(title: "No", style: .Default){ action in  }
            
            alert.addAction(okButton)
            alert.addAction(noButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
//        print("\(memberName) dist: \(dist) \(nearby)")
        
        if let pic = imageData{
            cell.customImage.image = UIImage(data: pic)
        }
        
        cell.role.text = "\(memberRole): \(memberName)  \(nearby)"
        cell.customText.text = "lati:\(memberLati) longi:\(memberLongi) "
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //加载CustomTableViewCell
        self.tableView.registerNib(UINib(nibName:"CustomTableViewCell", bundle:nil), forCellReuseIdentifier:"CustomTableViewCell")
        
        do{
         music = try AVAudioPlayer(contentsOfURL: url, fileTypeHint: AVFileTypeMPEG4)
        }catch let error as NSError{
             UIAlertView(title: "Error", message: "Could not create audio player: \(error)", delegate: nil, cancelButtonTitle: "OK").show()
        }
        
        rc = UIRefreshControl()
        rc.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        rc.attributedTitle = NSAttributedString(string: "release to refresh")
        tv.addSubview(rc)
        
        
        //init the location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        //start getting the location
        self.locationManager.startUpdatingLocation()
        print("start updating location")
        
        uid = ref.authData.uid
        
        // load data
        readData()
        
        ref.observeEventType(.ChildChanged, withBlock: { snapshot in
            
            // if there's a change in value, read the value in users
            self.refreshData()
            
        })
        
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        ref.unauth()
        self.performSegueWithIdentifier("logoutSegue", sender: self)
        
    }
    
    
    // location
    // called after initialization
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        /*CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if placemarks == nil{return}
            
            print("got location")
            
            if error != nil{
                print("Error: \(error!.localizedDescription) ")
                return
            }
            
            if placemarks!.count>0{
                let pm = placemarks![0] //as! CLPlacemark
                self.displayLocationInfo(pm)
                print("reloading")
            }
            
        })*/
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.count>0){
            if(ref.authData != nil){
                longi = locations[locations.endIndex-1].coordinate.longitude
                lati = locations[locations.endIndex-1].coordinate.latitude
                let newLocatoin = ["CurrentLongitude": "\(longi)",
                                    "CurrentLatitude": "\(lati)"]
/*                print("update uid: \(ref.authData.uid)")
                print("longi: \(longi) lati: \(lati)")
*/
                self.ref.childByAppendingPath("users").childByAppendingPath(ref.authData.uid).updateChildValues(newLocatoin)
                self.tableView.reloadData()
                
            }
            
        }
    }
    
    func refreshData(){
        
        readData()
        
        self.tableView.reloadData()
        self.rc.endRefreshing()
    }
    
    func readData(){
        // load data
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            // get user's family to find the IDs of the family member
            self.family = snapshot.childSnapshotForPath("users/\(self.uid)/Family").value as! String

            // go to the family and get the usernames of the family members
            self.userInfo = snapshot.childSnapshotForPath("Families/\(self.family)").value as! [String:String]
            
            self.members = [familyMember]()
            self.names = [String]()
            self.imageString = [String]()
            // now have the members, go get their locations
            for (AutoID,userID) in self.userInfo{

                if userID == self.uid{continue}
                var memberLongi = (snapshot.childSnapshotForPath("users/\(userID)/CurrentLongitude").value as! NSString).doubleValue
                var memberLati = (snapshot.childSnapshotForPath("users/\(userID)/CurrentLatitude").value as! NSString).doubleValue
                var memberRole = snapshot.childSnapshotForPath("users/\(userID)/Role").value as! String
                var memberName = (snapshot.childSnapshotForPath("users/\(userID)/FirstName").value as! String) + " " +
                    (snapshot.childSnapshotForPath("users/\(userID)/LastName").value as! String)
                var memberPic = snapshot.childSnapshotForPath("Images/\(userID)").value as! String
                
                var newMember = familyMember(newLongi: memberLongi, newLati: memberLati, newRole: memberRole, newName: memberName)
                self.names.append(memberName)
                self.members.append(newMember)
                self.imageString.append(memberPic)
            }
            
            self.tableView.reloadData()
        })
        
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark)
    {
        city = placemark.locality!
        longi = locationManager.location!.coordinate.longitude
        lati = locationManager.location!.coordinate.latitude
        
        self.locationManager.stopUpdatingLocation()
        print(city)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)

        if(ref.authData != nil){
            let newLocatoin = ["CurrentLongitude": "\(longi)",
                "CurrentLatitude": "\(lati)"]
            print("display uid: \(ref.authData.uid)")
            print("longi: \(longi) lati: \(lati)")
            
            self.ref.childByAppendingPath("users").childByAppendingPath(ref.authData.uid).updateChildValues(newLocatoin)
        }
    
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .SavedPhotosAlbum
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        var imageData = UIImageJPEGRepresentation(image, 0.9)! as NSData
        var imageString = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) as NSString
        
        ref.childByAppendingPath("Images/\(self.uid)").setValue(imageString)
    }
 
    @IBAction func talk(sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController: talkController = storyboard.instantiateViewControllerWithIdentifier("talkController") as! talkController
        menuViewController.modalPresentationStyle = .Popover
        menuViewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width*0.8, UIScreen.mainScreen().bounds.height*0.8)
        let popoverMenuViewController = menuViewController.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Any
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = self.view
        popoverMenuViewController?.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds),0,0)
        popoverMenuViewController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        menuViewController.names=self.names
        presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func sendPostRequest(sender: AnyObject) {
    
        let request = NSMutableURLRequest(URL:NSURL(string: "http://swang146.web.engr.illinois.edu")!);
        request.HTTPMethod = "POST";
        // Compose a query string
        let postString = "firstName=James&lastName=Bond";
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            //Let’s convert response sent from a server side script to a NSDictionary object:
            var myJSON = ["":""]

            do{
                myJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! [String:String]
            }catch{
            
            }
 
                // Now we can access value of First Name by its key
            let firstNameValue = myJSON["firstName"]
                print("firstNameValue: \(firstNameValue)")


        }
        task.resume()
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        }
        return 181
    }
    
}






