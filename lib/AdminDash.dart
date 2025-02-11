import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AdminDashScreen.dart';

class Admindash extends StatefulWidget {
  const Admindash({super.key});

  @override
  State<Admindash> createState() => _AdmindashState();
}

class _AdmindashState extends State<Admindash> {
  List<String> enteredPasscode = [];
  String storedPasscode = "";
  bool isSettingPasscode = false;
  String passcodeToConfirm = "";

  @override
  void initState() {
    super.initState();
    enteredPasscode.clear();
    
    _loadPasscode();
  }

  /// Fetch passcode from Firestore
  Future<void> _loadPasscode() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Admin')
          .doc('AdminDash')
          .get();

      setState(() {
        if (doc.exists && doc.data() != null && doc['AdminDashPass'] != null) {
          storedPasscode = doc['AdminDashPass'];
          isSettingPasscode = false; // Passcode exists, ask for entry
        } else {
          isSettingPasscode = true; // No passcode found, ask to create
          storedPasscode = ""; // Ensure storedPasscode is empty
        }
      });
    } catch (e) {
      print("Error loading passcode: $e");
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      enteredPasscode.clear();
    });
  }

  /// Save passcode to Firestore
  Future<void> _savePasscode(String passcode) async {
    try {
      await FirebaseFirestore.instance
          .collection('Admin')
          .doc('AdminDash')
          .set({'AdminDashPass': passcode});
      setState(() {
        storedPasscode = passcode;
        isSettingPasscode = false;
      });
    } catch (e) {
      print("Error saving passcode: $e");
    }
  }

  void _onNumberPressed(String num) {
    if (enteredPasscode.length < 4) {
      setState(() {
        enteredPasscode.add(num);
      });
      if (enteredPasscode.length == 4) {
        _validatePasscode();
      }
    }
  }

  void _onDeletePressed() {
    if (enteredPasscode.isNotEmpty) {
      setState(() {
        enteredPasscode.removeLast();
      });
    }
  }



  void _onForgotPassword(){
    
    
    
  }
  Widget _forgotPassword (){
    return ElevatedButton(onPressed: _onForgotPassword, child: Text('Forgot Password'));
    
  }

  void _onSubmitPressed() {
    if (enteredPasscode.isNotEmpty) {
      setState(() {
        enteredPasscode.clear();
      });
    }
  }

  void _validatePasscode() {
    String entered = enteredPasscode.join("");

    if (isSettingPasscode) {
      if (passcodeToConfirm.isEmpty) {
        passcodeToConfirm = entered;
        setState(() {
          passcodeToConfirm = entered;
          enteredPasscode.clear();
        });
      } else if (passcodeToConfirm == entered) {
        _savePasscode(entered);
        setState(() {
          storedPasscode = entered;
          isSettingPasscode = false;
          enteredPasscode.clear();
        });
      } else {
        setState(() {
          enteredPasscode.clear();
          passcodeToConfirm = "";
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passcodes do not match! Try again.')),
          );
        });
      }
    } else {
      if (entered == storedPasscode) {
        Future.delayed(const Duration(milliseconds: 500), () {
          enteredPasscode.clear();
          didChangeDependencies();
          
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashScreen()),
          );
        });
      } else {
        setState(() {
          enteredPasscode.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect Passcode')),
          );
        });
      }
    }
  }

  Widget buildPasscodeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
            color: index < enteredPasscode.length ? Color(0xFF706993) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget Dial(String num) {
    Color _getRandomColor() {
      final random = Random();
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    return OutlinedButton(
      onPressed: () => _onNumberPressed(num),
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.all(28.0),
        backgroundColor: _getRandomColor().withOpacity(0.1),
      ),
      child: Text(
        num,
        style: GoogleFonts.russoOne(fontSize: 20, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE5D9).withOpacity(0.2),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isSettingPasscode
                ? (passcodeToConfirm.isEmpty
                ? "Create a passcode"
                : "Confirm your passcode")
                : "Enter your passcode",
            style: GoogleFonts.russoOne(fontSize: 28),
          ),
          const SizedBox(height: 50),
          buildPasscodeDots(),
          const SizedBox(height: 50),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Dial('1'), Dial('2'), Dial('3')],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Dial('4'), Dial('5'), Dial('6')],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Dial('7'), Dial('8'), Dial('9')],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _onSubmitPressed,
                    icon: const Icon(Icons.clear_all_rounded, color: Color(0xFF6C91C2), size: 30,),
                  ),
                  Dial('0'),
                  IconButton(
                    onPressed: _onDeletePressed,
                    icon: const Icon(Icons.backspace, color: Color(0xFF6C91C2)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
