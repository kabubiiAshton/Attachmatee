import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../widgets/common.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState
    extends State<ApplicationsScreen> {

  final TextEditingController searchController = TextEditingController();
  final _api = ApiService.instance;

  String selectedFilter = 'All';
  List<Map<String, dynamic>>? applications;
  String? error;

  @override
  void initState() {
    super.initState();
    refreshApplications();
  }

  Future<void> refreshApplications() async {
    setState(() {
      error = null;
      applications = null;
    });
    try {
      final raw = await _api.getMyApplications();
      setState(() {
        applications = raw.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Applied":
        return Colors.blue;

      case "Under Review":
        return Colors.orange;

      case "Shortlisted":
        return Colors.purple;

      case "Interview":
        return Colors.green;

      case "Accepted":
        return Colors.teal;

      case "Rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  double getProgress(String status) {

    switch (status) {

      case "Applied":
        return .2;

      case "Under Review":
        return .4;

      case "Shortlisted":
        return .6;

      case "Interview":
        return .8;

      case "Accepted":
        return 1.0;

      default:
        return .1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: ErrorView(message: error!, onRetry: refreshApplications),
      );
    }
    if (applications == null) {
      return const Scaffold(
        body: LoadingView(),
      );
    }

    final allApplications = applications!;
    final pendingCount = allApplications
        .where((app) => app['status'].toString().toLowerCase() == 'pending')
        .length;
    final shortlistedCount = allApplications
        .where((app) => app['status'].toString().toLowerCase() == 'shortlisted')
        .length;
    final acceptedCount = allApplications
        .where((app) => app['status'].toString().toLowerCase() == 'accepted')
        .length;
    final rejectedCount = allApplications
        .where((app) => app['status'].toString().toLowerCase() == 'rejected')
        .length;
    final filteredApplications = allApplications.where((app) {
      if (selectedFilter == 'All') {
        return true;
      }
      return app['status'].toString().toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8FAFC),

      body: RefreshIndicator(

        onRefresh: refreshApplications,

        child: ListView(

          padding: const EdgeInsets.all(20),

          children: [

            // ===================
            // SEARCH
            // ===================

            TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText:
                    "Search applications...",
                prefixIcon:
                    const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===================
            // STATISTICS
            // ===================

            const Text(
              "Application Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.4,

              children: [

                statCard(
                  "Pending",
                  '$pendingCount',
                  Icons.hourglass_empty,
                  Colors.blue,
                ),

                statCard(
                  "Shortlisted",
                  '$shortlistedCount',
                  Icons.calendar_month,
                  Colors.green,
                ),

                statCard(
                  "Accepted",
                  '$acceptedCount',
                  Icons.check_circle,
                  Colors.teal,
                ),

                statCard(
                  "Rejected",
                  '$rejectedCount',
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ===================
            // FILTERS
            // ===================

            SizedBox(
              height: 45,

              child: ListView(
                scrollDirection:
                    Axis.horizontal,

                children: [

                  buildFilter("All"),
                  buildFilter("Applied"),
                  buildFilter(
                    "Under Review",
                  ),
                  buildFilter(
                    "Shortlisted",
                  ),
                  buildFilter(
                    "Interview",
                  ),
                  buildFilter(
                    "Accepted",
                  ),
                  buildFilter(
                    "Rejected",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "My Applications",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...filteredApplications.map(
              (application) {

                return applicationCard(
                  application,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilter(String title) {

    bool selected =
        selectedFilter == title;

    return Padding(

      padding:
          const EdgeInsets.only(
        right: 10,
      ),

      child: ChoiceChip(

        label: Text(title),

        selected: selected,

        onSelected: (value) {

          setState(() {

            selectedFilter =
                title;
          });
        },
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          CircleAvatar(
            backgroundColor:
                color.withOpacity(.15),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(title),
        ],
      ),
    );
  }

  Widget applicationCard(
      Map<String, dynamic> app) {

    Color statusColor =
        getStatusColor(
      app["status"],
    );

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          25,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        children: [

          Row(

            children: [

              Container(

                width: 55,
                height: 55,

                decoration:
                    BoxDecoration(

                  color:
                      Colors.blue
                          .shade50,

                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),

                child:
                    const Icon(
                  Icons.business,
                  color:
                      Colors.blue,
                ),
              ),

              const SizedBox(
                  width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      app["role"],
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            16,
                      ),
                    ),

                    Text(
                      app[
                          "company"],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          LinearProgressIndicator(
            value: getProgress(
              app["status"],
            ),
            color: statusColor,
          ),

          const SizedBox(
            height: 10,
          ),

          Row(

            children: [

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      12,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(

                  color: statusColor
                      .withOpacity(
                          .1),

                  borderRadius:
                      BorderRadius
                          .circular(
                              20),
                ),

                child: Text(
                  app["status"],
                  style:
                      TextStyle(
                    color:
                        statusColor,
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                app["date"],
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Row(

            children: [

              Expanded(
                child:
                    OutlinedButton(

                  onPressed: () {

                    showDialog(

                      context:
                          context,

                      builder:
                          (_) {

                        return AlertDialog(

                          title:
                              const Text(
                            "Application Details",
                          ),

                          content:
                              Text(
                            "${app["role"]}\n\n${app["company"]}\n\nStatus: ${app["status"]}",
                          ),
                        );
                      },
                    );
                  },

                  child:
                      const Text(
                    "View Details",
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    ElevatedButton(

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors
                            .red,
                    foregroundColor:
                        Colors
                            .white,
                  ),

                  onPressed: () async {
                    await _withdraw(app['id'] as int);
                  },

                  child: const Text(
                    "Withdraw",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}