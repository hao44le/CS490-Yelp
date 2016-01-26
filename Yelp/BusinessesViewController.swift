//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MJRefresh

class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    var searchBar = UISearchBar()
    var searchBarButtonItem: UIBarButtonItem?
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var mapButton: UIBarButtonItem!
    @IBAction func searchCliked(sender: UIBarButtonItem) {
        searchBar.alpha = 0
        navigationItem.titleView = searchBar
        navigationItem.setLeftBarButtonItem(nil, animated: true)
        navigationItem.setRightBarButtonItem(nil, animated: true)
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })

    }
    
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.filteredBusiness = []
        self.tableView.reloadData()
        navigationItem.titleView = nil
        navigationItem.title = "Yelp"
        navigationItem.setLeftBarButtonItem(mapButton, animated: true)
        navigationItem.setRightBarButtonItem(searchButton, animated: true)
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 0
            }, completion: { finished in
                self.searchBar.resignFirstResponder()
        })
    }
    
    @IBAction func mapClicked() {
        //go to map
        print("map")
    }
    @IBOutlet weak var tableView: UITableView!
    var businesses: NSMutableArray = []
    var pageNum = 0
    var isHeaderRefresh = false
    var filteredBusiness  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        self.setupTableRefresh()
        
        self.refreshData()
        
    }
    func configureView(){
        let textFiled = searchBar.valueForKey("searchField") as? UITextField
        textFiled?.textColor = UIColor.whiteColor()
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBarButtonItem = navigationItem.rightBarButtonItem
        mapButton = UIBarButtonItem(title: "Map", style: UIBarButtonItemStyle.Plain, target: self, action: "mapClicked")
        navigationItem.setLeftBarButtonItem(mapButton, animated: true)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
    }
    func setupTableRefresh(){
        let header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.isHeaderRefresh = true
            self.pageNum = 0
            self.refreshData()
        })
        header.setTitle("Pull down to refresh", forState: MJRefreshState.Idle)
        header.setTitle("Release to refresh", forState: MJRefreshState.Pulling)
        header.setTitle("Loading ...", forState: MJRefreshState.Refreshing)
        header.stateLabel?.textColor = UIColor.blackColor()
        header.lastUpdatedTimeLabel?.hidden = true
        self.tableView.mj_header = header
        self.tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: { () -> Void in
            self.pageNum += 1
            self.refreshData()
        })
    }
    
    func refreshData(){
        Tool.showProgressHUD("Loading Business")
        Business.searchWithTerm(pageNum * 20,term:"Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            Tool.dismissHUD()
            if self.tableView.mj_header.isRefreshing(){
                self.tableView.mj_header.endRefreshing()
            }
            if self.tableView.mj_footer.isRefreshing(){
                self.tableView.mj_footer.endRefreshing()
            }
            if self.isHeaderRefresh{
                self.isHeaderRefresh = false
            }
            if nil != businesses{
                self.businesses.addObjectsFromArray(businesses)
                
                self.tableView.reloadData()
            }else{
                Tool.showErrorHUD("Network Error")
            }
            //            for business in businesses {
            //                print(business.name!)
            //                print(business.address!)
            //            }
        })
        /* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        
        for business in businesses {
        print(business.name!)
        print(business.address!)
        }
        }
        */
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBusiness.count != 0 {
            return filteredBusiness.count
        } else {
            return businesses.count
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! BusinessCell
        if filteredBusiness.count != 0 {
            cell.business = filteredBusiness[indexPath.row] as! Business
        } else {
            cell.business = businesses[indexPath.row] as! Business
        }
        
        return cell
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredBusiness = businesses
        } else {
            let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            let filteredArray = businesses.filteredArrayUsingPredicate(searchPredicate)
            if filteredArray.count != 0 {
                filteredBusiness = filteredArray
            }
        }
        tableView.reloadData()
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toPopup"{
            let popupSegue = segue as! CCMPopupSegue
            
            
            if (self.view.bounds.size.height < 420) {
                
                popupSegue.destinationBounds = CGRectMake(0, 0, 300, 400)
                //6 plus
            } else if (self.view.bounds.size.height == 736) {
                popupSegue.destinationBounds = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.height-200) * 0.6, UIScreen.mainScreen().bounds.size.height-260)
                // 6
            } else if (self.view.bounds.size.height == 667) {
                popupSegue.destinationBounds = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.height-150) * 0.65, UIScreen.mainScreen().bounds.size.height-200)
                // 5s / 5
            } else if (self.view.bounds.size.height == 568) {
                popupSegue.destinationBounds = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.height-150) * 0.7, UIScreen.mainScreen().bounds.size.height-200)
                // 4s
            } else if (self.view.bounds.size.height == 480) {
                popupSegue.destinationBounds = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.height-100) * 0.76, UIScreen.mainScreen().bounds.size.height-150)
                // ipad
            } else {
                popupSegue.destinationBounds = CGRectMake(0, 0, (UIScreen.mainScreen().bounds.size.height-100) * 0.7, UIScreen.mainScreen().bounds.size.height-150)
            }
            popupSegue.backgroundBlurRadius = 7
            popupSegue.backgroundViewAlpha = 0.3
            popupSegue.backgroundViewColor = UIColor.blackColor()
            popupSegue.dismissableByTouchingBackground = true
            
        }
        
    }
    
    
    
}
