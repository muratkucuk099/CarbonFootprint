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
    var motorDataEntry = BarChartDataEntry(x: 3, y: 20, icon: UIImage(named: "moto"))
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
        guard let iconImage = UIImage(named: "motob") else { return }
        let size = CGSize(width: 32, height: 32) // Boyutu buradan ayarlayabilirsiniz
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedIcon = renderer.image { _ in
            iconImage.draw(in: CGRect(origin: .zero, size: size))
        }
        motorDataEntry.icon = resizedIcon
       
        //motorDataEntry.icon.
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
        let userCollection = requestManager.getUserCollection()
        userCollection.addSnapshotListener { [self] querySnapshot, error in
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.requestManager.requestTotal() { total in
                self.stopLoading()
                self.totalCalculationLabel.text = "Total: \(String(format: "%.2f", total)) kg"
            }
            self.requestManager.request(energyType: "Household") {
                result in
                self.houseHoldDataEntry.value = Double(String(format: "%.1f", result))!
                self.pieChartUpdateData()
            }
            self.requestManager.request(energyType: "Transportation") {
                result in
                self.transportationDataEntry.value = Double(String(format: "%.1f", result))!
                self.pieChartUpdateData()
            }
            let entryDicts = [
                requestManager.carArray: carDataEntry,
                requestManager.motorcycleArray: motorDataEntry,
                requestManager.busArray: busDataEntry,
                requestManager.planeArray: airPlaneDataEntry,
                requestManager.electricArray: electricDataEntry,
                requestManager.warmArray: warmDataEntry
            ]
            for entryDict in entryDicts{
                requestManager.requestChart(generalType: entryDict.key) { double in
                    entryDict.value.y = Double(String(format: "%.2f", double))!
                    self.barChartUpdate()
                }
            }
        }
    }
}
extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }
}




