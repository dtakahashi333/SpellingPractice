//
//  ViewController.swift
//  iPadApp
//
//  Created by Daisuke Takahashi on 12/15/18.
//  Copyright © 2018 Daisuke Takahashi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, SpeedOptionsDelegate {
    //private let speed = [ AVSpeechUtteranceMinimumSpeechRate, AVSpeechUtteranceDefaultSpeechRate, AVSpeechUtteranceMaximumSpeechRate ]
    private let speed: [Float] = [ 0.3, 0.4, 0.5, 0.6 ]
    private var words: [String] = []
    private var wordSize = 0
    private var index = 0
    private let synth = AVSpeechSynthesizer()
    private var correctCount = 0
    private var speedIndex: Int = 2
    
    private let cloverColor = UIColor.init(red: 66.0/255.0, green: 140.0/255.0, blue: 39.0/255, alpha: 1.0)

    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var yourAnswerField: UITextField!
    @IBOutlet weak var resultField: UILabel!
    @IBOutlet weak var answerField: UILabel!
    @IBOutlet weak var questionNumField: UILabel!
    @IBOutlet weak var scoreField: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        titleField.text = "Spelling Practice (ver " + version! + ")"
        resultField.text = ""
        answerField.text = ""
        questionNumField.text = "1"
        scoreField.text = "0"
        
        // Initialize buttons.
        speedButton.setTitle("Normal", for: .normal)
        
        // Load words from temp.bundle/words.txt
        var content: String? = nil
        do {
            let path = Bundle.main.resourcePath! + "/temp.bundle/words.json"
            content = try String(contentsOfFile:path, encoding:String.Encoding.utf8) as String //encoding: NSUTF8StringEncoding
        } catch {}
        
        do {
            let data: Data = content!.data(using: String.Encoding.utf8)!
            var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            json = json!["5"] as? [String : Any];

            var temp = Array(json!.keys)
            // Randomize a word list.
            while(temp.count > 0) {
                let number = Int.random(in: 0 ..< temp.count)
                words.append(String(temp[number]))
                temp.remove(at: number)
            }
        } catch {}
        
        //print("\(AVSpeechSynthesisVoice.speechVoices())")

        wordSize = words.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speak(string: words[index], rate: speed[speedIndex])
    }
    
    func speak(string: String, pauseBefore: Double = 0.0, pauseAfter: Double = 0.0, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utter = AVSpeechUtterance(string: string)
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.preUtteranceDelay = pauseBefore
        utter.postUtteranceDelay = pauseAfter
        utter.rate = rate
        synth.speak(utter)
    }
    
    @IBAction func speakButtonPressed(_ sender: Any) {
        speak(string: words[index], rate: speed[speedIndex])
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        answerField.text = ""
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        let yourAnswer = yourAnswerField.text
        let answer = words[index]
        let isCorrect = (yourAnswer == answer)
        
        var result: String
        if isCorrect {
            resultField.textColor = cloverColor
            result = "Correct!"
            correctCount += 1
        } else {
            resultField.textColor = UIColor.red
            result = "Incorrect..."
        }
        
        resultField.text = result
        answerField.text = answer
        speak(string: "Your answer is")
        speak(string: result)
        
        if !isCorrect {
            speak(string: "And the correct answer is")
            for letter in answer {
                speak(string: String(letter))
            }
            speak(string: answer)
        }

        index += 1
        if index >= 35 {
            // End the test.
            let score = Double(correctCount) / 35.0 * 100.0
            scoreField.text = String(format: "%.2f", score)
            confirmButton.isEnabled = false
        } else {
            // Go to the next word.
            questionNumField.text = String(index + 1)
            speak(string: words[index], pauseBefore: 0.8, rate: speed[speedIndex])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeedOptions" {
            if let viewController = segue.destination as? SpeedOptionsViewController {
                viewController.index = speedIndex
                viewController.delegate = self
            }
        }
    }
    
    func optionSelected(_ index: Int, title: String) {
        speedIndex = index
        speedButton.setTitle(title, for: .normal)
    }
}

