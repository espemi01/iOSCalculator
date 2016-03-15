//
//  ViewController.swift
//  Calculator
//
//  Created by Michael Espey on 2/7/16.
//  Copyright © 2016 MAEspey. All rights reserved.
//

import UIKit

class CalcViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var decimalButton: UIButton!
    
    var typing: Bool = false
    let decimalSeparator = NSNumberFormatter().decimalSeparator!
    
    var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decimalButton.setTitle(decimalSeparator, forState: UIControlState.Normal)
        display.text = " "
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if typing {
            if (digit == decimalSeparator) && (display.text!.rangeOfString(decimalSeparator) != nil) { return
//                display.text = display.text! + decimalSeparator
//                print("Decimal")
            }
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")) { return }
            if (digit != decimalSeparator) && ((display.text == "0") || (display.text == "-0")) {
                if (display.text == "0") {
                    display.text = digit
                } else {
                    display.text = "-" + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            if digit == decimalSeparator {
                display.text = "0" + decimalSeparator
            } else {
                display.text = digit
            }
            typing = true
            history.text = brain.description != "?" ? brain.description : ""
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle {
            if typing {
                if operation == "±" {
                    let displayText = display.text!
                    if (displayText.rangeOfString("-") != nil) {
                        display.text = String(displayText.characters.dropFirst())
                    } else {
                        display.text = "-" + displayText
                    }
                    return
                }
                enter()
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                // error?
                displayValue = nil
            }
        }
    }
    
    @IBAction func enter() {
        typing = false
        if displayValue != nil {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                // error?
                displayValue = nil
            }
        }
    }
    
    @IBAction func clear() {
        brain = CalculatorBrain()
        displayValue = nil
        history.text = ""
    }
    
    @IBAction func backSpace() {
        if typing {
            let displayText = display.text!
            if displayText.characters.count > 1 {
                display.text = String(displayText.characters.dropLast())
                if (displayText.characters.count == 2) && (display.text?.rangeOfString("-") != nil) {
                    display.text = "-0"
                }
            } else {
                display.text = "0"
            }
        } else {
            if let result = brain.popOperand() {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if typing {
            enter()
        }
        if let result = brain.pushOperand(sender.currentTitle!) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    @IBAction func storeVariable(sender: UIButton) {
        if let variable = (sender.currentTitle!).characters.last {
            if displayValue != nil {
                brain.variableValues["\(variable)"] = displayValue
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = nil
                }
            }
        }
        typing = false
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if (newValue != nil) {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                numberFormatter.maximumFractionDigits = 10
                display.text = numberFormatter.stringFromNumber(newValue!)
            } else {
                if let result = brain.evaluateAndReportErrors() as? String {
                    display.text = result
                } else {
                    display.text = " "
                }
            }
            typing = false
            history.text = brain.description != "" ? brain.description + " =" : ""
        }
    }
}