import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingMessages extends StatefulWidget {
  const LoadingMessages({super.key});

  @override
  _LoadingMessagesState createState() => _LoadingMessagesState();
}

class _LoadingMessagesState extends State<LoadingMessages>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startMessageRotation();
  }

  void _startMessageRotation() async {
    while (mounted) {
      _animationController.forward();
      await Future.delayed(Constants.messageRotationDuration);
      
      if (mounted) {
        _animationController.reverse();
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          setState(() {
            _currentMessageIndex = 
                (_currentMessageIndex + 1) % Constants.loadingMessages.length;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Indicateur de chargement rotatif
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Message de chargement
                Expanded(
                  child: Text(
                    Constants.loadingMessages[_currentMessageIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}