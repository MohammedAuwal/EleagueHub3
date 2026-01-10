import 'package:flutter/material.dart';
import 'dart:ui';

class MyFixturesFilter extends StatefulWidget {
  final Function(bool) onToggle;
  const MyFixturesFilter({super.key, required this.onToggle});

  @override
  State<MyFixturesFilter> createState() => _MyFixturesFilterState();
}

class _MyFixturesFilterState extends State<MyFixturesFilter> {
  bool isMyMatches = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () {
              setState(() => isMyMatches = !isMyMatches);
              widget.onToggle(isMyMatches);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Stack(
                children: [
                  // Sliding Indicator
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isMyMatches ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  // Labels
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text("All Matches", 
                            style: TextStyle(color: isMyMatches ? Colors.white54 : Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("My Matches", 
                            style: TextStyle(color: isMyMatches ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
