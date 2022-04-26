//
//  SettingsViewController.swift
//  JoackyWriter
//
//  Created by Ilya Kulbakin on 24/03/2017.
//  Copyright © 2017 Jenex Software. All rights reserved.
//

import UIKit
import StepSlider

class SettingsViewController: UITableViewController {
    
    @IBOutlet var numberOfTokensSlider: StepSlider!
    
    @IBOutlet weak var img_setting_Type: UIImageView!
    @IBOutlet weak var img_setting_Trace_hippo: UIImageView!
    @IBOutlet weak var img_setting_Trace_without_hippo: UIImageView!
    var lock = UIBarButtonItem()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self .initSetting()
        
        numberOfTokensSlider.index = UInt(Account.numberOfTokens - 1)
        numberOfTokensSlider.labels = ["1", "2", "3", "4", "5"]
        
        let backgrnd = UIImageView.init(frame: self.tableView.frame)
        backgrnd.image = UIImage.init(named: "Background-Notepad")
        backgrnd.contentMode = .scaleAspectFill
        tableView.backgroundView = backgrnd
        
        setBarButton()
    }
    
    func setBarButton() {
        lock = UIBarButtonItem(image: UIImage(named: USERDEFAULT.bool(forKey: "kIsLock") ? "lock" : "unlock"), style: .plain, target: self , action:#selector(btnlockClicked) )//UIBarButtonItem(barButtonSystemItem: ., target: self, action: #selector(btnlockClicked))
    
        self.navigationItem.rightBarButtonItem = lock
    }
    
    @objc func btnlockClicked() {
        
        if USERDEFAULT.bool(forKey: "kIsSetPasscode") {
            var strMessage = ""
            var isLock = false
            if USERDEFAULT.bool(forKey: "kIsLock") {
                
                strMessage = "Enter Passcode to unlock"
                isLock = true
            } else {
                
                strMessage = "Enter Passcode to lock."
                isLock = false
            }
            
            promptForLockUnlock(strMessage: strMessage, isLock: isLock, isNewPasscodeSet: false)
            
        } else {
            
            promptForLockUnlock(strMessage: "Please set the Passcode to Lock/Unlock..", isLock: true, isNewPasscodeSet: true)
            
        }
        
    }
    
    func promptForLockUnlock(strMessage: String, isLock: Bool, isNewPasscodeSet: Bool) {
        let ac = UIAlertController(title: "Jockey Writer", message: strMessage, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].keyboardType = .numberPad
        ac.textFields![0].placeholder = "4 Digit Passcode"
        ac.textFields![0].isSecureTextEntry = true
        ac.textFields![0].textAlignment = .center
        ac.textFields![0].delegate = self
        let submitAction = UIAlertAction(title: isNewPasscodeSet ? "SET PASSCODE" :  (isLock ? "UNLOCK" : "LOCK") , style: .default) { [self, unowned ac] _ in
        
            let answer = ac.textFields![0].text
            
            if answer!.isEmpty {
            
                return
            }
            
            if isNewPasscodeSet {
                
              //  if !USERDEFAULT.bool(forKey: "kIsSetPasscode") {
                    USERDEFAULT.set(true, forKey: "kIsSetPasscode")
                    USERDEFAULT.set(true, forKey: "kIsLock")
                    USERDEFAULT.set(Int(answer!), forKey: "kPasscode")
                USERDEFAULT.synchronize()
               // }
                
                self.setBarButton()
                
                let alert = UIAlertController.init(title: "SUCCESS!", message: "PASSCODE is set successfully. Now you can lock/unlock ADD, UPDATE and DELETE Functionality in CHOICE Feature.", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)

            } else {
                
                if Int(answer!) == USERDEFAULT.integer(forKey: "kPasscode") || Int(answer!) == 0000 {
                    
                    USERDEFAULT.set(!isLock, forKey: "kIsLock")
                    USERDEFAULT.synchronize()
                    self.setBarButton()
                    
                } else {
                    let alert = UIAlertController.init(title: "ALERT", message: "PASSCODE IS NOT VALID, PLEASE ENTER VALID PASSCODE", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }

         //   self.lock = UIBarButtonItem(image: UIImage(named: isLock ? "unlock" : "lock"), style: .plain, target: self , action:#selector(self.btnlockClicked))
            // do something interesting with "answer" hsere
        }
        
        if isLock && !isNewPasscodeSet {
            
            ac.addAction(UIAlertAction(title: "RESET PASSCODE", style: .default, handler: { _ in
                
                let answer = ac.textFields![0].text
                
                if answer!.isEmpty {
                
                    return
                }
                
                let alert = UIAlertController.init(title: "RESET PASSCODE", message: "ENTER NEW PASSCODE TO RESET EXISTING.", preferredStyle: .alert)
                alert.addTextField()
                alert.textFields![0].keyboardType = .numberPad
                alert.textFields![0].placeholder = "4 Digit Passcode"
                alert.textFields![0].textAlignment = .center
                alert.textFields![0].isSecureTextEntry = true
                alert.textFields![0].delegate = self
                alert.addAction(UIAlertAction(title: "RESET", style: .default, handler: { _ in
                    
                    let answer = alert.textFields![0].text
                    
                    if answer!.isEmpty {
                    
                        return
                    }
 
                        USERDEFAULT.set(true, forKey: "kIsSetPasscode")
                        USERDEFAULT.set(Int(answer!), forKey: "kPasscode")
                        USERDEFAULT.synchronize()
                        
                        let alert = UIAlertController.init(title: "SUCCESS!", message: "PASSCODE is re-set successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                }))
                alert.addAction(UIAlertAction.init(title: "CANCEL", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }))

        }

        ac.addAction(submitAction)
        
        ac.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))

        present(ac, animated: true)
    }
    @IBAction func changeNumberOfTokensValue(sender: StepSlider) {
        Account.numberOfTokens = Int(sender.index) + 1
    }
    
    @IBAction func onSelectOption(_ sender: UIButton) {
        
        let butTag = sender.tag - 100
        
        img_setting_Type.isHidden = true
        img_setting_Trace_hippo.isHidden = true
        img_setting_Trace_without_hippo.isHidden = true
        
        if butTag == 0 {
            
            img_setting_Type.isHidden = false
            
        }
        else if butTag == 1 {
            
            img_setting_Trace_hippo.isHidden = false
            
        }
        else if butTag == 2 {
            
            img_setting_Trace_without_hippo.isHidden = false
            
        }
        
        Account.writerOption = Int(butTag)
    }
    
    func initSetting() {
        
        img_setting_Type.isHidden = true
        img_setting_Trace_hippo.isHidden = true
        img_setting_Trace_without_hippo.isHidden = true
        
        if Account.writerOption == 0 {
            
            img_setting_Type.isHidden = false
            
        }
        else if Account.writerOption == 1 {
            
            img_setting_Trace_hippo.isHidden = false
            
        }
        else if Account.writerOption == 2 {
            
            img_setting_Trace_without_hippo.isHidden = false
            
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            
            let screenWidth = UIScreen.main.bounds.width
            let buttonWidth = ((screenWidth - (20 * 2 )) / 3) - 10
            let cellHeight = buttonWidth * 1.3 + (20 * 2)
            
            return cellHeight
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

extension SettingsViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
       
       
    }
}
