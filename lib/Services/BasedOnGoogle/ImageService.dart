library BMSrv.BasedOnGoogle.ImageService;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart' as auth_io;
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis/common/common.dart' show DownloadOptions, Media;
import 'package:redstone/server.dart' as app;
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Services/RealEstateService.dart';

final scopes = [storage.StorageApi.DevstorageFullControlScope];

@app.Group("/realestate/:type/:id/rooms/:roomid/images")
class ImageService { 
  final log = new Logger("BMSrv.Services.ImageService");
  final String contentType = "image/jpeg";
  final String bucket = "semplex";
  final String googleBaseUrl = "http://storage.googleapis.com";
  
  Uuid _Generator = new Uuid();
  
  RealEstateService _estateSrv;
  
  auth.ServiceAccountCredentials accountCredentials = null;
  auth.AuthClient Client;
  
  storage.StorageApi storageClient;
  
  ImageService(RealEstateService this._estateSrv)
  {
    File file = new File('bin/credentials.json');
    
    file.readAsString().then((String cont){
      accountCredentials = new auth.ServiceAccountCredentials.fromJson(cont);
      connect();
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
  
  Future<String> saveFile(@app.Body(app.FORM) var data) async {
    if (data['file'] is app.HttpBodyFileUpload) {
      app.HttpBodyFileUpload file = data["file"];
      List<int> content = file.content;
      Media newItem = new Media(new Stream.fromIterable([content]),
                                content.length, contentType: contentType);
      try {
        final String name = '${_Generator.v4()}.jpg';
        var ret = await storageClient.objects.insert(null, bucket,
                                                     name: name,
                                                     uploadMedia: newItem,
                                                     predefinedAcl: 'publicread');
        return "$bucket/$name";
      } catch (error) {
        throw new app.ErrorResponse(403, {"error": "$error"});
      }
    } else {
      throw new app.ErrorResponse(403, {"error": "data is not a file"});
    }
  }
  
  @app.Route('/base', methods: const [app.POST], allowMultipartRequest: true)
  @OnlyForUserGroup(const ['admin'])
  addBaseImage(String type, String id, String roomid, 
               @app.Body(app.FORM) var data) async
  {
    final String intUrl = await saveFile(data);
    final String publicUrl = "${googleBaseUrl}/${intUrl}";
    
    {
      Map<String, String> params = { 'value' : JSON.encode(publicUrl)};
      await _estateSrv.addDataForRoom(type, id, roomid, 'mainImageUrl', params);
    }
    
  }
}