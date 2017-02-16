//
//  FamilyMemberListViewController.swift
//  Stetho
//
//  Created by Administrator on 15/02/17.
//  Copyright © 2017 Hindustan Wellness. All rights reserved.
//

import UIKit

class FamilyMemberListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {

    @IBOutlet var familyTableView: UITableView!
    
    var searchBar : UISearchBar!
    var myFamilyList = [MyFamilyInfo]()
    var tempDataFamily = [MyFamilyInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        familyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FamilyMemberListViewController")
        

        familyTableView.register(FamilyHeaderCell.self, forCellReuseIdentifier: "FamilyHeaderCell")
//        self.modalPresentationStyle = .overCurrentContext

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        getMyFamilyList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
//    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 96
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            return tempDataFamily.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 90))
        headerView.backgroundColor = UIColor.white
        let lblSelectMember = BaseUIController().ALabelFrame(CGRect(x: 10 ,y:0 ,width: tableView.frame.width - 10 , height: 49), withString: "Select Member") as! UILabel
        lblSelectMember.font = UIFont(name: KROBOTO_LIGHT, size: 19.0)
        lblSelectMember.textColor = UIColor.black
        
        let seperatorLine = BaseUIController().ALabelFrame(CGRect(x: 0 ,y:49 ,width: tableView.frame.width , height: 1), withString: "") as! UILabel
        seperatorLine.backgroundColor = UIColor.black
        seperatorLine.textColor = UIColor.clear
        headerView.addSubview(lblSelectMember)
        headerView.addSubview(seperatorLine)
        
        let cancelButton = UIButton(frame: CGRect(x: headerView.frame.size.width - 40, y: 10, width: 30, height: 30))
        cancelButton.setImage(#imageLiteral(resourceName: "verified_no.png"), for: .normal)
        cancelButton.addTarget(self, action: #selector(HomeViewController.cancelButtonClicked(_:)), for: .touchUpInside)
        headerView.addSubview(cancelButton)
        
        configureSearchBar()
        searchBar.frame = CGRect(x: headerView.frame.origin.x, y: seperatorLine.frame.origin.y + seperatorLine.frame.size.height, width: headerView.frame.size.width, height: 40)
        headerView.addSubview(searchBar)
        return headerView
    }
    
    func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.isSearchResultsButtonSelected = true
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.clearButtonMode = .never
        searchBar.delegate = self
        searchBar.placeholder = "Name"
    }
//    {
//        let familyHeaderCell = tableView.dequeueReusableCell(withIdentifier: "FamilyHeaderCell") as! FamilyHeaderCell
//        
//        familyHeaderCell.cancelButton.addTarget(self, action: #selector(FamilyMemberListViewController.cancelButtonClicked(_:)), for: .touchUpInside)
//       // familyHeaderCell.searchBar.delegate = self
//        return familyHeaderCell
//    }
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let familyMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FamilyMemberTableViewCell", for: indexPath) as! FamilyMemberTableViewCell
        
        let familyMemberInfo = tempDataFamily[indexPath.row]

        familyMemberTableViewCell.lblMemberName.text = familyMemberInfo.memberName
        
        let imageString = familyMemberInfo.memberPhoto
        
        if imageString != "" {
            let data = Data(base64Encoded: familyMemberInfo.memberPhoto, options: NSData.Base64DecodingOptions(rawValue: 0))
            familyMemberTableViewCell.imgMember.layer.masksToBounds = true
            familyMemberTableViewCell.imgMember.layer.cornerRadius = familyMemberTableViewCell.imgMember.frame.size.width/2
            familyMemberTableViewCell.imgMember.image = UIImage.init(data: data!)
            
        }else{
            familyMemberTableViewCell.imgMember.image = UIImage(named: "avatar1.png")
        }
        
        return familyMemberTableViewCell
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if tableView == memberListTableView {
//            bgView.removeFromSuperview()
//            //set activity on view
//            activityIndicator = ProgressViewController(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: "")
//            activityIndicator?.frame = CGRect(x: tableView.frame.width/2 - 30, y: 100, width: 60, height: 60)
//            tblView.addSubview(activityIndicator!)
//            activityIndicator?.start()
//            myFamilyMemberObj = tempDataFamily[(indexPath as NSIndexPath).row]as! MyFamilyInfo
//            //            myFamilyMemberObj = arrMyFamilyList[(indexPath as NSIndexPath).row]as! MyFamilyInfo
//            self.getAllTestsByFamily(myFamilyMemberObj.memberId)
//        }
//    }
//

//    
//
//    
    func cancelButtonClicked(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
//        bgView.removeFromSuperview()
    }
//
//    func configureSearchBar() {
//        searchBar = UISearchBar()
//        searchBar.showsCancelButton = false
//        searchBar.isSearchResultsButtonSelected = true
//        let textField = searchBar.value(forKey: "searchField") as! UITextField
//        textField.clearButtonMode = .never
//        searchBar.delegate = self
//        searchBar.placeholder = "Name"
//    }
//    
    //MARK: Search Bar Delegates
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        var completeString = ""
        if text == "\n" {
            searchBar.resignFirstResponder()
            return true
        }
        if text.isEmpty ==  false{
            completeString = searchBar.text! + text
        }else{
            completeString = searchBar.text!
            if completeString.characters.count > 0 {
                completeString = String(completeString.characters.dropLast(1))
                if completeString.isEmpty == true{
                    tempDataFamily = myFamilyList
                    familyTableView.reloadData()
                    return true
                }
            }else{
                tempDataFamily = myFamilyList
                familyTableView.reloadData()
                return true
            }
        }        
        let filteredArray = myFamilyList.filter( { (memberInfo: MyFamilyInfo) -> Bool in
            return memberInfo.memberName.contains(completeString) //memberInfo.memberName == completeString
        })
        tempDataFamily = filteredArray
        familyTableView.reloadData()
        return true
        
//        myFamilyList.fil
//        tempDataFamily = (arrMyFamilyList.filtered(using: searchPredicate) as? NSMutableArray)!
//        print(tempDataFamily)
//        memberListTableView.reloadData()
//        return true
    }

//MARK: Custom Methods

    func getMyFamilyList()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let database = appDelegate.openDataBase()
        
        // arrMyFamilyList = NSMutableArray()
        do {
            let rs = try database.executeQuery("select * from MyFamily", values: nil)
            while rs.next() {
                let familyMemberObj = MyFamilyInfo()
                familyMemberObj.memberId = rs.string(forColumn: "MemberId")
                familyMemberObj.memberName = rs.string(forColumn: "MemberName")
                familyMemberObj.memberRelation = rs.string(forColumn: "Relation")
                familyMemberObj.memberPhoto = rs.string(forColumn: "MemberPhoto")
                familyMemberObj.memberDOB = rs.string(forColumn: "MemberDOB")
                familyMemberObj.memberEmail = rs.string(forColumn: "MemberEmail")
                familyMemberObj.memberGender = rs.string(forColumn: "MemberGender")
                familyMemberObj.memberMobileNo = rs.string(forColumn: "MemberMobileNo")
                familyMemberObj.memberVerefyStatus = rs.string(forColumn: "Verified")
                familyMemberObj.memberActiveStatus = rs.string(forColumn: "Active")
                //            arrMyFamilyList.add(familyMemberObj)
                myFamilyList.append(familyMemberObj)
            }
            tempDataFamily = myFamilyList
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        familyTableView.reloadData()
        database.close()
        //return myFamilyList
    }

}
