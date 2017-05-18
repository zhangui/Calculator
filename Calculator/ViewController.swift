//
//  ViewController.swift
//  Calculator
//
//  Created by Yang Zhang on 5/14/17.
//  Copyright © 2017 Yang Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var previousActions: UILabel!
    @IBOutlet weak var display: UILabel!
    
    var userIsTyping = false
    
    private var model = CalculatorModel()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if model.canReset() {
            display.text = digit
            userIsTyping = true
        } else {
            if userIsTyping {
                let TextCurrentlyInDisplay = display.text!
                if !model.checkFloat() {
                    display.text = TextCurrentlyInDisplay + digit
                } else {
                    display.text = TextCurrentlyInDisplay + "." + digit
                    model.resetFloat()
                }
            } else {
                if !model.checkFloat() {
                    display.text = digit
                } else {
                    display.text = "0." + digit
                    model.resetFloat()
                }
                userIsTyping = true
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = model.removeTrailing(float: String(newValue))
        }
    }
    

    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            model.setOperand(displayValue)
            userIsTyping = false
        }
        previousActions.text = model.updatePreviousActions()
        if let mathematicalSymbol = sender.currentTitle {
            model.performOperation(mathematicalSymbol)
        }
        previousActions.text = model.updatePreviousActions()
        if let result = model.result {
            if !model.checkFloat() {
                displayValue = result
            }
            userIsTyping = true
            previousActions.text = model.updatePreviousActions()
            if result == 0 {
                userIsTyping = false
            }
        }
    }


}

