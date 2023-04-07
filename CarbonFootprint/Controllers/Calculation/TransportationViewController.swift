//
//  MainPageViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 17.03.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TransportationViewController: UIViewController {
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var vehicleTypeLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var distanceTextfield: UITextField!
    var vehicleType: String = "Car"
    var currencyArray: [String] = []
    var type = ""
    var requestManager = RequestManager()
    var calculationManager = CalculationManager()
    var carbonEmission = 0.0
    var isPlane = false
    var count = 1
    var hours = 0
    var minutes = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyArray = requestManager.carArray
        type = currencyArray[0]
        uploadButton.isEnabled = false
        distanceTextfield.delegate = self
        myPickerView.delegate = self
        myPickerView.dataSource = self
        
    }
    
    @IBAction func recordButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toRecord", sender: nil)
    }
    
    
    @IBAction func vehicleButton(_ sender: UIButton) {
        vehicleType = (sender.titleLabel?.text)!
        myPickerView.selectRow(0, inComponent: 0, animated: true)
        distanceTextfield.isHidden = false
        distanceTextfield.text = ""
        uploadButton.isEnabled = false
        vehicleTypeLabel.text = "Which type of your \(vehicleType)"
        isPlane = false
        inputLabel.text = "How many km did you travel?"
        
        
        if vehicleType == "Car" {
            currencyArray = requestManager.carArray
        } else if vehicleType == "Bus" {
            currencyArray = requestManager.busArray
        } else if vehicleType == "Motorbike" {
           
            currencyArray = requestManager.motorcycleArray
        } else if vehicleType == "Plane" {
            vehicleTypeLabel.text = "How long is your travel time?"
            isPlane = true
            distanceTextfield.isHidden = true
            inputLabel.text = ""
        }
        
        myPickerView.reloadAllComponents()
        type = currencyArray[0]
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecord" {
            guard let mapViewController = segue.destination as? MapViewController else {return}
            mapViewController.type = type
        }
    }
    @IBAction func uploadPress(_ sender: UIButton) {
        
        if let carbonValue = requestManager.generalTypeDict[type] {
                if isPlane{
                    carbonEmission = calculationManager.calculatePlane(hours: hours, minutes: minutes)
                    print("planeee\(carbonEmission)")
                } else {
                    if let amount = Double(distanceTextfield.text!) {
                        carbonEmission = calculationManager.calculateWithKM(carbonValue: carbonValue, amount: amount)
                        print("kmkmkm\(carbonEmission)")
                }
            }
            requestManager.uploadData(type: type, navigationController: self.navigationController!, energyType: K.transportation, emission: carbonEmission, viewController: self)
        }
       
    }
}
//MARK: -
extension TransportationViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if !isPlane{
            if distanceTextfield.text == "" {
                uploadButton.isEnabled = false
            } else {
                uploadButton.isEnabled = true
            }
        }
    }
}
//MARK: -
extension TransportationViewController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isPlane{
            if component == 0 {
                return String(format: "%02d", requestManager.hoursArray[row])
            } else if component == 1 {
                return String(format: "%02d", requestManager.minutesArray[row])
            } else {
                return nil
            }
        } else {
            return currencyArray[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isPlane{
            type = "Plane"
            uploadButton.isEnabled = true
            switch component {
            case 0:
                hours = requestManager.hoursArray[row]
            case 1:
                minutes = requestManager.minutesArray[row]
            default:
                hours = 0
                minutes = 0
            }
            if hours == 0, minutes == 0 {
                uploadButton.isEnabled = false
            } else {
                uploadButton.isEnabled = true
            }
        } else {
            type = currencyArray[row]
        }
    }
}
//MARK: -
extension TransportationViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isPlane {
            return 2
        } else {
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isPlane {
            switch component {
            case 0:
                return requestManager.hoursArray.count
            case 1:
                return requestManager.minutesArray.count
            default:
                return 0
            }
        } else {
            return currencyArray.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if isPlane{
            return 50
        } else {
            return 230
        }
    }
}
