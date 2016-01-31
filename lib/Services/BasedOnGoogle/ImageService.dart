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
import "package:ini/ini.dart";
import 'package:logging/logging.dart';

import 'package:SrvCommon/SrvCommon.dart';
import 'package:BMSrv/Services/RealEstateService.dart';
import 'package:BMSrv/Models/User.dart';
import 'package:BMSrv/Models/JsonWrappers/REMetaData.dart';

final scopes = [storage.StorageApi.DevstorageFullControlScope];

@app.Group("/")
class ImageService {
  final log = new Logger("BMSrv.Services.ImageService");
  final String contentType = "image/jpeg";
  final String bucket = "semplex";
  final String googleBaseUrl = "http://storage.googleapis.com";

  Uuid _Generator = new Uuid();

  RealEstateService _estateSrv;
  Config _config;

  auth.ServiceAccountCredentials accountCredentials = null;
  auth.AuthClient Client;

  storage.StorageApi storageClient;

  ImageService(RealEstateService this._estateSrv, Config this._config)
  {
    bool res = _config.hasSection('GoogleCloud');
    File file = new File(_config.get("GoogleCloud", "credentials"));

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

  Future<String> saveFile(@app.Body(app.FORM) var data,
                          {String bucket : null,
                           String prefix : ''}) async
  {
    if (data['file'] is app.HttpBodyFileUpload) {
      app.HttpBodyFileUpload file = data["file"];
      List<int> content = file.content;
      Media newItem = new Media(new Stream.fromIterable([content]),
                                content.length, contentType: contentType);
      try {
        final String name = '$prefix${_Generator.v4()}.jpg';
        bucket = bucket == null ? this.bucket : bucket;
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

  @app.Route('/users/:id/profile/avatar', methods: const [app.POST],
             allowMultipartRequest: true)
  @ProtectedAccess(filtrateByUser: true)
  addUserAvatar(String id, @app.Body(app.FORM) var data) async
  {
    User user = await User.GetUser(id);
    final String bucketName = 'semplex-users-info';
    final String intUrl = await saveFile(data,
                                         bucket: bucketName,
                                         prefix: 'user-${user.id}-');
    final String publicUrl = "${googleBaseUrl}/${intUrl}";

    if(user.profileImage != null) {
      try {
        Uri url = Uri.parse(user.profileImage);

        var ret = await storageClient.objects.
            delete(bucketName, url.pathSegments.last);
      } catch(error) {
        var tmp = error;
      }
    }
    user.profileImage = publicUrl;
    return user.save();
  }

  @app.Route('/realestate/:type/:id/rooms/:roomid/images/base',
             methods: const [app.POST], allowMultipartRequest: true)
  @ProtectedAccess(filtrateByUser: false, groups: const ['admin'])
  addBaseImage(String type, String id, String roomid,
               @app.Body(app.FORM) var data) async
  {
    final String prefix = "main-$type-$id-$roomid-";
    final String intUrl = await saveFile(data, prefix: prefix);
    final String publicUrl = "${googleBaseUrl}/${intUrl}";

    {
      Map<String, String> params = { 'value' : JSON.encode(publicUrl)};
      await _estateSrv.addDataForRoom(type, id, roomid, 'mainImageUrl', params);
    }

    return publicUrl;
  }

  @app.Route('/realestate/:type/:id/rooms/:roomid/images',
             methods: const [app.POST], allowMultipartRequest: true)
  @ProtectedAccess(filtrateByUser: false, groups: const ['admin'])
  addAdditionalImage(String type, String id, String roomid,
                     @app.Body(app.FORM) var data) async
  {
    REMetaDataWrapper images = await _estateSrv
                      .getDataForRoomByName(type, id, roomid, 'objectImages');

    final String prefix = "additional-$type-$id-$roomid-";
    final String intUrl = await saveFile(data, prefix: prefix);
    final String publicUrl = "${googleBaseUrl}/${intUrl}";
    Map<String, String> params = null;

    if(!images.data.containsKey('objectImages')) {
      params = { 'value' : JSON.encode([publicUrl])};
      await _estateSrv.
        addDataForRoom(type, id, roomid, 'objectImages', params);
    } else {
      (images.data['objectImages'][0] as List).add(publicUrl);
      params = { 'value' : JSON.encode(images.data['objectImages'][0])};
      await _estateSrv.
        changeDataForRoom(type, id, roomid, 'objectImages', '0', params);
    }

    return publicUrl;
  }

  @app.Route('/realestate/:type/:id/rooms/:roomid/images',
             methods: const[app.GET])
  getImages(String type, String id, String roomid) async
  {
    REMetaDataWrapper data = await _estateSrv
                  .getDataForRoomByName(type, id, roomid, 'objectImages');

    if(data.data.containsKey('objectImages')) {
      return data.data['objectImages'][0];
    } else {
      return [];
    }
  }
}
