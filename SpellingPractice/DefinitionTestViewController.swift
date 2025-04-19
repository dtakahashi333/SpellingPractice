//
//  DefinitionTestViewController.swift
//  SpellingPractice
//
//  Created by Daisuke Takahashi on 1/12/19.
//  Copyright © 2019 Daisuke Takahashi. All rights reserved.
//

import UIKit
import DLRadioButton
import AVFoundation
import SwiftIconFont

class DefinitionTestViewController: UIViewController {
    private var dataJson: [String: Any]? = [:]
    private var words: [String] = []
    private var wordSize = 0
    private var index = 0
    private var correctCount = 0
    private var answer: String = ""
    private let synth = AVSpeechSynthesizer()

    private let cloverColor = UIColor.init(red: 66.0/255.0, green: 140.0/255.0, blue: 39.0/255, alpha: 1.0)
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var definitionField: UILabel!
    @IBOutlet weak var answerChoice1: DLRadioButton!
    @IBOutlet weak var answerChoice2: DLRadioButton!
    @IBOutlet weak var answerChoice3: DLRadioButton!
    @IBOutlet weak var answerChoice4: DLRadioButton!
    private var answerChoices: [DLRadioButton] = []
    @IBOutlet weak var answerField: UILabel!
    @IBOutlet weak var resultField: UILabel!
    @IBOutlet weak var questionNumField: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var scoreField: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var checkField1: UILabel!
    @IBOutlet weak var checkField2: UILabel!
    @IBOutlet weak var checkField3: UILabel!
    @IBOutlet weak var checkField4: UILabel!
    private var checkFields: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        titleField.text = "Word Definition Practice (ver " + version! + ")"
        answerField.text = ""
        resultField.text = ""
        
        // Load words from temp.bundle/words.txt
        var content: String? = nil
        do {
            let path = Bundle.main.resourcePath! + "/temp.bundle/words.json"
            content = try String(contentsOfFile:path, encoding:String.Encoding.utf8) as String //encoding: NSUTF8StringEncoding
        } catch {}
        
        do {
            let data: Data = content!.data(using: String.Encoding.utf8)!
            dataJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            var temp = Array(dataJson!.keys)
            // Randomize a word list.
            while temp.count > 0 {
                let number = Int.random(in: 0 ..< temp.count)
                words.append(String(temp[number]))
                temp.remove(at: number)
            }
        } catch {}
        
        wordSize = words.count
        
        // radio button configuration
        answerChoices = [
            answerChoice1,
            answerChoice2,
            answerChoice3,
            answerChoice4
        ]
        // check field configuration
        checkFields = [
            checkField1,
            checkField2,
            checkField3,
            checkField4
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Disable Next button while enabling Confirm button.
        nextButton.isEnabled = false
        confirmButton.isEnabled = true
        // Generate the first question.
        generateQuestion()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func confirmButtonPressed(_ sender: Any) {
        //if let yourAnswer = answerChoices.first(where: { $0.isSelected }) {
        if let yourAnswer = answerChoice1.selected() {
            let isCorrect = yourAnswer.title(for: .normal) == answer
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
                speak(string: answer)
            }
            
            let answerIndex = answerChoices.firstIndex(where: { $0.title(for: .normal) == answer })
            for i in 0 ..< checkFields.count {
                if (i == answerIndex) {
                    checkFields[i].text = String.fontAwesome5Icon("check")
                    checkFields[i].textColor = cloverColor
                } else {
                    checkFields[i].text = String.fontAwesome5Icon("times")
                    checkFields[i].textColor = UIColor.red
                }
                checkFields[i].font = UIFont.icon(from: .fontAwesome5, ofSize: 17.0)
            }
        }
        // Enable Next button to allow the user to proceed to the next question while disabling Confirm button.
        nextButton.isEnabled = true
        confirmButton.isEnabled = false
    }
    
    func speak(string: String, pauseBefore: Double = 0.0, pauseAfter: Double = 0.0, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utter = AVSpeechUtterance(string: string)
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.preUtteranceDelay = pauseBefore
        utter.postUtteranceDelay = pauseAfter
        utter.rate = rate
        synth.speak(utter)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if index + 1 > 35 {
            // End the test.
            let score = Double(correctCount) / 35.0 * 100.0
            scoreField.text = String(format: "Score: %.2f %%", score)
            confirmButton.isEnabled = false
        } else {
            // Disable Next button while enabling Confirm button.
            nextButton.isEnabled = false
            confirmButton.isEnabled = true
            // Generate a next question.
            generateQuestion()
        }
    }
    
    private func generateQuestion() {
        answer = words[index]
        let word = dataJson![answer] as? [String: String]
        print("\(String(describing: word!["definition"]))")
        definitionField.text = word!["definition"]
        
        var temp = words
        temp.remove(at: temp.firstIndex(of: answer)!)
        
        var answers = [answer]
        for _ in 0 ..< 3 {
            let number = Int.random(in: 0 ..< temp.count)
            answers.append(temp[number])
            temp.remove(at: number)
        }
        
        for x in 0 ..< 4 {
            let number = Int.random(in: 0 ..< answers.count)
            answerChoices[x].setTitle(answers[number], for: .normal)
            answers.remove(at: number)
        }
        
        answerChoice1.isSelected = true
        questionNumField.text = String(format: "%d / 35", index + 1)
        index += 1
        
        for i in 0 ..< checkFields.count {
            checkFields[i].text = ""
        }
        resultField.text = ""
        answerField.text = ""
    }
}
