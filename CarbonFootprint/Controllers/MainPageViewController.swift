//
//  MainPageViewController.swift
//  CarbonFootprintCalculatorDemo1
//
//  Created by Mac on 21.03.2023.
//

import UIKit
import FirebaseAuth
import Charts
import FirebaseFirestore


class MainPageViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var totalCalculationLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    var total: Float = 0.0
    var transportationDataEntry = PieChartDataEntry(value: 10, icon: UIImage(systemName: "car"))
    var houseHoldDataEntry = PieChartDataEntry(value: 10, icon: UIImage(systemName: "house"))
    var carDataEntry = BarChartDataEntry(x: 1, y: 20, icon: UIImage(systemName: "car"))
    var motorDataEntry = BarChartDataEntry(x: 3, y: 20, icon: UIImage(systemName: "bicycle"))
    var busDataEntry = BarChartDataEntry(x: 2, y: 20, icon: UIImage(systemName: "bus.fill"))
    var airPlaneDataEntry = BarChartDataEntry(x: 4, y: 20, icon: UIImage(systemName: "airplane"))
    var electricDataEntry = BarChartDataEntry(x : 5, y: 20, icon: UIImage(systemName: "bolt"))
    var warmDataEntry = BarChartDataEntry(x: 6, y: 20, icon: UIImage(systemName: "flame"))
    
    var pieNumberofDataEntry = [PieChartDataEntry]()
    var barNumberofDataEntry = [BarChartDataEntry]()
    
    var requestManager = RequestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChartView.chartDescription.text = ""
        barNumberofDataEntry = [carDataEntry]
        pieNumberofDataEntry = [transportationDataEntry, houseHoldDataEntry]
        firebaseGetData()
        
    }
    func barChartUpdate() {
        let entries = [
            carDataEntry,
            busDataEntry,
            motorDataEntry,
            airPlaneDataEntry,
            electricDataEntry,
            warmDataEntry
        ]
        
        let dataSet = BarChartDataSet(entries: entries, label: "")
        
        
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
        dataSet.colors = [.red, .orange, .yellow, .green, .blue, .black]
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelCount = entries.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["", "Car", "Bus", "Bike", "Plane", "Electric", "Warm"])
        barChartView.leftAxis.axisMinimum = 0
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    func pieChartUpdateData(){
        let chartDataSet = PieChartDataSet(entries: pieNumberofDataEntry, label: "")
        chartDataSet.iconsOffset = CGPoint(x: 10,y: 0)
        let charData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor.darkGray, UIColor.systemBrown]
        chartDataSet.colors = colors
        pieChartView.data = charData
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        barChartView.layer.borderWidth = 2
        barChartView.layer.cornerRadius = 15
    }
    
    func firebaseGetData() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let userCollection = db.collection("users").document(user!.uid).collection(user!.email!)
        userCollection.addSnapshotListener { querySnapshot, error in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                
                if (querySnapshot?.documents) != nil {
                    let query = userCollection.whereField("CarbonEmission",  isGreaterThan: 0)
                    var totalAmount = 0.0
                    query.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Hata oluştu: \(error.localizedDescription)")
                        } else {
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let amount = data["CarbonEmission"] as? Double ?? 0
                                totalAmount += amount
                            }
                            self.totalCalculationLabel.text = "Total: \(String(format: "%.2f", totalAmount)) kg"
                        }
                    }
                    
                    self.requestManager.request( userCollection: userCollection, energyType: "Household") {
                        result in
                        self.houseHoldDataEntry.value = Double(String(format: "%.1f", result))!
                        self.pieChartUpdateData()
                    }
                    self.requestManager.request(userCollection: userCollection, energyType: "Transportation") {
                        result in
                        self.transportationDataEntry.value = Double(String(format: "%.1f", result))!
                        self.pieChartUpdateData()
                    }
                   
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.carArray) { double in
                        self.carDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.motorcycleArray) { double in
                        self.motorDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.busArray) { double in
                        self.busDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.planeArray) { double in
                        self.airPlaneDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.electricArray) { double in
                        self.electricDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    self.requestManager.requestChart(userCollection: userCollection, energyType: self.requestManager.warmArray) { double in
                        self.warmDataEntry.y = Double(String(format: "%.2f", double))!
                        self.barChartUpdate()
                    }
                    
                   
                }
            }
        }
    }
}
