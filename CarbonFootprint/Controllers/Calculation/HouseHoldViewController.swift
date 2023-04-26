//
//  HouseHoldViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 22.03.2023.
//

import UIKit

class HouseHoldViewController: UIViewController {

    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var inputTextfield: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var typeLabel: UILabel!
    var type = ""
    var unit = ""
    var carbonEmission = 0.0
    var currencyArray: [String] = []
    let requestManager = RequestManager()
    let calculationManager = CalculationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyArray = ["Electric"]
        type = currencyArray[0]
        calculateButton.isEnabled = false
        inputTextfield.delegate = self
        myPickerView.delegate = self
        myPickerView.dataSource = self
        
        print(calculateButton.isEnabled)
        
    }
    
    @IBAction func electricPress(_ sender: UIButton) {
        currencyArray = ["Electric"]
        type = "Electric"
        unit = requestManager.unitDict[type]!
        myPickerView.reloadAllComponents()
        unitLabel.text = unit
        typeLabel.text = "Which Type of Your Electric?"
       
    }
    
    @IBAction func warmPress(_ sender: UIButton) {
        currencyArray = requestManager.warmArray
        type = currencyArray[0]
        unit = requestManager.unitDict[type]!
        myPickerView.reloadAllComponents()
        unitLabel.text = unit
        typeLabel.text = "Which Type of Your Warm?"
    }
    
    @IBAction func calculatePress(_ sender: UIButton) {
        if let carbonValue = requestManager.generalTypeDict[type] {
            if let amount = Double(inputTextfield.text!) {
                carbonEmission = calculationManager.calculateHousehold(carbonValue: carbonValue, amount: amount, numberOfPeople: 1.0)
            }
        }
        requestManager.uploadData(type: type, navigationController: self.navigationController!, energyType: K.household, emission: carbonEmission, viewController: self)
    }
}
//MARK: -
extension HouseHoldViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if inputTextfield.text == "" {
            calculateButton.isEnabled = false
        } else {
            calculateButton.isEnabled = true
        }
    }
}
//MARK: -
extension HouseHoldViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = currencyArray[row]
        unit = requestManager.unitDict[type]!
        unitLabel.text = unit
    }
}
//MARK: -
extension HouseHoldViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencyArray.count
    }
    
    
}
