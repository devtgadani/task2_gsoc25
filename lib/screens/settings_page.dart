import 'package:flutter/material.dart';
import 'package:task_2_dev_t_gadani/components/connection_flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../connections/ssh.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  late SSH ssh;

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _loadSettings();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result ?? false;
    });
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  void _showAlert(String title, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          // actions: [
    
          //   _buildButton('cancel', , Colors.white, const Color(0xFF8B0000)),
          // ],
        );
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color backgroundColor, Color textColor) {
    return Container(
      width: 200,
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, connectionStatus);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Connection Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ConnectionFlag(status: connectionStatus),
              const SizedBox(height: 20),
              _buildTextField(_ipController, 'IP address', 'Enter Master IP', Icons.computer),
              _buildTextField(_usernameController, 'LG Username', 'Enter your username', Icons.person),
              _buildTextField(_passwordController, 'LG Password', 'Enter your password', Icons.lock, isPassword: true),
              _buildTextField(_sshPortController, 'SSH Port', '22', Icons.settings_ethernet),
              _buildTextField(_rigsController, 'No. of LG rigs', 'Enter the number of rigs', Icons.memory),
              const SizedBox(height: 20),
              _buildButton('CONNECT TO LG', () async {
                await _saveSettings();
                bool? result = await ssh.connectToLG();
                if (result == true) {
                  setState(() {
                    connectionStatus = true;
                  });
                  _showAlert('Successful Connection', () {});
                } else {
                  _showAlert('Connection Failed', () {});
                }
              }, Colors.white,  Color(0xFF8B0000)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
            focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6D091E), width: 5.0),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
        ),
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
