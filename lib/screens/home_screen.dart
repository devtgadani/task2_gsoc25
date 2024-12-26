import 'package:flutter/material.dart';
import 'package:task_2_dev_t_gadani/connections/ssh.dart';
import 'package:task_2_dev_t_gadani/components/connection_flag.dart';

bool connectionStatus = false;
const String searchPalce = 'Khadia';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  bool isFirstClick = true;

  void _handleClick() async {
    if (isFirstClick) {
      await ssh.kmlMaker();
    } else {
      await ssh.kmlMaker2();
    }
    setState(() {
      isFirstClick = !isFirstClick; // Toggle the state for next click
    });
  }

  void _showAlert(String title, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1E1E),
          title: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Container(
              width: 200,
              height: 50,
              margin: EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              width: 200,
              height: 50,
              margin: EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF8B0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main logo image
          Container(
            width: 350,
            height: 350,
            child: Image.asset(
              'assets/lg.png',
              fit: BoxFit.contain,
            ),
          ),
          // Optional animated ring around the logo
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: 55,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF8B0000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            elevation: 3,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Text(
              'TASK 2 DEV T GADANI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            ConnectionFlag(status: connectionStatus),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              _buildLogo(),
              SizedBox(height: 40),
              // First Row
              Row(
                children: [
                  Expanded(
                    child: _buildButton('RELAUNCH', () {
                      _showAlert('Relaunching rig', () async {
                        await ssh.relaunchLG();
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildButton('CLEAN KML', () async {
                      await ssh.cleanKML();
                    }),
                  ),
                  Expanded(
                    child: _buildButton('ORBIT LG', () async {
                      await ssh.playOrbit();
                    }),
                  ),
                ],
              ),
              // Second Row
              Row(
                children: [
                  Expanded(
                    child: _buildButton('REBOOT LG', () {
                      _showAlert('Rebooting rig', () async {
                        await ssh.rebootlg();
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildButton('MY HOME CITY', () async {
                      await ssh.myHomeCity(searchPalce);
                    }),
                  ),
                  Expanded(
                    child: _buildButton(
                      'SEND KML (${isFirstClick ? "1" : "2"})',
                      _handleClick,
                    ),
                  ),
                ],
              ),
              // Third Row
              Row(
                children: [
                  Expanded(
                    child: _buildButton('CLEAN LOGO', () async {
                      await ssh.cleanLogo();
                    }),
                  ),
                  Expanded(
                    child: _buildButton('SEND LOGO', () async {
                      await ssh.sendLogo();
                    }),
                  ),
                  Expanded(
                    child: _buildButton('POWER OFF ', () async {
                      _showAlert('Powering off system', () {
                        ssh.powerOff();
                      });
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
