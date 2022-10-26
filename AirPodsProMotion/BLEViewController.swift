//
//  ViewController.swift
//
//  I created ViewController with reference to the following repositories and articles.
//  GitHub          : https://github.com/tukuyo/AirPodsPro-Motion-Sampler
//  Article (Qiita) : https://qiita.com/tukutuku_tukuyo/items/ea949ee2dbb499d6e7ca
//

import UIKit
import CoreBluetooth
 
class BLEViewController: UIViewController, CBCentralManagerDelegate {
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.frame = CGRect(x: self.view.bounds.minX + (self.view.bounds.width / 10),
                            y: self.view.bounds.minY + (self.view.bounds.height / 6),
                            width: self.view.bounds.width, height: self.view.bounds.height)
        view.text = "Looking for AirPods Pro"
        view.font = view.font?.withSize(14)
        view.isEditable = false
        return view
    }()
 
    var centralManager: CBCentralManager!
 
    override func viewDidLoad() {
        // CentralManager 初期化
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        super.viewDidLoad()
        
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        centralManager.stopScan()
        print("Scanning stopped")
        
        super.viewWillDisappear(animated)
    }
    
    // CentralManager status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBManager is powered on")
            startScan()
        case .poweredOff:
            print("CBManager is not powered on")
            return
        case .resetting:
            print("CBManager is resetting")
        case .unauthorized:
            print("Unexpected authorization")
            return
        case .unknown:
            print("CBManager state is unknown")
            return
        case .unsupported:
            print("Bluetooth is not supported on this device")
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            return
        }
    }
    
    // begin to scan
    func startScan(){
        print("begin to scan ...")
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    // stop scan
    func stopBluetoothScan() {
        self.centralManager.stopScan()
    }
 
    // Peripheral探索結果を受信
    func centralManager(_ central: CBCentralManager,
                            didDiscover peripheral: CBPeripheral,
                            advertisementData: [String: Any],
                            rssi RSSI: NSNumber) {
     
            print("pheripheral.name: \(String(describing: peripheral.name))")
            print("advertisementData:\(advertisementData)")
            print("RSSI: \(RSSI)")
            print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)\n")
        }
 
}

