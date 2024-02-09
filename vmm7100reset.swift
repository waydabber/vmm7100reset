//
//  vmm7100reset.swift
//
//  Created by @waydabber
//
//  Adapted from https://github.com/djrobx/USBResetter

import Foundation
import IOKit.usb

guard VMM7100.reset() else {
  print("VMM7100 reset failed.")
  exit(EXIT_FAILURE)
}

enum VMM7100 {
  // From IOUSBLib.h as #define

  static let kIOUSBDeviceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                   0x9D, 0xC7, 0xB7, 0x80, 0x9E, 0xC0, 0x11, 0xD4,
                                                                                   0xA5, 0x4F, 0x00, 0x0A, 0x27, 0x05, 0x28, 0x61)

  static let kIOCFPlugInInterfaceID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                             0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
                                                                             0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)

  static let kIOUSBInterfaceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                      0x2D, 0x97, 0x86, 0xC6, 0x9E, 0xF3, 0x11, 0xD4,
                                                                                      0xAD, 0x51, 0x00, 0x0A, 0x27, 0x05, 0x28, 0x61)

  // From IOUSBLib.h as #define

  static let kIOUSBDeviceInterfaceID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                              0x5C, 0x81, 0x87, 0xD0, 0x9E, 0xF3, 0x11, 0xD4,
                                                                              0x8B, 0x45, 0x00, 0x0A, 0x27, 0x05, 0x28, 0x61)

  static let kIOUSBInterfaceInterfaceID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                 0x73, 0xC9, 0x7A, 0xE8, 0x9E, 0xF3, 0x11, 0xD4,
                                                                                 0xB1, 0xD0, 0x00, 0x0A, 0x27, 0x05, 0x28, 0x61)

  // VMM7100 device identifiers

  static var vendorID: Int32 = 0x06CB
  static var productID: Int32 = 0x7100

  // VMM7100 reset data packets

  static let resetDataPackets: [[UInt8]] = [
    [
      0x01, 0x00, 0x11, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05,
      0x00, 0x00, 0x00, 0x50, 0x52, 0x49, 0x55, 0x53, 0xD6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00,
    ],
    [
      0x01, 0x00, 0x0C, 0x00, 0x00, 0xB1, 0x00, 0x2C, 0x02, 0x20, 0x20, 0x04,
      0x00, 0x00, 0x00, 0xD1, 0x20, 0x00, 0x71, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00,
    ],
    [
      0x01, 0x00, 0x10, 0x00, 0x00, 0xA1, 0x00, 0x1C, 0x02, 0x20, 0x20, 0x04,
      0x00, 0x00, 0x00, 0xF5, 0x00, 0x00, 0x00, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00,
    ],
  ]

  static func getDeviceIterator() -> io_iterator_t {
    var deviceIterator = io_iterator_t()
    let dictionary = NSMutableDictionary()
    dictionary.setValue(kIOUSBDeviceClassName, forKey: kIOProviderClassKey)
    dictionary.setValue(vendorID, forKey: kUSBVendorID)
    dictionary.setValue(productID, forKey: kUSBProductID)
    IOServiceGetMatchingServices(kIOMainPortDefault, dictionary as CFDictionary, &deviceIterator)
    return deviceIterator
  }

  static func devicePresent() -> Bool {
    let deviceIterator = Self.getDeviceIterator()
    defer {
      IOObjectRelease(deviceIterator)
    }
    let deviceObject = IOIteratorNext(deviceIterator)
    defer {
      IOObjectRelease(deviceObject)
    }
    guard deviceObject != 0 else {
      return false
    }
    print("VMM7100 - device present")
    return true
  }

  static func getNextDevice(deviceIterator: io_iterator_t) -> (device: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, deviceInterface: IOUSBDeviceInterface)? {
    var devicePlugin: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
    var device: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
    var score: Int32 = 0

    let deviceObject = IOIteratorNext(deviceIterator)
    defer {
      IOObjectRelease(deviceObject)
    }
    guard deviceObject != 0 else {
      return nil
    }
    let createPlugInInterfaceForServiceReturn = IOCreatePlugInInterfaceForService(deviceObject, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &devicePlugin, &score)
    guard createPlugInInterfaceForServiceReturn == kIOReturnSuccess else {
      print("VMM7100 - Unable to create plugin interface for device")
      return nil
    }
    defer {
      IODestroyPlugInInterface(devicePlugin)
    }
    guard let devicePluginInterface = devicePlugin?.pointee?.pointee else {
      print("VMM7100 - Unable to get plugin interface for device")
      return nil
    }
    let queryInterfaceReturn = withUnsafeMutablePointer(to: &device) {
      $0.withMemoryRebound(to: LPVOID?.self, capacity: 1) {
        devicePluginInterface.QueryInterface(
          devicePlugin,
          CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
          $0
        )
      }
    }
    guard queryInterfaceReturn == kIOReturnSuccess, let deviceInterface = device?.pointee?.pointee else {
      print("VMM7100 - Unable to get or query device")
      return nil
    }
    return (device: device, deviceInterface: deviceInterface)
  }

  static func getNextInterface(interfaceIterator: inout io_iterator_t, device: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?, deviceInterface: IOUSBDeviceInterface) -> (interface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface>?>?, interfaceInterface: IOUSBInterfaceInterface)? {
    var interfacePlugin: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
    var interface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface>?>?
    var score: Int32 = 0

    var interfaceRequest = IOUSBFindInterfaceRequest()
    interfaceRequest.bInterfaceClass = UInt16(kIOUSBFindInterfaceDontCare)
    interfaceRequest.bInterfaceSubClass = UInt16(kIOUSBFindInterfaceDontCare)
    interfaceRequest.bInterfaceProtocol = UInt16(kIOUSBFindInterfaceDontCare)
    interfaceRequest.bAlternateSetting = UInt16(kIOUSBFindInterfaceDontCare)

    let createInterfaceIteratorReturn = deviceInterface.CreateInterfaceIterator(device, &interfaceRequest, &interfaceIterator)
    guard createInterfaceIteratorReturn == kIOReturnSuccess else {
      print("VMM7100 - Unable to create interface iterator for interface")
      return nil
    }

    let interfaceObject = IOIteratorNext(interfaceIterator)
    defer {
      IOObjectRelease(interfaceObject)
    }
    let createPlugInInterfaceForServiceInterfaceReturn = IOCreatePlugInInterfaceForService(interfaceObject, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &interfacePlugin, &score)
    guard createPlugInInterfaceForServiceInterfaceReturn == kIOReturnSuccess else {
      print("VMM7100 - Unable to create plugin interface for interface", createPlugInInterfaceForServiceInterfaceReturn)
      return nil
    }
    defer {
      IODestroyPlugInInterface(interfacePlugin)
    }
    guard let interfacePluginInterface = interfacePlugin?.pointee?.pointee else {
      print("VMM7100 - Unable to get plugin interface for interface")
      return nil
    }
    let interfaceQueryInterfaceReturn = withUnsafeMutablePointer(to: &interface) {
      $0.withMemoryRebound(to: LPVOID?.self, capacity: 1) {
        interfacePluginInterface.QueryInterface(
          interfacePlugin,
          CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID),
          $0
        )
      }
    }
    guard interfaceQueryInterfaceReturn == kIOReturnSuccess, let interfaceInterface = interface?.pointee?.pointee else {
      print("VMM7100 - Unable to get or query device interface")
      return nil
    }
    let interfaceOpenReturn = interfaceInterface.USBInterfaceOpen(interface)
    guard interfaceOpenReturn == kIOReturnSuccess else {
      if interfaceOpenReturn == kIOReturnExclusiveAccess {
        print("VMM7100 - Unable to gain access")
      } else {
        print("VMM7100 - Unable to open device")
      }
      return nil
    }

    return (interface: interface, interfaceInterface: interfaceInterface)
  }

  static func reset() -> Bool {
    var success = false

    let deviceIterator = Self.getDeviceIterator()
    defer {
      IOObjectRelease(deviceIterator)
    }
    deviceWhile: while let (device: device, deviceInterface: deviceInterface) = getNextDevice(deviceIterator: deviceIterator) {
      defer {
        _ = deviceInterface.Release(device)
      }
      var interfaceIterator = io_iterator_t()
      defer {
        IOObjectRelease(interfaceIterator)
      }
      if let (interface, interfaceInterface) = getNextInterface(interfaceIterator: &interfaceIterator, device: device, deviceInterface: deviceInterface) {
        defer {
          _ = interfaceInterface.Release(interface)
        }
        var i = 1
        for data in Self.resetDataPackets {
          sleep(i == 1 ? 0 : 1)
          let dataPtr = UnsafeMutableRawPointer.allocate(byteCount: data.count, alignment: 1)
          defer {
            dataPtr.deallocate()
          }
          dataPtr.copyMemory(from: data, byteCount: data.count)
          var request = IOUSBDevRequest(
            bmRequestType: 0x21,
            bRequest: 0x9,
            wValue: 0x0201,
            wIndex: 0,
            wLength: UInt16(data.count - 1),
            pData: dataPtr,
            wLenDone: 0
          )
          let controlRequestReturn = interfaceInterface.ControlRequest(interface, 0, &request)
          guard controlRequestReturn == kIOReturnSuccess else {
            print("VMM7100 - Unable to send control request \(i)")
            continue deviceWhile
          }
          i += 1
        }
        success = true
      }
    }
    return success
  }
}
