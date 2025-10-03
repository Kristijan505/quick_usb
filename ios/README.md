# iOS USB Support for Quick USB Plugin

This directory contains the iOS implementation of the Quick USB plugin, providing USB device communication capabilities for iOS applications.

## Requirements

- **iOS 12.0+** (minimum deployment target)
- **Xcode 12.0+**
- **Swift 5.0+**

## iOS-Specific Considerations

### MFi Program Requirements

iOS USB support requires compliance with Apple's **Made for iPhone (MFi) Program**:

1. **Hardware Certification**: USB devices must be MFi certified
2. **Protocol Registration**: Device protocols must be registered in your app's `Info.plist`
3. **Developer Program**: You may need to join Apple's MFi Developer Program

### Info.plist Configuration

Add the following to your app's `Info.plist`:

```xml
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.yourcompany.yourprotocol</string>
    <!-- Add your device's supported protocols here -->
</array>
```

### Supported Frameworks

The iOS implementation uses:
- **ExternalAccessory**: For MFi-certified USB accessories
- **Foundation**: For basic iOS functionality

## Implementation Details

### Device Discovery
- Uses `EAAccessoryManager.shared().connectedAccessories` to discover devices
- Automatically handles MFi-certified accessories
- Provides device information including manufacturer, product name, and serial number

### Data Transfer
- Implements bulk transfer operations using `EASession`
- Supports both input and output data streams
- Handles protocol-specific communication

### Limitations
- Only works with MFi-certified devices
- No direct USB configuration management (handled by iOS)
- Kernel driver management not applicable on iOS

## Testing

To test the iOS implementation:

1. Connect an MFi-certified USB device
2. Ensure the device protocol is registered in `Info.plist`
3. Run your Flutter app on a physical iOS device
4. Use the plugin's API to discover and communicate with the device

## Troubleshooting

### Common Issues

1. **No devices found**: Ensure the USB device is MFi-certified and connected
2. **Permission denied**: Check `Info.plist` protocol configuration
3. **Connection failed**: Verify device compatibility and MFi certification

### Debug Tips

- Use Xcode's External Accessory framework debugging tools
- Check device logs for External Accessory framework messages
- Verify protocol strings match between device and app configuration

## Future Enhancements

With iOS 26's enhanced USB support, future versions may include:
- Direct USB device access (non-MFi)
- Enhanced protocol support
- Improved error handling and diagnostics
