//
//  ViewController.swift
//  100 Days of Swift Project 5
//
//  Created by Seb Vidal on 18/11/2021.
//

import UIKit

class ViewController: UITableViewController {
    var allWords: [String] = []
    var usedWords: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        loadWords()
        startGame()
    }
    
    func loadWords() {
        if let startURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    @objc func startGame() {
        title = allWords.randomElement()?.capitalized
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
    }
    
    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter Answer:", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] action in
            guard let answer = alertController?.textFields?[0].text else {
                return
            }
            
            self?.submit(answer)
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if !isPossible(word: lowerAnswer){
            guard let title = title?.lowercased() else {
                return
            }
            
            showErrorAlert(title: "Word Not Possible", message: "You can't spell that word from \(title)!")
            
            return
        }
        
        if !isOriginal(word: lowerAnswer) {
            showErrorAlert(title: "Word Already Used", message: "Be more original!")
            
            return
        }
        
        if !isReal(word: lowerAnswer) {
            showErrorAlert(title: "Word Not Recognised", message: "You can't just make them up, you know!")
            
            return
        }
        
        usedWords.insert(answer.lowercased(), at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row].capitalized
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let word = title?.lowercased() else {
            return
        }
        
        let title = usedWords[indexPath.row].capitalized
        let messagee = "You used \(title.count) of \(word.count) letters."
        let alertController = UIAlertController(title: title, message: messagee, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            tableView.deselectRow(at: indexPath, animated: true)
        }))
        
        present(alertController, animated: true)
    }
}

