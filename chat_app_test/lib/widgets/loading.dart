import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}


class LoadingMessages extends StatelessWidget {
  const LoadingMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}



