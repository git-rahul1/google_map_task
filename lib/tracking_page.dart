import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_map/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(23.789966, 90.372843);
  static const LatLng destinationLocation =
      LatLng(23.789917, 90.374731);

  List<LatLng> polyLineCoordinate = [];

  LocationData? currentLocation;

  BitmapDescriptor sourceIcon=BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon=BitmapDescriptor.defaultMarker;
  BitmapDescriptor courrentLocationIcon=BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {

    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(newLoc.longitude!, newLoc.longitude!),
          ),
        ),
      );
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_map_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pointLatLng) {
        polyLineCoordinate
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
      setState(() {});
    }
  }

  void setCustomMArkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "images/Pin_source.png").then((icon) => sourceIcon=icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "images/Pin_Destination.png").then((icon) => destinationIcon=icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "images/Badge.png").then((icon) => courrentLocationIcon=icon);
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    setCustomMArkerIcon();
    getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track"),
        centerTitle: true,
      ),
      body: Center(
        child: currentLocation == null
            ? Center(child: Text("Loading"))
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 14),
                polylines: {
                  Polyline(
                      polylineId: PolylineId("route"),
                      points: polyLineCoordinate,
                      color: primaryColor,
                      width: 6),
                },
                markers: {
                  Marker(
                    markerId: MarkerId("currentLocation"),
                    icon: courrentLocationIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                  ),
                  Marker(
                    markerId: MarkerId("source"),
                    position: sourceLocation,
                    icon: sourceIcon
                  ),
                  Marker(
                    markerId: MarkerId("destination"),
                    position: destinationLocation,
                    icon: destinationIcon
                  ),
                },
                onMapCreated: (mapController) {
                  _controller.complete(mapController);
                },
              ),
      ),
    );
  }
}
