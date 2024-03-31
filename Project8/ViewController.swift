//
//  ViewController.swift
//  Project8
//
//  Created by Will Kembel on 3/27/24.
//

import UIKit

class ViewController: UIViewController {
    
    var scoreLabel: UILabel!
    var hintsLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var letterButtons = [UIButton]()
    var solutions = [String]()
    var solutionBits = [String]()
    var activeButtons = [UIButton]()
    
    var level = 1
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var prevLevelScore = 0
    
    override func loadView() {
        let gameView = UIView()
        gameView.backgroundColor = .white
        view = gameView
        
        // format UI
        //
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(scoreLabel)
        
        hintsLabel = UILabel()
        hintsLabel.translatesAutoresizingMaskIntoConstraints = false
        hintsLabel.textAlignment = .left
        hintsLabel.text = "HINTS"
        hintsLabel.font = UIFont.systemFont(ofSize: 24)
        hintsLabel.numberOfLines = 0
        hintsLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // ok to stretch
        view.addSubview(hintsLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.textAlignment = .right
        answersLabel.text = "ANSWERS"
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.numberOfLines = 0
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // ok to stretch
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Press Buttons to Build Answer Here"
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.textAlignment = .center
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        //submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.textAlignment = .center
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        //clearButton.setTitleColor(.black, for: .normal)
        clearButton.titleLabel?.textAlignment = .center
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clearButton)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        // position UI
        //
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            hintsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            hintsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            hintsLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: hintsLabel.heightAnchor),
            
            currentAnswer.topAnchor.constraint(equalTo: hintsLabel.bottomAnchor, constant: 10),
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, constant: -200),
            
            submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            
            clearButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
            
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 10),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 10)
        ])
        
        // input buttons
        //
        let letterButtonWidth = 150
        let letterButtonHeight = 80
        for row in 0..<4 {
            for col in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 44)
                letterButton.titleLabel?.textAlignment = .center
                //letterButton.setTitleColor(.black, for: .normal)
                letterButton.setTitle("WWW", for: .normal)
                
                let frame = CGRect(x: col * letterButtonWidth, y: row * letterButtonHeight, width: letterButtonWidth, height: letterButtonHeight)
                letterButton.frame = frame
                
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let submittedAnswer = currentAnswer?.text else { return }
        
        // correct solution
        //
        if let matchIndex = solutions.firstIndex(of: submittedAnswer) {
            // update answer label
            var visibleAnswers = answersLabel.text?.components(separatedBy: "\n")
            visibleAnswers?[matchIndex] = submittedAnswer
            answersLabel.text = visibleAnswers?.joined(separator: "\n")
            
            // clear answer field
            //
            currentAnswer.text = ""
            
            // score and level up
            //
            score += 1
           
            if score.isMultiple(of: 7) {
                let ac = UIAlertController(title: "Level Complete!", message: "Ready to level up?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Lets go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
                    
        }
        else {
            showError(saying: "Incorrect solution. Try something else.")
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer?.text = ""
        score = prevLevelScore
        loadLevel()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        if let answerFieldText = currentAnswer?.text {
            currentAnswer.text = answerFieldText + buttonTitle
            sender.isHidden = true
            activeButtons.append(sender)
        }
    }
    
    func loadLevel() {
        solutions.removeAll()
        solutionBits.removeAll()
        
        var hintLabelString = ""
        var answerLabelString = ""
        if let fileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let fileString = try? String(contentsOf: fileURL) {
                let lines = fileString.components(separatedBy: "\n")
                
                for (index, line) in lines.enumerated() {
                    // extract answer and hint from line
                    //
                    let lineSections = line.components(separatedBy: ": ")
                    let rawAnswer = lineSections[0]
                    let hint = lineSections[1]
                    
                    // populate UI label strings for hint and answers
                    //
                    let answer = rawAnswer.replacingOccurrences(of: "|", with: "")
                    answerLabelString += "\(answer.count) characters\n"
                    solutions.append(answer) // store for button press later
                    hintLabelString += "\(index+1). \(hint)\n"
                    
                    // extract answer bits
                    //
                    solutionBits += rawAnswer.components(separatedBy: "|")
                }
                
                
                // populate UI
                //
                answersLabel.text = answerLabelString.trimmingCharacters(in: .whitespacesAndNewlines)
                hintsLabel.text = hintLabelString.trimmingCharacters(in: .whitespacesAndNewlines)
                
                letterButtons.shuffle()
                
                if letterButtons.count == solutionBits.count {
                    for (index, button) in letterButtons.enumerated() {
                        button.setTitle(solutionBits[index], for: .normal)
                    }
                    
                    // reset used buttons
                    //
                    for button in activeButtons {
                        button.isHidden = false
                    }
                    activeButtons.removeAll()
                }
                else {
                    showError(saying: "Number of answer bits doesn't match number of answer buttons.")
                }
                
                return
                
            } // load file into string
        } // create file url
        
        showError(saying: "Unable to load file level\(level).txt")
    }
    
    func showError(saying msg: String) {
        let ac = UIAlertController(title: "File Error", message: msg, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func levelUp(_ alert: UIAlertAction) {
        let maxLevel = 2
        level += 1
        prevLevelScore = score
        
        if level > maxLevel { return }
        
        loadLevel()
    }


}

