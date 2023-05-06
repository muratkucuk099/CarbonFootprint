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
import UserNotifications

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var totalCalculationLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    let transportationDataEntry = PieChartDataEntry(value: 10, icon: UIImage(systemName: "car"))
    let houseHoldDataEntry = PieChartDataEntry(value: 10, icon: UIImage(systemName: "house"))
    let carDataEntry = BarChartDataEntry(x: 1, y: 20, icon: UIImage(systemName: "car.side"))
    let motorDataEntry = BarChartDataEntry(x: 3, y: 20, icon: UIImage(systemName: "bicycle"))
    let busDataEntry = BarChartDataEntry(x: 2, y: 20, icon: UIImage(systemName: "bus.fill"))
    let airPlaneDataEntry = BarChartDataEntry(x: 4, y: 20, icon: UIImage(systemName: "airplane"))
    let electricDataEntry = BarChartDataEntry(x : 5, y: 20, icon: UIImage(systemName: "bolt"))
    let warmDataEntry = BarChartDataEntry(x: 6, y: 20, icon: UIImage(systemName: "flame"))
    
    var pieNumberofDataEntry = [PieChartDataEntry]()
    var barNumberofDataEntry = [BarChartDataEntry]()
    var entries: [BarChartDataEntry] = []
    
    let requestManager = RequestManager()
    let treemanager = TreeRequest()
    let notification = PushNotification()
    override func viewDidLoad() {
        super.viewDidLoad()
        notification.notification()
        entries = [
            carDataEntry,
            busDataEntry,
            motorDataEntry,
            airPlaneDataEntry,
            electricDataEntry,
            warmDataEntry
        ]
        startLoading()
        pieChartView.chartDescription.text = ""
        barNumberofDataEntry = [carDataEntry]
        pieNumberofDataEntry = [transportationDataEntry, houseHoldDataEntry]
        firebaseGetData()
    }
    
    func startLoading() {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
    }
    func stopLoading() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    func barChartUpdate() {
        let dataSet = BarChartDataSet(entries: entries, label: "")
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
        dataSet.colors = [ UIColor(red: 38/255, green: 79/255, blue: 71/255, alpha: 1), UIColor(red: 38/255, green: 79/255, blue: 71/255, alpha: 1),  UIColor(red: 38/255, green: 79/255, blue: 71/255, alpha: 1), UIColor(red: 38/255, green: 79/255, blue: 71/255, alpha: 1), UIColor(red: 95/255, green: 176/255, blue: 68/255, alpha: 1), UIColor(red: 95/255, green: 176/255, blue: 68/255, alpha: 1),]
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelCount = entries.count
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["", "Car", "Bus", "Bike", "Plane", "Electric", "Warm"])
        barChartView.leftAxis.axisMinimum = 0
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        barChartView.layer.borderWidth = 2
        barChartView.layer.cornerRadius = 15
    }
    
    func pieChartUpdateData(){
        let chartDataSet = PieChartDataSet(entries: pieNumberofDataEntry, label: "")
        chartDataSet.iconsOffset = CGPoint(x: 10,y: 0)
        let charData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor(red: 38/255, green: 79/255, blue: 71/255, alpha: 1), UIColor(red: 95/255, green: 176/255, blue: 68/255, alpha: 1)]
        chartDataSet.colors = colors
        pieChartView.data = charData
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
    
    func firebaseGetData() {
        guard let user = Auth.auth().currentUser else {
            print("Current user not found.")
            return
        }
        let db = Firestore.firestore()
        let userCollection = db.collection("users").document(user.uid).collection(user.email!)
        userCollection.addSnapshotListener { querySnapshot, error in
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.requestManager.requestTotal(userCollection: userCollection) { total in
                self.stopLoading()
                self.totalCalculationLabel.text = "Total: \(String(format: "%.2f", total)) kg"
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
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.carArray) { double in
                self.carDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.motorcycleArray) { double in
                self.motorDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.busArray) { double in
                self.busDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.planeArray) { double in
                self.airPlaneDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.electricArray) { double in
                self.electricDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
            self.requestManager.requestChart(userCollection: userCollection, generalType: self.requestManager.warmArray) { double in
                self.warmDataEntry.y = Double(String(format: "%.2f", double))!
                self.barChartUpdate()
            }
        }
    }
}




