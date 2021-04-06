//
//  ViewController.swift
//  DOW v3
//
//  Created by Dan on 1/25/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var _characteristics: [CBCharacteristic]?

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
                    print("BLE powered on")
                    // Turned on
                    central.scanForPeripherals(withServices: nil, options: nil)
                }
                else {
                    print("Something wrong with BLE")
                    // Not on, but can have different issues
                }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let pname = peripheral.name {
            print(pname)
            if pname == "MLT-BT05" {
                    self.centralManager.stopScan()
                    
                    self.myPeripheral = peripheral
                    self.myPeripheral.delegate = self
             
                    self.centralManager.connect(peripheral, options: nil)
                    print("Connected to MLT-BT05")
                }
            }
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            
            for service in services {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           guard let characteristics = service.characteristics else { return }
           
           for characteristic in characteristics {
               print(characteristic)
               if characteristic.properties.contains(.read) {
                   print("\(characteristic.uuid): properties contain .read")
                   peripheral.readValue(for: characteristic)
               }
               if characteristic.properties.contains(.notify) {
                   print("\(characteristic.uuid): properties contains .notify")
                   peripheral.setNotifyValue(true, for: characteristic)
               }
           }
       }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error: \(error)")
        }
        else {
            print("isNotifying: \(characteristic.isNotifying)")
        }
    }
    private func displayData(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        return "Char UUID: \(characteristic.uuid)" + String(byte)
    }
    
    @IBOutlet weak var lights: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }


    
    @IBAction func armfordarkness2(_ sender: Any) {
        print("Armed")
        lights.image = UIImage(named: "state2")

        //send serial command "1" via BLE to peripheral here
    }
    
    @IBAction func armedsafetyoff(_ sender: Any) {
        print("Armed for Day and Night")
        lights.image = UIImage(named: "state3")
        
        //send serial command "2" via BLE to peripheral here
    }
    
    @IBAction func fire(_ sender: Any) {
        print("Fire!")
        lights.image = UIImage(named: "state4")
        
        //send serial command "3" via BLE to peripheral here
    }
    
    
    @IBAction func disarm(_ sender: Any) {
        print("Disarmed")
        lights.image = UIImage(named: "state1")
        
        //send serial command "4" via BLE to peripheral here
        
    }
}

