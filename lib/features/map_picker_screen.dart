// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
//
// class MapPickerScreen extends StatefulWidget {
//   final LatLng initialPosition;
//
//   const MapPickerScreen({Key? key, required this.initialPosition})
//     : super(key: key);
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   LatLng? _selectedPosition;
//   late GoogleMapController _mapController;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedPosition = widget.initialPosition;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pick Location"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: () {
//               Navigator.pop(context, _selectedPosition);
//             },
//           ),
//         ],
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: widget.initialPosition,
//           zoom: 15,
//         ),
//         onMapCreated: (controller) => _mapController = controller,
//         markers: _selectedPosition != null
//             ? {
//                 Marker(
//                   markerId: const MarkerId('picked'),
//                   position: _selectedPosition!,
//                 ),
//               }
//             : {},
//         onTap: (pos) {
//           setState(() {
//             _selectedPosition = pos;
//           });
//         },
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//     );
//   }
// }
