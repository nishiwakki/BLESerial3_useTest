import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    // プロトコルとプロパティ定義
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var centralManagerReady: Bool = false // (1)
    var peripheralReady: Bool = false // (10)
    
    // MARK: - IBOutlet 表示
    
    @IBOutlet weak var SSIDUILabel: UILabel!
    
    // MARK: - IBAction ボタン等
    

    @IBAction func F1button(_ sender: Any) {
        pushBtn(0x01)
    }
    
    @IBAction func F2button(_ sender: Any) {
        pushBtn(0x02)
    }
    
    @IBAction func F3button(_ sender: Any) {
        pushBtn(0x03)
    }
    
    @IBAction func F4button(_ sender: Any) {
        pushBtn(0x04)
    }
    
    @IBAction func F5button(_ sender: Any) {
        pushBtn(0x05)
    }
    
    @IBAction func F6button(_ sender: Any) {
        pushBtn(0x06)
    }
    
    @IBAction func F7button(_ sender: Any) {
        pushBtn(0x07)
    }
    
    @IBAction func F8button(_ sender: Any) {
        pushBtn(0x08)
    }
    
    @IBAction func F9button(_ sender: Any) {
        pushBtn(0x09)
    }
    
    @IBAction func F10button(_ sender: Any) {
        pushBtn(0x0A)
    }
    
    @IBAction func F11button(_ sender: Any) {
        pushBtn(0x0B)
    }
    
    @IBAction func F12button(_ sender: Any) {
        pushBtn(0x0C)
    }
    
    @IBAction func PlayPausebutton(_ sender: Any) {
        pushBtn(0x0D)
    }
    
    @IBAction func Weakbutton(_ sender: Any) {
        pushBtn(0x0E)
    }
    
    @IBAction func Strongbutton(_ sender: Any) {
        pushBtn(0x0F)
    }
    
    @IBAction func Cbutton(_ sender: Any) {
        pushBtn(0x10)
    }
    
    @IBAction func Dbutton(_ sender: Any) {
        pushBtn(0x11)
    }
    
    @IBAction func Ebutton(_ sender: Any) {
        pushBtn(0x12)
    }
    
    @IBAction func Fbutton(_ sender: Any) {
        pushBtn(0x13)
    }
    
    @IBAction func Gbutton(_ sender: Any) {
        pushBtn(0x14)
    }
    
    @IBAction func Abutton(_ sender: Any) {
        pushBtn(0x15)
    }
    
    @IBAction func Bbutton(_ sender: Any) {
        pushBtn(0x16)
    }
    
    @IBAction func C2button(_ sender: Any) {
        pushBtn(0x17)
    }
    
    
    // connectボタンが押されたとき
    @IBAction func connectBtnTapped(_ sender: Any) {
        // セントラルマネージャが起動していないとき
        if self.centralManagerReady == false {
            reStart()
            return
        }
        // 起動していたとき (2)
        self.scanBLESerial3();
    }
    
    // MARK: - CBCentralManagerDelegate記述
    
    // セントラルマネージャの状態変化取得。この場合はスマホがセントラル（変化するたびに呼び出される）CBCentralManagerの初期化必須
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")
        
        switch central.state {
        case .poweredOff: // BLEがオフ
            print("電源Off")
            self.centralManagerReady = false
            break
        case .poweredOn: // BLEがオン アドバタイズの開始
            print("電源On")
            // BLEデバイスの検出を開始したときにtrueにする (1)
            self.centralManagerReady = true
            break
        default:
            break
        }
    }
    
    // スキャンを行い、BLESerial3（ペリフェラル）が検出された際に呼び出される。 (4)
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("finding peripheral: \(peripheral)")
        self.centralManager.stopScan()
        self.connectPeripheral(peripheral: peripheral)
    }
    
    // BLESerial3（ペリフェラル）に接続成功すると呼び出される (6-A)
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connecting BLE: \(peripheral)")
        self.SSIDUILabel.text = peripheral.name
        self.scanService()
    }
    
    // BLESerial3（ペリフェラル）に接続失敗すると呼び出される (6-B)
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("not connecting peripheral: \(peripheral)")
    }
    
    
    // MARK: - CBPeripheralDelegate Delegate記述
    
    // サービス発見時に呼び出される (8)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let service: CBService = peripheral.services![0]
        self.scanCharacteristics(service)
    }
    
    // キャラクタリスティックスを発見すると呼び出される。データの書き込み要求を行う (10)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristic: CBCharacteristic = service.characteristics![0]
        self.characteristic = characteristic
        
        peripheralReady = true
    }
    
    // MARK: - メソッドの記述
    
    // BLESerial3(ペリフェラル)を見つけるためのメソッド (3)
    func scanBLESerial3() {
        let BLESerial3UUID: [CBUUID] = [CBUUID.init(string: "FEED0001-C497-4476-A7ED-727DE7648AB1")]
        self.centralManager?.scanForPeripherals(withServices: BLESerial3UUID, options: nil)
    }
    
    // BLESerial3(見つけたペリフェラル)に繋げるためのメソッド (5)
    func connectPeripheral(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    // 見つけたペリフェラルが持っているサービスを検索し登録 (7)
    func scanService() {
        self.peripheral.delegate = self
        let TXCBUUID: [CBUUID] = [CBUUID.init(string: "FEED0001-C497-4476-A7ED-727DE7648AB1")] // 必要とするサービスのuuid
        self.peripheral.discoverServices(TXCBUUID)// uuidを指定しサービスを検索する
    }
    
    // 見つけたサービスが持っている書き込み用のキャラクタリスティックを検索し登録 (9)
    func scanCharacteristics(_ service: CBService) {
        let characteristics: [CBUUID] = [CBUUID.init(string: "FEEDAA02-C497-4476-A7ED-727DE7648AB1")] // tx
        self.peripheral.discoverCharacteristics(characteristics, for: service)
    }
    
    // CBCentralManagerを初期化する
    func reStart(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // ボタンを押された時の処理
    func pushBtn(_ num: UInt8){
        if self.peripheralReady == false {
            return
        }
        var val: UInt8 = num
        let data: NSData = NSData.init(bytes: &val, length: 1)
        self.peripheral.writeValue(data as Data, for: self.characteristic, type: .withoutResponse)
    }
    
    // MARK: - LifeCycle記述
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
