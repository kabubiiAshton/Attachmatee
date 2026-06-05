import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../models/models.dart';
import '../posting_detail_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==========================
            // HEADER CARD
            // ==========================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF2563EB),
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: const [

                            Text(
                              "Welcome Back 👋",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Find Your Next Attachment",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Profile Completion",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      value: 0.85,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "85% Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==========================
            // SEARCH BAR
            // ==========================

            TextField(
              decoration: InputDecoration(
                hintText: "Search opportunities...",
                prefixIcon:
                    const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==========================
            // OVERVIEW SECTION
            // ==========================

            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
              childAspectRatio: 1.3,
              children: [
                FutureBuilder<List<dynamic>>(
                  future: ApiService.instance.getMyApplications(),
                  builder: (context, snapshot) {
                    final value = snapshot.connectionState != ConnectionState.done
                        ? '...'
                        : '${snapshot.data?.length ?? 0}';
                    return dashboardCard(
                      'Applications',
                      value,
                      Icons.description,
                      Colors.blue,
                    );
                  },
                ),

                dashboardCard(
                  "Interviews",
                  "3",
                  Icons.calendar_month,
                  Colors.green,
                ),

                dashboardCard(
                  "Saved",
                  "8",
                  Icons.bookmark,
                  Colors.orange,
                ),

                dashboardCard(
                  "Profile",
                  "85%",
                  Icons.person,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==========================
            // RECOMMENDED JOBS
            // ==========================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: const [

                Text(
                  "Recommended Opportunities",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            FutureBuilder<List<dynamic>>(
              future: ApiService.instance.getPostings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                }
                if (snapshot.hasError) {
                  return const Text('Unable to load opportunities.');
                }
                final postings = snapshot.data ?? [];
                if (postings.isEmpty) {
                  return const EmptyView(
                    title: 'No opportunities available',
                    hint: 'Check back later or ask a company to post a new role.',
                  );
                }
                return Column(
                  children: postings.take(3).map((posting) {
                    final job = posting as Map<String, dynamic>;
                    return opportunityCard(
                      job['company_name'] as String? ?? 'Company',
                      job['title'] as String? ?? 'Opportunity',
                      job['location'] as String? ?? 'Location',
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // ==========================
            // INTERVIEWS
            // ==========================

            const Text(
              "Upcoming Interviews",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            interviewCard(
              "Safaricom PLC",
              "15 June 2026 • 10:00 AM",
            ),

            const SizedBox(height: 15),

            interviewCard(
              "KCB Bank",
              "18 June 2026 • 9:00 AM",
            ),

            const SizedBox(height: 30),

            // ==========================
            // SKILLS
            // ==========================

            const Text(
              "Skills In Demand",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                skillChip("Flutter"),
                skillChip("Django"),
                skillChip("Python"),
                skillChip("React"),
                skillChip("UI/UX"),
                skillChip("Git"),
                skillChip("SQL"),
                skillChip("Java"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          CircleAvatar(
            backgroundColor:
                color.withOpacity(0.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget opportunityCard(
    String company,
    String position,
    String location,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [

          Row(
            children: [

              const CircleAvatar(
                child: Icon(Icons.business),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      position,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(company),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              const Icon(
                Icons.location_on,
                size: 18,
              ),

              const SizedBox(width: 5),

              Text(location),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  foregroundColor:
                      Colors.white,
                ),
                onPressed: () {},
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget interviewCard(
    String company,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          const Icon(
            Icons.calendar_month,
            color: Colors.green,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  company,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(date),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget skillChip(String skill) {
    return Chip(
      backgroundColor:
          const Color(0xFFE0E7FF),
      label: Text(
        skill,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}