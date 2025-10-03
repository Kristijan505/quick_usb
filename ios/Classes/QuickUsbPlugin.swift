import Flutter
import UIKit
import ExternalAccessory

public class QuickUsbPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "quick_usb", binaryMessenger: registrar.messenger())
    let instance = QuickUsbPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private var currentSession: EASession?
  private var accessoryManager = EAAccessoryManager.shared()

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceList":
      getDeviceList(result: result)
    case "getDeviceDescription":
      getDeviceDescription(call: call, result: result)
    case "hasPermission":
      hasPermission(call: call, result: result)
    case "requestPermission":
      requestPermission(call: call, result: result)
    case "openDevice":
      openDevice(call: call, result: result)
    case "closeDevice":
      closeDevice(result: result)
    case "getConfiguration":
      getConfiguration(call: call, result: result)
    case "setConfiguration":
      setConfiguration(call: call, result: result)
    case "claimInterface":
      claimInterface(call: call, result: result)
    case "releaseInterface":
      releaseInterface(call: call, result: result)
    case "bulkTransferIn":
      bulkTransferIn(call: call, result: result)
    case "bulkTransferOut":
      bulkTransferOut(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Device Management
  
  private func getDeviceList(result: @escaping FlutterResult) {
    let accessories = accessoryManager.connectedAccessories
    let deviceList = accessories.map { accessory in
      return [
        "identifier": accessory.connectionID,
        "vendorId": 0, // EAAccessory doesn't expose vendor ID directly
        "productId": 0, // EAAccessory doesn't expose product ID directly
        "configurationCount": 1, // iOS typically has single configuration
        "manufacturer": accessory.manufacturer,
        "product": accessory.name,
        "serialNumber": accessory.serialNumber
      ] as [String: Any]
    }
    result(deviceList)
  }

  private func getDeviceDescription(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let deviceId = args["device"] as? [String: Any],
          let identifier = deviceId["identifier"] as? Int else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid device identifier", details: nil))
      return
    }

    let accessories = accessoryManager.connectedAccessories
    guard let accessory = accessories.first(where: { $0.connectionID == identifier }) else {
      result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
      return
    }

    let description = [
      "manufacturer": accessory.manufacturer,
      "product": accessory.name,
      "serialNumber": accessory.serialNumber
    ] as [String: Any]
    result(description)
  }

  private func hasPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let identifier = args["identifier"] as? Int else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid identifier", details: nil))
      return
    }

    let accessories = accessoryManager.connectedAccessories
    let hasAccess = accessories.contains { $0.connectionID == identifier }
    result(hasAccess)
  }

  private func requestPermission(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // On iOS, permissions are handled through MFi program and Info.plist
    // This is more of a placeholder - actual permission handling depends on MFi setup
    result(nil)
  }

  // MARK: - Device Connection
  
  private func openDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let identifier = args["identifier"] as? Int else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid identifier", details: nil))
      return
    }

    let accessories = accessoryManager.connectedAccessories
    guard let accessory = accessories.first(where: { $0.connectionID == identifier }) else {
      result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
      return
    }

    // Create session for the accessory
    // Note: Protocol string needs to be defined in Info.plist and supported by accessory
    if let protocolString = accessory.protocolStrings.first {
      currentSession = EASession(accessory: accessory, forProtocol: protocolString)
      result(currentSession != nil)
    } else {
      result(FlutterError(code: "NO_PROTOCOL", message: "No supported protocol found", details: nil))
    }
  }

  private func closeDevice(result: @escaping FlutterResult) {
    currentSession?.inputStream?.close()
    currentSession?.outputStream?.close()
    currentSession = nil
    result(nil)
  }

  // MARK: - Configuration Management
  
  private func getConfiguration(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // iOS External Accessory framework doesn't expose USB configurations directly
    // Return a default configuration
    let config = [
      "id": 1,
      "index": 0,
      "interfaces": [
        [
          "id": 0,
          "alternateSetting": 0,
          "endpoints": [
            [
              "endpointNumber": 1,
              "direction": 0x80 // IN direction
            ],
            [
              "endpointNumber": 1,
              "direction": 0x00 // OUT direction
            ]
          ]
        ]
      ]
    ] as [String: Any]
    result(config)
  }

  private func setConfiguration(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // iOS handles configuration automatically through MFi
    result(true)
  }

  // MARK: - Interface Management
  
  private func claimInterface(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // iOS External Accessory handles interface claiming automatically
    result(true)
  }

  private func releaseInterface(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // iOS External Accessory handles interface release automatically
    result(true)
  }

  // MARK: - Data Transfer
  
  private func bulkTransferIn(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let maxLength = args["maxLength"] as? Int,
          let timeout = args["timeout"] as? Int,
          let session = currentSession,
          let inputStream = session.inputStream else {
      result(FlutterError(code: "INVALID_SESSION", message: "No active session or input stream", details: nil))
      return
    }

    // Read data from the accessory
    var buffer = Data(count: maxLength)
    let bytesRead = buffer.withUnsafeMutableBytes { bytes in
      inputStream.read(bytes.bindMemory(to: UInt8.self).baseAddress!, maxLength: maxLength)
    }

    if bytesRead > 0 {
      let data = buffer.prefix(bytesRead)
      result(Array(data))
    } else {
      result(FlutterError(code: "TRANSFER_FAILED", message: "Bulk transfer failed", details: nil))
    }
  }

  private func bulkTransferOut(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let data = args["data"] as? FlutterStandardTypedData,
          let timeout = args["timeout"] as? Int,
          let session = currentSession,
          let outputStream = session.outputStream else {
      result(FlutterError(code: "INVALID_SESSION", message: "No active session or output stream", details: nil))
      return
    }

    // Write data to the accessory
    let bytesWritten = data.data.withUnsafeBytes { bytes in
      outputStream.write(bytes.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.data.count)
    }

    if bytesWritten > 0 {
      result(bytesWritten)
    } else {
      result(FlutterError(code: "TRANSFER_FAILED", message: "Bulk transfer failed", details: nil))
    }
  }
}
