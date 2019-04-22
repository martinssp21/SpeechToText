//
//  ViewController.swift
//  SpeechToText
//
//  Created by Rodrigo Martins on 22/04/19.
//  Copyright © 2019 Rodrigo Martins. All rights reserved.
//

import UIKit
import  Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet private weak var detectedTextLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var colorView: UIView!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt_BR"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func recordAndRecognizeSpeech() -> Swift.Void{
        let node = audioEngine.inputNode
        let recordiongFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordiongFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do{
            try audioEngine.start()
        } catch{
            return print(error)
        }
        
        guard let myRecongnizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecongnizer.isAvailable{
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let sResult = result {
                let bestString = sResult.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
            } else if let errorPrint = error {
                print(errorPrint)
            }
        })
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        self.recordAndRecognizeSpeech()
    }
    
}
