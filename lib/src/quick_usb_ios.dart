import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:quick_usb/src/common.dart';
import 'package:quick_usb/src/quick_usb_platform_interface.dart';

const MethodChannel _channel = MethodChannel('quick_usb');

class QuickUsbIOS extends QuickUsbPlatform {
  @override
  Future<bool> init() async {
    // iOS initialization is handled automatically by the system
    return true;
  }

  @override
  Future<void> exit() async {
    // iOS cleanup is handled automatically by the system
  }

  @override
  Future<List<UsbDevice>> getDeviceList() async {
    final List<dynamic> result = await _channel.invokeMethod('getDeviceList');
    return result.map((device) => UsbDevice.fromMap(device)).toList();
  }

  @override
  Future<List<UsbDeviceDescription>> getDevicesWithDescription({
    bool requestPermission = true,
  }) async {
    final devices = await getDeviceList();
    final descriptions = <UsbDeviceDescription>[];

    for (final device in devices) {
      try {
        final description = await getDeviceDescription(
          device,
          requestPermission: requestPermission,
        );
        descriptions.add(description);
      } catch (e) {
        // If we can't get description, create one with basic info
        descriptions.add(UsbDeviceDescription(device: device));
      }
    }

    return descriptions;
  }

  @override
  Future<UsbDeviceDescription> getDeviceDescription(
    UsbDevice usbDevice, {
    bool requestPermission = true,
  }) async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'getDeviceDescription',
      {'device': usbDevice.toMap(), 'requestPermission': requestPermission},
    );

    return UsbDeviceDescription.fromMap(result);
  }

  @override
  Future<bool> hasPermission(UsbDevice usbDevice) async {
    final bool result = await _channel.invokeMethod('hasPermission', {
      'identifier': usbDevice.identifier,
    });
    return result;
  }

  @override
  Future<void> requestPermission(UsbDevice usbDevice) async {
    await _channel.invokeMethod('requestPermission', {
      'identifier': usbDevice.identifier,
    });
  }

  @override
  Future<bool> openDevice(UsbDevice usbDevice) async {
    final bool result = await _channel.invokeMethod('openDevice', {
      'identifier': usbDevice.identifier,
    });
    return result;
  }

  @override
  Future<void> closeDevice() async {
    await _channel.invokeMethod('closeDevice');
  }

  @override
  Future<UsbConfiguration> getConfiguration(int index) async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'getConfiguration',
      {'index': index},
    );
    return UsbConfiguration.fromMap(result);
  }

  @override
  Future<bool> setConfiguration(UsbConfiguration config) async {
    final bool result = await _channel.invokeMethod('setConfiguration', {
      'index': config.index,
    });
    return result;
  }

  @override
  Future<bool> claimInterface(UsbInterface intf) async {
    final bool result = await _channel.invokeMethod('claimInterface', {
      'id': intf.id,
      'alternateSetting': intf.alternateSetting,
    });
    return result;
  }

  @override
  Future<bool> detachKernelDriver(UsbInterface intf) async {
    // iOS doesn't support kernel driver detachment
    return true;
  }

  @override
  Future<bool> releaseInterface(UsbInterface intf) async {
    final bool result = await _channel.invokeMethod('releaseInterface', {
      'id': intf.id,
      'alternateSetting': intf.alternateSetting,
    });
    return result;
  }

  @override
  Future<Uint8List> bulkTransferIn(
    UsbEndpoint endpoint,
    int maxLength,
    int timeout,
  ) async {
    final List<dynamic> result = await _channel.invokeMethod('bulkTransferIn', {
      'endpoint': endpoint.toMap(),
      'maxLength': maxLength,
      'timeout': timeout,
    });
    return Uint8List.fromList(result.cast<int>());
  }

  @override
  Future<int> bulkTransferOut(
    UsbEndpoint endpoint,
    Uint8List data,
    int timeout,
  ) async {
    final int result = await _channel.invokeMethod('bulkTransferOut', {
      'endpoint': endpoint.toMap(),
      'data': data,
      'timeout': timeout,
    });
    return result;
  }

  @override
  Future<void> setAutoDetachKernelDriver(bool enable) async {
    // iOS doesn't support kernel driver management
  }
}
