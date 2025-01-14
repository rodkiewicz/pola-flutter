﻿import 'package:chopper/chopper.dart';
import 'package:pola_flutter/models/search_result.dart';

part 'pola_api_service.chopper.dart';

@ChopperApi()
abstract class PolaApiService extends ChopperService {

  //example code 5900311000360
  @Get(path: 'a/v4/get_by_code')
  Future<Response> getCompany(@Query("code") int code,@Query("device_id") String deviceId);

  static PolaApiService create() {
    final client = ChopperClient(
      baseUrl: 'https://pola-app.pl',
      interceptors: [
        HttpLoggingInterceptor()
      ],
      services: [
        _$PolaApiService(),
      ],
    );
    return _$PolaApiService(client);
  }
}