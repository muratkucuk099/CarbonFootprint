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
    
    @IBOutlet weak var motorButton: UIButton!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var vehicleTypeLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var myPickerView: UIPickerView!
    @IBOutlet weak var distanceTextfield: UITextField!
    @IBOutlet weak var recordButton: UIButton!
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
        guard let iconImage = UIImage(named: "moto") else { return }
        let size = CGSize(width: 42, height: 42) // Boyutu buradan ayarlayabilirsiniz
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedIcon = renderer.image { _ in
            iconImage.draw(in: CGRect(origin: .zero, size: size))
        }
        motorButton.setImage(resizedIcon, for: .normal)
        motorButton.imageView?.contentMode = .scaleAspectFit
        currencyArray = requestManager.carArray
        type = currencyArray[0]
        uploadButton.isEnabled = false
        distanceTextfield.delegate = self
        myPickerView.delegate = self
        myPickerView.dataSource = self
        myPickerView.setValue(UIColor.black, forKeyPath: "textColor")
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toRecord", sender: nil)
    }
    
    
    @IBAction func vehicleButton(_ sender: UIButton) {
        vehicleType = (sender.titleLabel?.text)!
        myPickerView.selectRow(0, inComponent: 0, animated: true)
        distanceTextfield.isHidden = false
        distanceTextfield.text = ""
        uploadButton.isEnabled = false
        recordButton.isEnabled = true
        vehicleTypeLabel.text = "Which Type of Your \(vehicleType)?"
        isPlane = false
        inputLabel.text = "Distance Traveled in Km?"
        
        if vehicleType == "Car" {
            currencyArray = requestManager.carArray
        } else if vehicleType == "Bus" {
            currencyArray = requestManager.busArray
        } else if vehicleType == "Motorbike" {
            currencyArray = requestManager.motorcycleArray
        } else if vehicleType == "Plane" {
            vehicleTypeLabel.text = "How Long is Your Travel Time?"
            isPlane = true
            distanceTextfield.isHidden = true
            inputLabel.text = "Recording Flight is Coming Soon!"
            recordButton.isEnabled = false
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
            print(type)
            if isPlane{
                carbonEmission = calculationManager.calculatePlane(hours: hours, minutes: minutes)
            } else {
                if let amount = Double(distanceTextfield.text!) {
                    carbonEmission = calculationManager.calculateWithKM(carbonValue: carbonValue, amount: amount)
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
