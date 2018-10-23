//
//  MainViewController.swift
//  iBeacon
//
//  Created by Seth Bailey on 9/21/18.
//  Copyright © 2018 Seth Bailey. All rights reserved.
//

import UIKit
import CoreLocation
let storedItemsK = "storedItems"

class MainViewController: UIViewController {

    var items = [IBeaconItem]()

    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var distanceImage: UIImageView!
    @IBOutlet weak var throwLabel: UILabel!
    @IBOutlet weak var nameBeacon: UILabel!
    @IBOutlet weak var distanceBeacon: UILabel!
    @IBOutlet weak var throwBeacon: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        throwLabel?.text = "Throws: "
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        loadItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadItems() {
        print("Loading items")
        guard let storedItems = UserDefaults.standard.array(forKey: storedItemsK) as? [Data] else { return }
        for itemData in storedItems {
            guard let item = NSKeyedUnarchiver.unarchiveObject(with: itemData) as? IBeaconItem else { continue }
            items.append(item)
            startMonitoringItem(item)
            print("In found item")
            nameBeacon?.text = item.name;
            distanceBeacon?.text = item.locationString();
            throwBeacon?.text = String(item.throwsValue);
            
        }
    }
    
    func startMonitoringItem(_ item: IBeaconItem) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    func stopMonitoringItem(_ item: IBeaconItem) {
        let beaconRegion = item.asBeaconRegion()
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        // Find the same beacons in the table.
        var indexPaths = [IndexPath]()
        for beacon in beacons {
            for row in 0..<items.count {
                if items[row] == beacon {
                    print("Beacon Found")
                    items[row].beacon = beacon
                    indexPaths += [IndexPath(row: row, section: 0)]
                    distanceBeacon?.text = items[row].locationString()
                    distanceImage.image = UIImage(named: items[row].locationImage())
                    if(items[row].didThrow(lastvalue: items[row].lastDistance)){
                        items[row].throwsValue += 1
                        throwLabel?.text = "\(items[row].throwsValue)"
                        print("Threw IBeacon")
                    }
                    items[row].lastDistance = items[row].accuracyDistance()
                }

            }
        }

//        // Update beacon locations of visible rows.
//        if let visibleRows = tableView.indexPathsForVisibleRows {
//            let rowsToUpdate = visibleRows.filter { indexPaths.contains($0) }
//            for row in rowsToUpdate {
//                let cell = tableView.cellForRow(at: row) as! IBeaconCell
//                cell.refreshLocation()
//            }
//        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}

