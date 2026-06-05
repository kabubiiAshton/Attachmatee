import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'posting_detail_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final TextEditingController searchController = TextEditingController();
  final _api = ApiService.instance;

  List<Posting>? _postings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPostings();
  }

  Future<void> _loadPostings([String? search]) async {
    setState(() {
      _error = null;
      _postings = null;
    });
    try {
      final raw = await _api.getPostings(search: search);
      setState(() {
        _postings = raw
            .map((e) => Posting.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search opportunities...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) => _loadPostings(value.trim()),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      filterChip("All"),
                      filterChip("IT"),
                      filterChip("Software"),
                      filterChip("Networking"),
                      filterChip("Remote"),
                      filterChip("Data"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: () => _loadPostings(searchController.text.trim()));
    }
    if (_postings == null) {
      return const LoadingView();
    }
    if (_postings!.isEmpty) {
      return const EmptyView(
        title: 'No opportunities found',
        hint: 'Try adjusting your search or check back later.',
      );
    }
    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => _loadPostings(searchController.text.trim()),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _postings!.length,
        itemBuilder: (context, index) {
          return _opportunityCard(_postings![index]);
        },
      ),
    );
  }

  Widget filterChip(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(title),
        onPressed: () {
          final query = title == 'All' ? '' : title;
          _loadPostings(query);
        },
      ),
    );
  }

  Widget _opportunityCard(Posting posting) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posting.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(posting.companyName),
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
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(posting.location.isEmpty ? 'Location not specified' : posting.location),
                ),
                Text(
                  posting.status == 'approved' ? 'Open' : posting.status.capitalize(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: posting.status == 'approved' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${posting.slots} slot(s)'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostingDetailScreen(posting: posting),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}

        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
              children: [

                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        job["role"],
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(job["company"]),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    job["saved"]
                        ? Icons.bookmark
                        : Icons
                            .bookmark_border,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      job["saved"] =
                          !job["saved"];
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 5),

                Text(job["location"]),

                const Spacer(),

                Text(
                  job["stipend"],
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: const Text(
                    "Internship",
                  ),
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () {

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          ApplicationFormScreen(
        job: job,
      ),
    ),
  );
},
                  icon:
                      const Icon(Icons.send),
                  label:
                      const Text("Apply"),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF2563EB),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}