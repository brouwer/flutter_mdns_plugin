import 'dart:typed_data';
import 'package:flutter/services.dart';

class ServiceInfo{
  final Map<String, Uint8List>? attr;
  final String name;
  final String type;
  final String hostName;
  final String address;
  final int port;

  ServiceInfo({this.attr, required this.name, required this.type, required this.hostName, required this.address, required this.port});

  static ServiceInfo fromMap(Map fromChannel){
    Map<String, Uint8List>? attr;
    String name = "";
    String type = "";
    String hostName = "";
    String address = "";
    int port = 0;

    if (fromChannel.containsKey("attr") ) {
      attr = Map<String, Uint8List>.from(fromChannel["attr"]);
    }

    if (fromChannel.containsKey("name") ) {
      name = fromChannel["name"];
    }

    if (fromChannel.containsKey("type")) {
      type = fromChannel["type"];
    }

    if (fromChannel.containsKey("hostName")) {
      hostName = fromChannel["hostName"];
    }

    if (fromChannel.containsKey("address")) {
      address = fromChannel["address"];
    }

    if (fromChannel.containsKey("port")) {
      port = fromChannel["port"];
    }

    return new ServiceInfo(attr: attr, name: name, type: type, hostName: hostName, address: address, port: port);
  }

  @override
  String toString(){
    return "Name: $name, Type: $type, HostName: $hostName, Address: $address, Port: $port";
  }
}
typedef void ServiceInfoCallback(ServiceInfo info);

typedef void IntCallback (int data);
typedef void VoidCallback();

class DiscoveryCallbacks{
  VoidCallback? onDiscoveryStarted;
  VoidCallback? onDiscoveryStopped;
  ServiceInfoCallback? onDiscovered;
  ServiceInfoCallback? onResolved;
  ServiceInfoCallback? onLost;

  DiscoveryCallbacks({
    this.onDiscoveryStarted,
    this.onDiscoveryStopped,
    this.onDiscovered,
    this.onResolved,
    this.onLost,
  });
}

class FlutterMdnsPlugin {
  static const String NAMESPACE = "pro.brouwer.mdns";

  static const MethodChannel _channel =
  const MethodChannel('flutter_mdns_plugin');

  final EventChannel _serviceDiscoveredChannel =
  const EventChannel("$NAMESPACE/discovered");

  final EventChannel _serviceResolvedChannel =
  const EventChannel("$NAMESPACE/resolved");

  final EventChannel _serviceLostChannel =
  const EventChannel("$NAMESPACE/lost");

  final EventChannel _discoveryRunningChannel =
  const EventChannel("$NAMESPACE/running");

  DiscoveryCallbacks? discoveryCallbacks;

  FlutterMdnsPlugin({this.discoveryCallbacks}){

    if ( discoveryCallbacks != null ) {
      //Configure all the discovery related callbacks and event channels
      _serviceResolvedChannel.receiveBroadcastStream().listen((data) {
        print("Service resolved ${data.toString()}");
        if (discoveryCallbacks!.onResolved != null) {
          discoveryCallbacks!.onResolved!(ServiceInfo.fromMap(data));
        }
      });

      _serviceDiscoveredChannel.receiveBroadcastStream().listen((data) {
        print("Service discovered ${data.toString()}");
        if (discoveryCallbacks!.onDiscovered != null) {
          discoveryCallbacks!.onDiscovered!(ServiceInfo.fromMap(data));
        }
      });

      _serviceLostChannel.receiveBroadcastStream().listen((data) {
        print("Service lost ${data.toString()}");
        if (discoveryCallbacks!.onLost != null) {
          discoveryCallbacks!.onLost!(ServiceInfo.fromMap(data));
        }
      });

      _discoveryRunningChannel.receiveBroadcastStream().listen((running) {
        print("Discovery Running? $running");
        if (running && discoveryCallbacks!.onDiscoveryStarted != null) {
          discoveryCallbacks!.onDiscoveryStarted!();
        } else if (discoveryCallbacks!.onDiscoveryStopped != null) {
          discoveryCallbacks!.onDiscoveryStopped!();
        }
      });
    }

  }

  startDiscovery(String serviceType) {
    Map args = new Map();
    args["serviceType"] = serviceType;
    _channel.invokeMethod("startDiscovery", args);
  }

  stopDiscovery(){
    _channel.invokeMethod("stopDiscovery", new Map());
  }

}
