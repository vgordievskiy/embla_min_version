library BMSrv.BasedOnGoogle.ImageService;
import 'dart:async';
import 'dart:io';
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis/common/common.dart' show DownloadOptions, Media;
import 'package:dart_orm/dart_orm.dart' as ORM;
import 'package:redstone/server.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';

final scopes = [storage.StorageApi.DevstorageFullControlScope];

@app.Group("/public/images")
class ImageService {
  final log = new Logger("BMSrv.Services.ImageService");
  
  auth.ServiceAccountCredentials accountCredentials = null;
  auth.AuthClient Client;
  
  storage.StorageApi storageClient;
  
  ImageService()
  {
    File file = new File('bin/credentials.json');
    
    file.readAsString().then((String cont){
      accountCredentials = new auth.ServiceAccountCredentials.fromJson(cont);
      connect().then((_) => test());
    });
  }
  
  Future connect() async {
    try {
      Client  =  await auth_io.clientViaServiceAccount(accountCredentials, scopes);
      storageClient = new storage.StorageApi(Client);
    } catch (error) {
      log.warning(error);
    }
  }
  
  test() async {
    var options = DownloadOptions.FullMedia;
    storage.Objects tmp = await storageClient.objects.list('semplex');
    
  }
  
}