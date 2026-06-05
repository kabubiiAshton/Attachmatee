import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../widgets/common.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AttachMate Admin'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ApiService.instance.getCompanies(),
          ApiService.instance.getStudents(),
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

          final companies = snapshot.data![0] as List<dynamic>;
          final students = snapshot.data![1] as List<dynamic>;
          final postings = snapshot.data![2] as List<dynamic>;
          final applications = snapshot.data![3] as List<dynamic>;
          final pendingPostings = postings
              .where((item) => (item as Map<String, dynamic>)['status'] == 'pending')
              .length;
          final verifiedCompanies = companies
              .where((item) => (item as Map<String, dynamic>)['is_verified'] == true)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Admin Control Center',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Registered Companies'),
                  subtitle: Text('${companies.length} total, $verifiedCompanies verified'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Students'),
                  subtitle: Text('${students.length} profiles'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Applications'),
                  subtitle: Text('${applications.length} total'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.pending_actions),
                  title: const Text('Pending Postings'),
                  subtitle: Text('$pendingPostings awaiting approval'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}