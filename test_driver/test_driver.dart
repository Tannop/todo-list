/// integration_test_driver.dart
/// 14/02/23
/// gets called by the integration tests and invokes or enables location/wifi/perms

/// Call adb as Android/Sdk/platform-tools/adb.exe on Windows and Android/Sdk/platform-tools/adb
/// on Ubuntu

import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

// void main() => integrationDriver();

Future<void> main() async {
  print("Starting integration test: ");
  final Map<String, String> envVars = Platform.environment;
  //print('evnVars = $envVars');

  //directory to the adb.exe of local device
  String nonnull = "";
  String? frontp = envVars['LOCALAPPDATA'];
  if (frontp != null) nonnull = frontp;
  String adbPath = nonnull + '/Android/Sdk/platform-tools/adb.exe'; //Windows
  if (envVars['USER'] == "ubuntu") {
    //bad idea but we test on ubuntu as ubuntu
    frontp = envVars['HOME'];
    if (frontp != null) nonnull = frontp;
    adbPath = nonnull + "/Android/Sdk/platform-tools/adb";
  }
  await integrationDriver();
}
