//
//  AddChoiceVC.swift
//  SQLitedemo
//
//  Created by Vinay Patel on 29/07/2021.
//

import UIKit
import AVKit
import Vision
import WatchConnectivity

class AddChoiceVC: UIViewController {

    
    @IBOutlet weak var vwImageBg: UIView!
    @IBOutlet weak var vwBgImg: UIImageView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var tfCaption: UITextField!
    @IBOutlet weak var tfMoreWords: UITextField!
    @IBOutlet weak var tfWorkType: UITextField!
    @IBOutlet weak var btnAddMoreWords : UIButton!
    @IBOutlet weak var lblCaption: UILabel!
    
    private let audioManager: SCAudioManager!
    private let imageDrawer: WaveformImageDrawer!
    @IBOutlet weak var waveformView: WaveformLiveView!
    var imgURL: URL?
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnDeleteRecord: UIButton!
    
    
    @IBOutlet weak var btnAddToiWatch: UIButton!
    @IBOutlet weak var btnAddToBoth: UIButton!
    
//    var isForiWatch: Bool = false
//    var isForBoth: Bool = false

    var isSaved = false
    var audioURL : URL?
    
    var isImageHasText: Int = 0
    

    var strSelectedTable: String?
    
    var selectedChoice : Choices?
    
    required init?(coder: NSCoder) {
        audioManager = SCAudioManager()
        
        imageDrawer = WaveformImageDrawer()
        super.init(coder: coder)

        audioManager.recordingDelegate = self
    }
    
    var callBack : (()->())?
    var selectedParentID : Int = 0
    var isCategory: Bool = false
    var vwbgColor: UIColor = .lightGray {
        
        didSet {
            if isCategory {
                vwBgImg.tintColor = vwbgColor
                
            } else {
                vwImageBg.backgroundColor = vwbgColor
            }
        }
        
    }
    
    var strCaption: String = ""{
        didSet {
            
            lblCaption.text = strCaption
        }
    }
    
    var strWordType: String = "Others" {
        
        didSet {
            
            tfWorkType.text = strWordType
        }
        
    }
    
    var session: WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfCaption.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        
        if selectedChoice != nil {
            
            tfCaption.text = selectedChoice?.caption
            lblCaption.text = selectedChoice?.caption
            tfMoreWords.text = isCategory ? selectedChoice?.sWord : selectedChoice?.moreWords
            tfWorkType.text = selectedChoice?.wordType.rawValue
            isCategory = selectedChoice!.isCategory
            strWordType = (selectedChoice?.wordType)!.rawValue
            vwbgColor = UIColor(selectedChoice!.color)
            if selectedChoice?.recordingPath != "" {
                audioURL = URL(string: selectedChoice!.recordingPath!)
            }
            if isCategory {
                vwBgImg.isHidden = false
                vwImageBg.backgroundColor = .clear
                vwBgImg.tintColor = UIColor(selectedChoice!.color)
                tfMoreWords.placeholder = "Suggestion Words"
                vwBgImg.image = #imageLiteral(resourceName: "folder")
            } else {
                vwImageBg.backgroundColor = UIColor(selectedChoice!.color)
            }
            
            if selectedChoice?.imgPath != "" {
                imgVw.image = APPDELEGATE.loadImageFromDocumentDirectory(nameOfImage: selectedChoice!.imgPath!)
            }
        } else {
            if isCategory {
                
                vwBgImg.isHidden = false
                vwImageBg.backgroundColor = .clear
                tfCaption.placeholder = "Enter Category"
                tfMoreWords.placeholder = "Suggestion Words"
                vwBgImg.image = #imageLiteral(resourceName: "folder")
                vwBgImg.tintColor = .lightGray
            }
        }
        
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }

       

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        waveformView.configuration = waveformView.configuration.with(
            style: .striped(.init(color: .red, width: 3, spacing: 3))
        )
        audioManager.prepareAudioRecording()
    }
    
    @objc func textFieldDidChange(textField:UITextField)
    {
        strCaption = textField.text!
        NSLog(textField.text!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}

//MARK:- UIButton Actions

extension AddChoiceVC {
    
    @IBAction func btnAddToiWatch(_ sender: Any) {
        
        if btnAddToBoth.isSelected {
            btnAddToBoth.isSelected = false
        }
        btnAddToiWatch.isSelected = true
    }
    
    @IBAction func btnAddToBoth(_ sender: Any) {
        if btnAddToiWatch.isSelected {
            btnAddToiWatch.isSelected = false
        }
        btnAddToBoth.isSelected = true
    }
    
    
    @IBAction func btnDeleteRecording(_ sender: Any) {
        
        if audioURL != nil {
            APPDELEGATE.deleteFile(fileNameToDelete: "recordings/\(audioURL!.lastPathComponent)")
        }
    }
    @IBAction func btnPlayRecoding(_ sender: Any) {
        
        if audioURL != nil {
            
            audioManager.playAudioFile(from: audioURL)
//            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
//            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
//            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
//            if let dirPath = paths.first{
//                let audioURL1 = URL(fileURLWithPath: dirPath).appendingPathComponent("recordings/\(audioURL!.lastPathComponent)")
//
//                audioManager.playAudioFile(from: audioURL)
//            }
        }
    }
    @IBAction func btnRecording(_ sender: Any) {
        
        if audioURL != nil {
            
            APPDELEGATE.deleteFile(fileNameToDelete: "recordings/\(audioURL!.lastPathComponent)")
        }
        
        
        if audioManager.recording() {
            audioManager.stopRecording()
            btnRecord.tintColor = .red//setTitle("Start Recording", for: .normal)
        } else {
            waveformView.reset()
            audioManager.startRecording()
            btnRecord.tintColor = .black//setTitle("Stop Recording", for: .normal)
        }
    }
    
    @IBAction func btnClearImagePressed(_ sender: Any) {
        
        imgVw.image = nil
        if isCategory {
                
            vwBgImg.tintColor = .lightGray
            return
        }
        vwImageBg.backgroundColor = .lightGray
    }
    
    @IBAction func btnCameraPressed(_ sender : UIButton) {
        
        CameraHandler.shared.showActionSheet(vc: self, btn: sender)
        CameraHandler.shared.imagePickedBlock = { [weak self] (image, url) in
            
            self!.isImageHasText = 0
            self?.imgVw.image = image
            self!.imgURL = url
            
            guard let cgImage = image.cgImage else {return}
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            
            let request = VNRecognizeTextRequest(completionHandler: self?.recognizeTextHandler(reqeust:error:))
            
            do {
                try requestHandler.perform([request])
            } catch {
                
                debugPrint("Unable to perform the requests: \(error.localizedDescription)")
            }
            /* get your image here */
        }
        
    }
    
    private func recognizeTextHandler(reqeust: VNRequest, error: Error?) {
        guard let observations = reqeust.results as? [VNRecognizedTextObservation] else {return}
        
        let recognizedStrings = observations.compactMap { observation in
            
            
            return observation.topCandidates(1).first?.string
            
            
        }
        isImageHasText = 1
        self.tfCaption.text = recognizedStrings.first
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if !isSaved && audioURL != nil{
            APPDELEGATE.deleteFile(fileNameToDelete: "recordings/\(audioURL!.lastPathComponent)")
        }
    }
    
    @IBAction func btnSavePressed(_ sender: Any) {
        
        let imgData = imgVw.image?.jpegData(compressionQuality: 1)
        
        let Size = Float(Double(imgData!.count)/1024)
        
        var tempImg = imgVw.image
        
        if imgVw.image!.size.width > 200.0 && Size >= 60.0 {
            
            if let compressed = imgVw.image!.resized(toWidth: 400.0) {
               tempImg = compressed
            }
        }
        
//        do {
//            try session.updateApplicationContext(["imgData": tempImg?.jpegData(compressionQuality: 1.0)! as Any])
//        } catch let err {
//            debugPrint("Error ----- \(err.localizedDescription)")
//        }
        
        
        
        
        session.sendMessage(["a": tfCaption.text!], replyHandler: nil) { error in
            debugPrint("Error getting while sending Message from iPhone to iWatch -- \(error.localizedDescription)")
        }
        
        
        
        
        session.sendMessageData((tempImg?.jpegData(compressionQuality: 1))!, replyHandler: nil) { erro in

            debugPrint("Error ---- \(erro.localizedDescription)")
        }
        
       // session.transferFile(imgURL!, metadata: nil)
       // return
        
        let db:DBHelper = DBHelper.shared
        
        var imagePath = ""
        if let image = imgVw.image {
            
            if selectedChoice?.imgPath != "" {
                
                imagePath = APPDELEGATE.saveImageToDocumentDirectory(image: image, fileName: selectedChoice != nil ? "\(selectedChoice?.imgPath ?? "")" : "\(Date().timeIntervalSince1970).png")
                
            } else {
                
                imagePath =  APPDELEGATE.saveImageToDocumentDirectory(image: image, fileName: "\(Date().timeIntervalSince1970).png")
            }
        }
        
        if selectedChoice != nil {
            
            if db.updateById(id: selectedChoice!.id, parentId: selectedParentID, caption: tfCaption.text!, showInMessageBox: false, imgPath: imagePath, recordingPath: audioURL != nil ? audioURL!.absoluteString : "", wordType: strWordType, color: vwbgColor.hexString(), moreWords: isCategory ? "" : tfMoreWords.text!, isCategory: isCategory, sWord: isCategory ? tfMoreWords.text!.lowercased() : "", isImageHasText: isImageHasText, tableName: strSelectedTable!) {
                
                isSaved = true
                self.dismiss(animated: true) {
                    
                    self.callBack?()
                }
            }
            
            return
        }
        
        if db.insert(id: 0, parentId: selectedParentID, caption: tfCaption.text!, showInMessageBox: false, imgPath: imagePath, recordingPath: audioURL != nil ? audioURL!.absoluteString : "", wordType: strWordType, color: vwbgColor.hexString(), moreWords: isCategory ? "" : tfMoreWords.text!, isCategory: isCategory, sWord: isCategory ? tfMoreWords.text!.lowercased() : "", isImageHasText: isImageHasText, tableName: strSelectedTable!) {
            isSaved = true
            self.dismiss(animated: true) {
                
                self.callBack?()
            }
        }
        
    }
    
    @IBAction func btnCancelPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnWordTypePressed(_ sender: Any) {
        
        let alertView = UIAlertController(title: "WordType", message: "Please select Word Type.", preferredStyle: .actionSheet)
        
        alertView.addAction(UIAlertAction(title: "Noun", style: .default, handler: { [weak self] alert in
            
            self!.strWordType = alert.title!
        }))
        alertView.addAction(UIAlertAction(title: "Verb", style: .default, handler: { [weak self] alert in
            
            self!.strWordType = alert.title!
        }))
        alertView.addAction(UIAlertAction(title: "Descriptive", style: .default, handler: { [weak self] alert in
            
            self!.strWordType = alert.title!
        }))
        alertView.addAction(UIAlertAction(title: "Phrase", style: .default, handler: { [weak self] alert in
            
            self!.strWordType = alert.title!
        }))
        alertView.addAction(UIAlertAction(title: "Others", style: .default, handler: { [weak self] alert in
            
            self!.strWordType = alert.title!
        }))
        
        alertView.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        if let presenter = alertView.popoverPresentationController {
                presenter.sourceView = tfWorkType;
                presenter.sourceRect = tfWorkType.bounds;
            }
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        tfMoreWords.isUserInteractionEnabled = false
        btnAddMoreWords.isSelected = false
    }
    
    @IBAction func btnAddWordForsPressed(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            tfMoreWords.isUserInteractionEnabled = true
            tfMoreWords.becomeFirstResponder()
        } else {
            tfMoreWords.isUserInteractionEnabled = false
            tfMoreWords.resignFirstResponder()
        }
    }
    
    @IBAction func btnColorsPressed(_ sender: UIButton) {
        
        var clr : UIColor = .lightGray
        switch sender.tag {
        case 0:
            clr = #colorLiteral(red: 0.7608028054, green: 0.3028233647, blue: 0, alpha: 1)
            break
        case 1:
            clr = #colorLiteral(red: 0, green: 0.569468379, blue: 0, alpha: 1)
            break
        case 2:
            clr = #colorLiteral(red: 0.6713187099, green: 0, blue: 0.5584232807, alpha: 1)
            break
        case 3:
            clr = #colorLiteral(red: 0.5993054509, green: 0.5179988742, blue: 0, alpha: 1)
            break
        case 4:
            clr = #colorLiteral(red: 0.5147576332, green: 0.008318921551, blue: 0.6677450538, alpha: 1)
            break
        case 5:
            clr = #colorLiteral(red: 0.4588036537, green: 0.4587942362, blue: 0.4630755782, alpha: 1)
            break
        case 6:
            clr = #colorLiteral(red: 0, green: 0.4767668843, blue: 0.6516603827, alpha: 1)
            break
        case 7:
            clr = #colorLiteral(red: 0.5876073241, green: 0.3765279353, blue: 0.2195830047, alpha: 1)
            break
        default:
            break
        }
        vwbgColor = clr
    }
   
    
}

extension AddChoiceVC: RecordingDelegate {

    func audioManager(_ manager: SCAudioManager!, didAllowRecording success: Bool) {
        if !success {
            preconditionFailure("Recording must be allowed in Settings to work.")
        }
    }

    func audioManager(_ manager: SCAudioManager!, didFinishRecordingSuccessfully success: Bool, recodingURL url: URL!) {
        print("did finish recording with success=\(success)")
        
        print(" recodeing URL \(url)")
        audioURL = url
        btnRecord.tintColor = .red//setTitle("Start Recording", for: .normal)
        
       // APPDELEGATE.saveImageToDocumentDirectory(image: <#T##UIImage#>, fileName: <#T##String#>)
    }

    func audioManager(_ manager: SCAudioManager!, didUpdateRecordProgress progress: CGFloat) {
        print("current power: \(manager.lastAveragePower()) dB")
        let linear = 1 - pow(10, manager.lastAveragePower() / 20)

        // Here we add the same sample 3 times to speed up the animation.
        // Usually you'd just add the sample once.
        waveformView.add(samples: [linear, linear, linear])
    }
}

extension AddChoiceVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}


extension AddChoiceVC: WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let msg = message["b"] as? String
       
        DispatchQueue.main.async {
            
            Toast.show(message: msg!, controller: self)
        }
        
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
}
