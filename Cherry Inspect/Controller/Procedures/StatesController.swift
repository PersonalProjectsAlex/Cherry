//
//  statesController.swift
//  Cherry Inspect
//
//  Created by Jefferson S. Batista on 7/14/16.
//  Copyright © 2016 Slate Development. All rights reserved.
//

import UIKit

protocol StateDelegate {
    func stateValueBack(_ value: String, field: String)
}

class StatesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    
    var filtered:[String] = []
    var states = [[String]]()

    var data = [""]
    var field:String?
    var delegate: StateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        //    searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "StateView-iOS")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if(searchActive) {
            return 1
        }else if (states.count > 0) {
            return states.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }else if (states.count > 0) {
            switch section {
                case 0: return states[0].count
                case 1: return states[1].count
                case 2: return states[2].count
                default: fatalError()
            }
        }else{
            return data.count
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(searchActive) {
            return 0
        }else if (states.count > 0) {
            return 40
        }else {
            return 0
        }
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 50))
        let lblHeader = UILabel.init(frame: CGRect(x: 15, y: 8, width: tableView.bounds.size.width - 10, height: 24))
        if section == 0 {
            lblHeader.text = "US States"
        }
        else if section == 1 {
            lblHeader.text = "Canadian States"
        }
        else if section == 2 {
            lblHeader.text = "Mexican States"
        }
        else {
            lblHeader.text = ""
        }
        lblHeader.font = UIFont (name: "HelveticaNeue-Medium", size: 18)
        lblHeader.textColor = UIColor.white
        headerView.addSubview(lblHeader)
        headerView.backgroundColor = Constants.CherryDriveSecondaryColor
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell;
        if(searchActive){
            cell.textLabel?.text = filtered[indexPath.row]
        }else if (states.count > 0) {
            switch indexPath.section {
                case 0:
                    cell.textLabel?.text = states[0][indexPath.row]
                case 1:
                    cell.textLabel?.text = states[1][indexPath.row]
                case 2:
                    cell.textLabel?.text = states[2][indexPath.row]
                default:
                    cell.textLabel?.text = ""
            }
        } else {
            cell.textLabel?.text = data[indexPath.row]
        }
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)        
        delegate?.stateValueBack(currentCell!.textLabel!.text!, field: self.field!)
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = data.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
}
