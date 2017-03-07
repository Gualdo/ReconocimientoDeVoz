//
//  ViewController.swift
//  ReconocimientoDeVoz
//
//  Created by Eduardo D De La Cruz Marr on 3/3/17.
//  Copyright © 2017 Eduardo D De La Cruz Marrero. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController , AVAudioRecorderDelegate
{
    @IBOutlet var textView: UITextView!
    
    var audioRecordingSession : AVAudioSession!
    let audioFileName : String = "audio-recordered.m4a"
    var audioRecorder : AVAudioRecorder!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // recognizeSpeech() // Se usaba para cuando el proyecto tomaba dictado del audio que esta grabado en el proyecto
        recordingAudioSetup()// Encargado de pedirle permisos al usuario
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recognizeSpeech() // Traduce el audio a texto colocandolo en el texview de la vista
    {
        SFSpeechRecognizer.requestAuthorization //dar autorizacion para usar algo del dispositivo
            { (authStatus) in
                if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized // Condicion que compruba que el usuario dio la autorizacion
                {
                    //if let urlPath = Bundle.main.url(forResource: "audio-recordered", withExtension: "m4a") // Este es el audio que grabamos en tiempo real
                    //if let urlPath = Bundle.main.url(forResource: "audio", withExtension: "mp3") // En este se usa el audio que esta grabado en el archivo del proyecto
                    //{
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: /*urlPath se usaba para leer el archivo de audio del proyewcto*/ self.directoryURL()!)
                    
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
                    //}
                }
                else
                {
                    print("No tengo permisos para acceder al Speech Framework")
                }
           }
    }
    
    func recordingAudioSetup() // Metodo encargado de pedir los permisos al usuario si se da se llama al starRecording
    {
        audioRecordingSession = AVAudioSession.sharedInstance() // Sesion de audio compartida ya que el emicrofono lo usa todas las app
        
        do
        {
            try audioRecordingSession.setCategory(AVAudioSessionCategoryRecord) // Para grabar audio desde el microfono
            try audioRecordingSession.setActive(true) // Indica que estamos listos para empezar a grabar a hacer un record
            
            audioRecordingSession.requestRecordPermission( // Pide permiso al usuario para realizar una grabacion
                { [unowned self] (allowed : Bool) in // unowned es una referencia al tipo de metodo que voy a llevar a cabo
                    if allowed
                    {
                        // Hay que empezar a grabar ya que tienes los permisos
                        self.startRecording()
                    }
                    else
                    {
                        print("Necesito permisos para utilizar el micrfono")
                    }
                })
        }
        catch
        {
            print("Ha habido un error al configurar el audio recorder")
        }
    }
    
    func directoryURL() -> URL?
    {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory , in: .userDomainMask) // Sistema de directorios para los audios creados en este casi documentDirectory ya que se guarda en los documentos del telefono y userDomainMask ya que es creado por el usuario
        let documentsDirectory = urls[0] as URL
        
        return documentsDirectory.appendingPathComponent(audioFileName)
    }
    
    func startRecording() // Da los settings de grabacion creando la grabacion en el directorio que se configuro en documentos del usuario.
    {
        let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC) ,
                        AVSampleRateKey : 12000.0 ,
                        AVNumberOfChannelsKey : 1 as NSNumber ,
                        AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue] as [String : Any] // Settings de la grabacion
        
        do
        {
            audioRecorder = try AVAudioRecorder(url: directoryURL()!, settings: settings) // Se crea la grabacion en el directorio especificado
            audioRecorder.delegate = self
            audioRecorder.record() // Se va grabando
            
            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.stopReccording), userInfo: nil, repeats: false) // A los 10 segundos se deja de grabar
        }
        catch
        {
            print("No se ha podido grabar el audio correctamente")
        }
    }
    
    func stopReccording() // Detiene la grabacion luego de que empezo hace 10 segundos
    {
        audioRecorder.stop() // Detiene la grabacion
        audioRecorder = nil // Ya que no va a ser utilizado asi que sale de memoria asignandolo a nil para liberer memoria y proteger la pila
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.recognizeSpeech), userInfo: nil, repeats: false) // Luego de un segundo llama a recognizeSpeech
    }
}
