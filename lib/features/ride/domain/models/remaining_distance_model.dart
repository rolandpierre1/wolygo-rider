class RemainingDistanceModel {
  double? distance;
  String? distanceText;
  String? duration;
  int? durationSec;
  String? status;
  String? driveMode;
  String? encodedPolyline;

  RemainingDistanceModel(
      {this.distance,
        this.distanceText,
        this.duration,
        this.durationSec,
        this.status,
        this.driveMode,
        this.encodedPolyline});

  RemainingDistanceModel.fromJson(Map<String, dynamic> json) {
    distance = json['distance'].toDouble();
    distanceText = json['distance_text'];
    duration = json['duration'];
    durationSec = json['duration_sec'];
    status = json['status'];
    driveMode = json['drive_mode'];
    encodedPolyline = json['encoded_polyline'];
  }

}
