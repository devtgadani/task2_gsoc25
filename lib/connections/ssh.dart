import 'package:dartssh2/dartssh2.dart';
import 'dart:async';
import 'dart:io';
import 'package:task_2_dev_t_gadani/components/connection_flag.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute([String? replaceAll]) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final demo_result =
          await _client!.execute(' echo "search=India" >/tmp/query.txt');
      return demo_result;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<void> relaunchLG() async {
    try {
      for (var i = 1; i <= int.parse(_numberOfRigs); i++) {
        String cmd = """RELAUNCH_CMD="\\
        if [ -f /etc/init/lxdm.conf ]; then
          export SERVICE=lxdm
        elif [ -f /etc/init/lightdm.conf ]; then
          export SERVICE=lightdm
        else
          exit 1
        fi
        if [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
          echo ${_passwordOrKey} | sudo -S service \\\${SERVICE} start
        else
          echo ${_passwordOrKey} | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p ${_passwordOrKey} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await _client?.run(
            '"/home/${_username}/bin/lg-relaunch" > /home/${_username}/log.txt');
        await _client?.run(cmd);
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> rebootlg() async {
    try {
      for (var i = 1; i <= int.parse(_numberOfRigs); i++) {
        await _client?.run(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> powerOff() async {
    try {
      for (var i = 1; i <= int.parse(_numberOfRigs); i++) {
        await _client?.run(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S poweroff"');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> setRefresh() async {
    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'{{cmd}}\'';

      try {
        await execute(query.replaceAll('{{cmd}}', clearCmd));
        await execute(query.replaceAll('{{cmd}}', cmd));
      } catch (e) {
        print("$e");
      }
    }
    await rebootlg();
  }

  Future<void> resetRefresh() async {
    const search =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

    final clear =
        'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
      final cmd = clear.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $_passwordOrKey ssh -t lg$i \'$cmd\'';

      try {
        await _client!.execute(query);
      } catch (e) {
        print("$e");
      }
    }
    await rebootlg();
  }

  // clean  kml  and logo

  Future cleanLogo() async {
    String clean =
        '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
      </Document>
</kml>

  ''';

    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      } else {
        await _client?.execute("echo '$clean' > /var/www/html/kml/slave_3.kml");
        print('done');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  cleanKML() async {
    try {
      await _client!.execute("echo '' > /tmp/query.txt");
      await _client!.execute("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      await cleanKML();
    }
  }

  //send logo to salve

  Future sendLogo() async {
    String name =
        '''<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>task 2</name>
    <open>1</open>
    <description>dev t gadani </description>
    <Folder>

      <ScreenOverlay id="abc">
        <name>task 2 </name>
        <Icon><href>
        https://github.com/devtgadani/kml-dataimg/blob/1d2424cfba4e8340f810a974b3a7b7bca79098b9/task2_gsoc25.jpg?raw=true</href></Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0" y="0.98" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="500" y="300" xunits="pixels" yunits="pixels"/>
      </ScreenOverlay>
      </Folder>
  </Document>
</kml>

  ''';

    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      } else {
        await _client?.execute("echo '$name' > /var/www/html/kml/slave_3.kml");
        print('done');
      }
    } catch (e) {
      return Future.error(e);
    }
  }

// my city name khadia
  Future<SSHSession?> myHomeCity(String place) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      final session =
          await _client!.execute("echo 'search=$place' >/tmp/query.txt");
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

// orbit lg

  playOrbit() async {
    try {
      await connectToLG();
      await _client!
          .execute("echo '${SSH().makeOrbit()}' > /var/www/html/orbitCity.kml");
      await _client!.execute(
          'echo "http://lg1:81/orbitCity.kml" >> /var/www/html/kmls.txt');
      print('orbit');
      return await _client!.execute("echo 'playtour=Orbit' > /tmp/query.txt");
    } catch (error) {
      throw error;
    }
  }

  String makeOrbit() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <gx:Tour>
    <name>Orbit</name>
      <gx:Playlist>
        ${getCityData()}
      </gx:Playlist>
  </gx:Tour>
</kml>
  ''';
  }

  String getCityData() {
    int heading = 0;
    String kml = '';

    for (var i = 0; i <= 36; i++) {
      heading += 10;
      kml += '''
<gx:FlyTo>
  <gx:duration>1.2</gx:duration>
  <gx:flyToMode>smooth</gx:flyToMode>
  	<name>Dev Place</name>
  <LookAt>
    <longitude>72.59338047456748</longitude>
    <latitude>23.02073745592954</latitude>
    <heading>$heading</heading>
   <tilt>64.34299295697522</tilt>
    <range>193.8159415534574</range>
    <gx:fovy>35</gx:fovy> 
    <altitude>75.9318908017075</altitude> 
    <gx:altitudeMode>absolute</gx:altitudeMode>
  </LookAt>
</gx:FlyTo>
  ''';
    }

    return kml;
  }

// constant kml file maker for 2  kml file

// 1

  String kmlKhadia() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>Khadia, Ahmedabad - Red Circle</name>
	<description>Khadia area highlighted with a smooth red circle.</description>
	
	<Style id="redCircleStyle">
		<LineStyle>
			<color>ff0000ff</color>
			<width>2</width>
		</LineStyle>
		<PolyStyle>
			<color>4d0000ff</color>
		</PolyStyle>
	</Style>
	<Style id="redCircleStyle0">
		<LineStyle>
			<color>ff0000ff</color>
			<width>2</width>
		</LineStyle>
		<PolyStyle>
			<color>4d0000ff</color>
		</PolyStyle>
	</Style>
	<StyleMap id="redCircleStyle1">
		<Pair>
			<key>normal</key>
			<styleUrl>#redCircleStyle</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#redCircleStyle0</styleUrl>
		</Pair>
	</StyleMap>
	<Placemark>
		<name>Khadia Area</name>
		<styleUrl>#redCircleStyle1</styleUrl>
		<Polygon>
			<outerBoundaryIs>
				<LinearRing>
					<coordinates>
						72.59895945592152,23.0257219922189,0 72.59838629684366,23.03284965792903,0 72.5885,23.032,0 72.58450000000001,23.033,0 72.5805,23.032,0 72.5775,23.029,0 72.5765,23.025,0 72.5775,23.021,0 72.5805,23.018,0 72.58450000000001,23.017,0 72.5885,23.018,0 72.5988974643688,23.01899153551538,0 72.59895945592152,23.0257219922189,0 
					</coordinates>
				</LinearRing>
			</outerBoundaryIs>
		</Polygon>
	</Placemark>
</Document>
</kml>

''';
  }

// 2

  String kmlLleida() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>Lleida, Spain - Red Circle</name>
    <description>Lleida city area highlighted with a red circle</description>
    <Style id="redCircleStyle">
      <PolyStyle>
        <color>4d0000ff</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
      <LineStyle>
        <color>ff0000ff</color>
        <width>2</width>
      </LineStyle>
    </Style>
    <Placemark>
      <name>Lleida Area</name>
      <styleUrl>#redCircleStyle</styleUrl>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              0.6341,41.6183,0
              0.6331,41.6223,0
              0.6301,41.6253,0
              0.6261,41.6263,0
              0.6221,41.6253,0
              0.6191,41.6223,0
              0.6181,41.6183,0
              0.6191,41.6143,0
              0.6221,41.6113,0
              0.6261,41.6103,0
              0.6301,41.6113,0
              0.6331,41.6143,0
              0.6341,41.6183,0
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    </Placemark>
  </Document>
</kml>''';
  }

// function to upload and execute kml file to lg master .

//1

  Future<SSHSession?> kmlMaker() async {
    try {
      await connectToLG();

      await _client!
          .execute("echo '${SSH().kmlKhadia()}' > /var/www/html/kmlKhadia.kml");
      await _client!.execute(
          'echo "http://lg1:81/kmlKhadia.kml" >> /var/www/html/kmls.txt');
      final executeResult = await _client!.execute(
          'echo "flytoview=${getKML(23.02073745592954, 72.59338047456748, 2000, 30, 0)}" > /tmp/query.txt');
    } catch (error) {
      throw error;
    }
  }

//2

  Future<SSHSession?> kmlMaker2() async {
    try {
      await connectToLG();

      await _client!
          .execute("echo '${SSH().kmlLleida()}' > /var/www/html/kmltwo.kml");
      await _client!
          .execute('echo "http://lg1:81/kmltwo.kml" >> /var/www/html/kmls.txt');
      final executeResult = await _client!.execute(
          'echo "flytoview=${getKML(41.6166, 0.6266, 2000, 30, 0)}" > /tmp/query.txt');
    } catch (error) {
      throw error;
    }
  }

  // fly to specfic place where kml made

  String getKML(double latitude, double longitude, double zoom, double tilt,
      double heading) {
    return '<gx:duration>3.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$heading</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }
}
