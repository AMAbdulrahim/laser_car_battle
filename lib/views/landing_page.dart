import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Team 57',
              style: TextStyle(
                
                fontSize: 50,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60, // Set the height of the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    child: Text('Enter Your Name'),
                  ),
                ),
              ),
              SizedBox(height: 20), 

            
            ],
          ),
        ],
      ),
    );
  }
}