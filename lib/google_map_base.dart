import 'package:flutter/material.dart';

import 'google_map_stub.dart'
    if (dart.library.io) 'package:covidfen/google_map_mobile.dart'

    if (dart.library.html) 'package:covidfen/google_map_browser.dart';

abstract class BaseGoogleMap {
  StatefulWidget getWidget();

  factory BaseGoogleMap() => getGoogleMap();
}
