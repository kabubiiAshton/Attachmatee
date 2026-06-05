import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../widgets/common.dart';

class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttachMate Company'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ApiService.instance.getPostings(),
          ApiService.instance.getMyApplications(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }

          final postings = snapshot.data![0] as List<dynamic>;
          final applications = snapshot.data![1] as List<dynamic>;
          final pendingApplications = applications
              .where((item) => (item as Map<String, dynamic>)['status'] == 'pending')
              .length;
          final acceptedApplications = applications
              .where((item) => (item as Map<String, dynamic>)['status'] == 'accepted')
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Company Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.add_business),
                  title: const Text('Your Opportunities'),
                  subtitle: Text('${postings.length} postings'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Applicants'),
                  subtitle: Text('${applications.length} total'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Pending Applications'),
                  subtitle: Text('$pendingApplications waiting review'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Accepted Candidates'),
                  subtitle: Text('$acceptedApplications accepted'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}