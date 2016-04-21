//
//  talkController.swift
//  twitter
//
//  Created by McTavish Wang on 16/3/2.
//  Copyright © 2016年 McTavish Wang. All rights reserved.
//

import UIKit

class talkController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, returnValueDelegate {

    @IBOutlet weak var curText: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var name: UIButton!
    var names=[String]()
    var chosenName=""
    
    var predictions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tv.delegate = self;
        self.tv.dataSource = self;
        // send a request to the server for options
        
        name.layer.masksToBounds = true
        name.layer.cornerRadius = 10
        
        getPrediction("")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //returns the number of rows in a section
        
        return predictions.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //      tableView.deselectRowAtIndexPath(indexPath, animated: true) //tv?
        
        self.tv.deselectRowAtIndexPath(indexPath, animated: true)
        
        if predictions[indexPath.row]=="" {
            return
        }
        
        //append the text to the current prediction
        if let cur = curText.text{
            if cur=="__" {
                curText.text = predictions[indexPath.row]
            }
            else{curText.text = cur+" "+predictions[indexPath.row]}
        }
        
        //send the current selection to the server and wait for new set of predictions
        getPrediction(predictions[indexPath.row])
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // returns the actual cell
        print("reload")
        
        var cell = UITableViewCell()
        
        cell.textLabel!.text = predictions[indexPath.row]
        
        return cell
    }

    //buttons
    @IBAction func comma(sender: UIButton) {
        if let txt=self.curText.text{
            curText.text = txt+", "
        }
    }

    @IBAction func period(sender: UIButton) {
        if let txt=self.curText.text{
            curText.text = txt+". "
        }
    }
    
    @IBAction func deleteWord(sender: UIButton) {
        if let txt=self.curText.text{
            if let index2 = txt.rangeOfString(" ", options: .BackwardsSearch)?.startIndex{
                self.curText.text = txt.substringToIndex(index2)
            }else{
                self.curText.text = "__"
            }
        }
    }
    
    @IBAction func quit(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    func getPrediction(sel: String){
        let request = NSMutableURLRequest(URL:NSURL(string: "http://swang146.web.engr.illinois.edu")!);
        request.HTTPMethod = "POST";
        // Compose a query string
        let postString = "selection="+sel;
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            //print("response = \(response)")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            
            //Let’s convert response sent from a server side script to a NSDictionary object:
            var myJSON = [String]()
            
            do{
                myJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! [String]
            }catch{
                
            }
            
            // Now we can access value of First Name by its key
            self.predictions = myJSON
            print("start reload")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tv.reloadData()
            })
        }
        task.resume()
    }

    @IBAction func choosename(sender: UIButton) {
        let  namefrm: CGRect = self.name.frame
        let x = namefrm.origin.x + namefrm.width/2
        let y = namefrm.origin.y + namefrm.height/2
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController: nameController = storyboard.instantiateViewControllerWithIdentifier("nameController") as! nameController
        menuViewController.modalPresentationStyle = .Popover
        menuViewController.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width*0.2, UIScreen.mainScreen().bounds.height*0.2)
        let popoverMenuViewController = menuViewController.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Any
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = self.view
        popoverMenuViewController?.sourceRect = CGRectMake(x, y,0,0)
        popoverMenuViewController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 1)
        menuViewController.delegate = self
        menuViewController.names=self.names
        presentViewController(menuViewController, animated: true, completion: nil)
        
    }
    
    func selectPropertyIndex(idx: Int){
        chosenName=names[idx]
        self.name.setTitle(chosenName, forState: UIControlState.Normal)
    }
}

protocol returnValueDelegate {
    func selectPropertyIndex(idx: Int)
}
