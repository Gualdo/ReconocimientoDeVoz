//
//  ViewController.swift
//  ReconocimientoDeVoz
//
//  Created by Eduardo D De La Cruz Marr on 3/3/17.
//  Copyright © 2017 Eduardo D De La Cruz Marrero. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController
{
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        recognizeSpeech()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recognizeSpeech()
    {
        SFSpeechRecognizer.requestAuthorization //dar autorizacion para usar algo del dispositivo
            { (authStatus) in
                if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized // Condicion que compruba que el usuario dio la autorizacion
                {
                    if let urlPath = Bundle.main.url(forResource: "audio", withExtension: "mp3")
                    {
                        let recognizer = SFSpeechRecognizer()
                        let request = SFSpeechURLRecognitionRequest(url: urlPath)
                        
                        recognizer?.recognitionTask(with: request, resultHandler:
                            { (result, error) in
                                if let error = error
                                {
                                    print("Algo ha ido mal \(error.localizedDescription /*Da una descripcion del error que ha ocurrido*/)")
                                }
                                else
                                {
                                    self.textView.text = result?.bestTranscription.formattedString // Cambia el resultado a String
                                }
                            })
                    }
                }
                else
                {
                    print("No tengo permisos para acceder al Speech Framework")
                }
            }
    }
}
