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
        self.requestSpeechAuthorization()
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
                
                var lastString = String()
                for segment in sResult.bestTranscription.segments{
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorSaid(resulString: lastString)
                
            } else if let errorPrint = error {
                print(errorPrint)
            }
        })
    }

    func checkForColorSaid(resulString: String){
        switch resulString {
        case "vermelho":
            self.colorView.backgroundColor = UIColor.red
        case "azul":
            self.colorView.backgroundColor = UIColor.blue
        case "verde":
            self.colorView.backgroundColor = UIColor.green
        case "amarelo":
            self.colorView.backgroundColor = UIColor.yellow
        case "laranja":
            self.colorView.backgroundColor = UIColor.orange
        case "roxo":
            self.colorView.backgroundColor = UIColor.purple
        case "branco":
            self.colorView.backgroundColor = UIColor.white
        case "preto":
            self.colorView.backgroundColor = UIColor.black
        default:
            self.colorView.backgroundColor = UIColor.gray
        }
        
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization({authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Reconhecimento de voz desabilitado!"
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Reconhecimento bloqueado pelo usuário. :("
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Reconhecimento de voz restrito neste dispositivo."
                @unknown default:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Erro desconhecido"
                }
            }
            
        })
    }
    @IBAction func startButtonTapped(_ sender: Any) {
        self.recordAndRecognizeSpeech()
    }
    
}
