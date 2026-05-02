import 'package:flutter/material.dart';

import '../../widgets/postal/postal.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Senior Post')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: const [
            PostalCardEnvelope(
              child: Text(
                'Senior Post is a global postal-style social app for adults 45+.\n\n'
                'We focus on calm companionship through postcards and letters, '
                'instead of algorithmic matching and instant-pressure interactions.\n\n'
                'Version: 1.0.0 (UI Mock Framework)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
