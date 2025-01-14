
class TourModel {

  String name;
  String placemarkId;
  Map<String, double> initialCoordinate;
  List<Map<String, double>> coordinates;

  TourModel({
    required this.name,
    required this.placemarkId,
    required this.initialCoordinate,
    required this.coordinates,
  });

  String get tourKml => '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>Tour</name>
    <open>1</open>
    <Folder>
      $tag
    </Folder>
  </Document>
</kml>
  ''';


  String get tag => '''
    <gx:Tour>
      <name>$name</name>
      <gx:Playlist>
        $_updates
      </gx:Playlist>
    </gx:Tour>
  ''';


  String get _updates {
    String updates = '';

    double heading = 0;
    double? last;

    int changedIterations = 0;

    for (var coord in coordinates) {
      if (heading >= 360) {
        heading -= 360;
      }

      double? lng = coord['lng'];
      final lat = coord['lat'];
      final alt = coord['altitude'];

      bool changed = false;

      if (last != null && (lng! - last).abs() > 20 && changedIterations == 0) {
        changed = true;
      }

      if (last != null &&
          ((lng! < 0 && last > 0) || (lng > 0 && last < 0)) &&
          lat!.abs() > 70) {
        changedIterations++;
        heading += (heading >= 180 ? -180 : 180);
      }

      heading += 1;
      updates += '''
        <gx:FlyTo>
          <gx:duration>0.4</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>$lng</longitude>
            <latitude>$lat</latitude>
            <altitude>$alt</altitude>
            <heading>$heading</heading>
            <tilt>30</tilt>
            <range>10000000</range>
            <gx:altitudeMode>absolute</gx:altitudeMode>
          </LookAt>
        </gx:FlyTo>

        <gx:AnimatedUpdate>
          <gx:duration>${changed ? 0 : 0.7}</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="$placemarkId">
                <Point>
                  <coordinates>$lng,$lat,$alt</coordinates>
                </Point>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
      ''';

      if (changedIterations > 0 && changedIterations < 11) {
        changedIterations++;
      } else {
        changedIterations = 0;
      }

      last = lng;
    }

    updates += '''
        <gx:Wait>
          <gx:duration>2</gx:duration>
        </gx:Wait>

        <gx:AnimatedUpdate>
          <gx:duration>0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="$placemarkId">
                <Point>
                  <coordinates>${initialCoordinate['lng']},${initialCoordinate['lat']},${initialCoordinate['altitude']}</coordinates>
                </Point>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>

        <gx:FlyTo>
          <gx:duration>5</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>${initialCoordinate['lng']}</longitude>
            <latitude>${initialCoordinate['lat']}</latitude>
            <altitude>${initialCoordinate['altitude']}</altitude>
            <heading>0</heading>
            <tilt>60</tilt>
            <range>4000000</range>
            <gx:altitudeMode>relativeToGround</gx:altitudeMode>
          </LookAt>
        </gx:FlyTo>
    ''';

    return updates;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'placemarkId': placemarkId,
      'initialCoordinate': initialCoordinate,
      'coordinates': coordinates,
    };
  }

  factory TourModel.fromMap(Map<String, dynamic> map) {
    return TourModel(
      name: map['name'],
      placemarkId: map['placemarkId'],
      initialCoordinate: map['initialCoordinate'],
      coordinates: map['coordinates'],
    );
  }
}
