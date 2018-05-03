//
//  MainViewController.swift
//  EASIPRO-Clinic
//
//  Created by Raheel Sayeed on 5/3/18.
//  Copyright © 2018 Boston Children's Hospital. All rights reserved.
//

import UIKit
import EASIPRO
import AssessmentCenter
import SMART

class MainViewController: UITableViewController {
    
    /// Session Controller
    var sessionController : SessionController2?
    
    var measures : [PROMeasure2]? = nil {
        didSet {
            btnBeginSession?.isEnabled = (measures != nil)
            tableView.reloadData()
        }
    }
    
    
    weak var patientHeaderView: PatientSectionHeader?
    
    weak final var btnBeginSession : UIButton?

    
    var patientName : String? {
        get {
            return SMARTManager.shared.patient?.humanName
        }
    }
    
    var status : String = "" {
        didSet { statusLabel?.text = status }
    }
    
    var statusLabel : UILabel?
    
    class func Today()->String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EASIPRO Clinic"
        navigationItem.largeTitleDisplayMode = .automatic
        let nib = UINib(nibName: "PatientSectionHeader", bundle: nil)
        let nibFooter = UINib(nibName: "SessionActionView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "PatientSectionHeader")
        tableView.register(nibFooter, forHeaderFooterViewReuseIdentifier: "SessionActionView")
        tableView.separatorStyle = .singleLine
        setupUI()
        configureCallbacks()



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measures?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let measure = measures![indexPath.row]
        let completed = measure.sessionStatus == .completedCurrent
        let title = measure.title
        let status = completed ? "COMPLETED" : ""
        cell.textLabel?.text = "\(indexPath.row+1): \(title)"
        cell.detailTextLabel?.text = status
        cell.accessoryType = .detailButton
        cell.accessoryView = (measure.sessionStatus == .completedCurrent) ? accessoryView() : nil
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        patientHeaderView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "PatientSectionHeader") as? PatientSectionHeader
        patientHeaderView?.baseViewController = self
        patientHeaderView?.btnMeasures.addTarget(self, action: #selector(selectMeasures(_:)), for: .touchUpInside)
        patientHeaderView?.btnSession.addTarget(self, action: #selector(showPROHistory(_:)), for: .touchUpInside)
        patientHeaderView?.btnPatient.addTarget(self, action: #selector(selectPatient(_:)), for: .touchUpInside)
        patientHeaderView?.btnHistory.addTarget(self, action: #selector(showPROHistory(_:)), for: .touchUpInside)
        return patientHeaderView
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SessionActionView") as! SessionActionView
        cell.btnStart.addTarget(self, action: #selector(beginSession(_:)), for: .touchUpInside)
        btnBeginSession = cell.btnStart
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 220
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (measures != nil) ? 120 : 0
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsMake(0, 100, 0, 100)
        cell.separatorInset = UIEdgeInsetsMake(0, 100, 0, 100)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    
    
    
    func showMsg(msg: String) {
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: "EASIPRO", message: msg, preferredStyle: .alert)
        alertViewController.addAction(alertAction)
        present(alertViewController, animated: true, completion: nil)
    }
    func setupUI() {
        
        let profileBtn = UIBarButtonItem(image: UIImage.init(named: "icons8-male-user-filled-50"), style: .plain, target: self, action: #selector(showProfile))
        let practitionerBtn = UIBarButtonItem(title: "LOGIN", style: .plain, target: self, action: #selector(showProfile))
        navigationItem.rightBarButtonItems = [profileBtn, practitionerBtn]
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: MainViewController.Today(), style: .plain, target: nil, action: nil)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        statusLabel?.text = "Ready"
        statusLabel?.textAlignment = .center
        let labelItem = UIBarButtonItem(customView: statusLabel!)
        let proHistory = UIBarButtonItem.init(title: "PRO-History", style: .plain, target: nil, action: nil)
        toolbarItems = [proHistory, flexibleItem, labelItem, flexibleItem]
        
    }
    
    func configureCallbacks() {
        weak var weakSelf = self
        SMARTManager.shared.onPractitionerSelected = {
            let practitioner = SMARTManager.shared.practitioner?.name?.first?.human ?? " ---> "
            let practitionerBarItem = weakSelf?.navigationItem.rightBarButtonItems![1]
            practitionerBarItem?.title = practitioner
        }
        SMARTManager.shared.onPatientSelected = {
            weakSelf?.patientHeaderView?.setPatient(patient: SMARTManager.shared.patient)
        }
    }
    func accessoryView() -> UIButton {
        
        let btn = UIButton(type: .roundedRect)
        let img = UIImage.init(named: "icons8-ok-50")
        let imgView = UIImageView(image: img)
        imgView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn.setBackgroundImage(img, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        btn.contentMode = .center
        return btn
    }
    
    @objc public func selectMeasures(_ sender: UIButton) {
//        let measuresViewController = ACMeasuresViewController()
//        measuresViewController.onSelection = { (measures) in
//            self.measures = measures
//        }
//        present(popUpNavigationController(root: measuresViewController, frame: sender.frame), animated: true, completion: nil)
    }
    
    @objc func showPROHistory(_ sender: Any) {
        let insights = InsightsController(style: .grouped)
        insights.view.backgroundColor = view.backgroundColor
        let navigationController = UINavigationController(rootViewController: insights)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func selectPatient(_ sender: Any) {
        SMARTManager.shared.selectPatient { [weak self] (viewController) in
            self?.present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc func showProfile() {
        SMARTManager.shared.client.ready { [unowned self] (error) in
            DispatchQueue.main.async {
                SMARTManager.shared.showLoginController(over: self)
            }
        }
    }
    
    
    
    
    // MARK: AC Session Management
    
    @objc public func beginSession(_ sender: Any?) {
        
        guard let pt = SMARTManager.shared.patient, let measures = measures, let practitioner = SMARTManager.shared.practitioner else {
            showMsg(msg: "Please login and select Patient Profile")
            return
        }
        
        let btn : RoundedButton? = sender as? RoundedButton ?? nil
        btn?.busy()
        sessionController = SessionController2(patient:pt, measures: measures, practitioner: practitioner)
        
        
        
        // Report back to the UI that the session is Complete.
        sessionController?.onSessionCompletion = { [weak self] result, measures in
            self?.status = "Session Completed for \(self?.patientName ?? "---")"
        }
        
        sessionController?.onMeasureCompletion = { [weak self] result, measure in
            
            let filtered = self?.measures?.filter { $0 == measure }.first
            if let idx = filtered {
                idx.sessionStatus = .completedCurrent
                self?.status = "Session Completed for \(self?.patientName ?? "---")"
            }
            btn?.reset()
            self?.tableView.reloadData()
        }
        
        sessionController?.prepareSessionContainer { [weak self] (viewController, error) in
            
            guard let viewController = viewController else {
                self?.showMsg(msg: "Error Creating a Session Controller")
                btn?.reset()
                return
            }
            
            viewController.view.tintColor = UIColor.red
            self?.present(viewController, animated: true, completion: nil)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
     override func tableView(_ tab    var status : String = "" {
     didSet { statusLabel?.text = status }
     }
     
     var statusLabel : UILabel?leView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
