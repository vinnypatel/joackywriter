//
//  SuggetionVC.swift
//  JoackyWriter
//
//  Created by Vinay Patel on 12/10/21.
//

import UIKit

class SuggetionVC: UIViewController {
    
    var arrChoice : [Choices] = []
    
    @IBOutlet weak var choiceClVw: UICollectionView!
    
    var callBackWithChoice: ((Choices, Int)->())?
    var callBackViewDidDisAppear:(()->())?
    private let audioManager: SCAudioManager!
    var count: Int = 0
    //private let arrSelectedCellForEdit: [Int] = []
    required init?(coder: NSCoder) {
        audioManager = SCAudioManager()
        
        
        super.init(coder: coder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callBackViewDidDisAppear?()
    }
    
    
    fileprivate func readChoiceDB(parentID: Int, withTableName name: String) {
        
        arrChoice = DBHelper.shared.read(parentID: parentID, withTableName: name)
        self.choiceClVw.reloadData()
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


extension SuggetionVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return arrChoice.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = choiceClVw.dequeueReusableCell(withReuseIdentifier: "choiceCell", for: indexPath) as! ChoiceClVwCell
        
        cell.modelChoice = arrChoice[indexPath.row]
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {

        return UIDevice.current.userInterfaceIdiom == .phone ? CGSize(width: 120, height: collectionView.frame.height/3 - 4) :CGSize(width: 184, height: 140)
        
            }

            func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                return 0.0
            }

            func collectionView(_ collectionView: UICollectionView, layout
                collectionViewLayout: UICollectionViewLayout,
                                minimumLineSpacingForSectionAt section: Int) -> CGFloat {
                return 0.0
            }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if arrChoice[indexPath.row].isCategory {
           
            self.readChoiceDB(parentID: arrChoice[indexPath.row].id, withTableName: "TABLE_CHOICE")
            
        } else {

            let model  = arrChoice[indexPath.row]
            if let audioURL = URL(string: model.recordingPath!) {
                
                audioManager.playAudioFile(from: audioURL)
                
            }
                let cell = choiceClVw.cellForItem(at: indexPath) as! ChoiceClVwCell
            let imageViewPosition : CGPoint = cell.vw.convert(cell.vw.bounds.origin, to: self.view)
            
            let vwTemp = UIView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.vw.frame.size.width, height: cell.vw.frame.size.height))
            vwTemp.backgroundColor = cell.vw.backgroundColor
            vwTemp.layer.cornerRadius = 8
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: vwTemp.frame.width, height: vwTemp.frame.height))
            
            lbl.text = cell.lblChoiceName.text
            lbl.textAlignment = .center
            vwTemp.addSubview(lbl)
            //let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.lblChoiceName.frame.size.width, height: cell.lblChoiceName.frame.size.height))
            
           // imgViewTemp.image = cell.imageViewProduct.image
            
            animation(tempView: vwTemp) { [weak self] in
                
                self!.callBackWithChoice?(self!.arrChoice[indexPath.row], self!.count)
                
                //self!.arrSelectedChoices.append(selectedChoiceWords(strCaption: model.caption, strImageName: model.imgPath!))
                self!.tapOnChoicesWords(strToSpeak: model.caption)
                self!.count += 1
            }
            
            
       //
            
        }
        
    }
    
    @objc func tapOnChoicesWords(strToSpeak: String) {
        
        
//        let arrCaption = arrSelectedChoices.map({$0.strCaption})
//        arrTempSelectedChoices = arrCaption
        let utterance = AVSpeechUtterance(string: strToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.3
       // AppDelegate.speechSynthesizer.delegate = self
       // let synthesizer = AVSpeechSynthesizer()
        AppDelegate.speechSynthesizer.speak(utterance)
    }
    
    func animation(tempView : UIView,  finished: @escaping() -> Void)  {
        self.view.addSubview(tempView)
        UIView.animate(withDuration: 1.0,
                       animations: {
                        tempView.animationZoom(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                tempView.animationZoom(scaleX: 0.2, y: 0.2)
                tempView.animationRoted(angle: CGFloat(Double.pi))
                
                tempView.frame.origin.x = self.view.frame.width/2
                tempView.frame.origin.y = -50//self.clVwSelectedChoices.frame.height
                
            }, completion: { _ in
                
                tempView.removeFromSuperview()
                
                finished()
//                UIView.animate(withDuration: 1.0, animations: {
////
//////                    self.counterItem += 1
//////                    self.lableNoOfCartItem.text = "\(self.counterItem)"
//                    self.clVwSelectedChoices.animationZoom(scaleX: 1.1, y: 1.1)
//                }, completion: {_ in
//                    self.clVwSelectedChoices.animationZoom(scaleX: 1.0, y: 1.0)
//                })
                
            })
            
        })
    }

}
