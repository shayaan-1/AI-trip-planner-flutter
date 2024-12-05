import "package:flutter/material.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

  class _SplashScreenState extends State<SplashScreen>{
    @override
    void initState(){
      super.initState();
      _navigateToLogin();
    }

    _navigateToLogin() async{
      await Future.delayed(
        const Duration(seconds: 3)
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            )
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.travel_explore,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20,),
                Text(
                  "Trip Planner",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  "Plan your perfect Journey",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70
                  ),
                )
              ],
            ),
          ),
        ),

      );
    }
  }

