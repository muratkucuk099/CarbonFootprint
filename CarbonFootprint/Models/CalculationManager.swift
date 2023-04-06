//
//  CalculationManager.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 28.03.2023.
//

import Foundation
import UIKit

struct CalculationManager{
    func calculateWithKM(carbonValue: Double, amount: Double) -> Double{
       
        let carbonEmission = Double(String(format: "%.2f", carbonValue * amount))!
        return carbonEmission
    }
    
    func calculateHousehold(carbonValue: Double, amount: Double, numberOfPeople: Double) -> Double{
        let carbonEmission = Double(String(format: "%.2f", carbonValue * amount / numberOfPeople))!
        return carbonEmission
    }
    func calculatePlane(hours: Int, minutes: Int) -> Double{
        
        let carbonEmission = Double(String(format: "%.2f", Double(70 * hours) + (1.16 * Double(minutes))))!
        return carbonEmission
    }
    
}
