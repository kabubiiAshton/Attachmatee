import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../theme.dart';

class PostingDetailScreen extends StatefulWidget {
  final Posting posting;
  const PostingDetailScreen({super.key, required this.posting});
  @override
  State<PostingDetailScreen> createState() => _PostingDetailScreenState();
}

class _PostingDetailScreenState extends State<PostingDetailScreen> {
  final _api = ApiService.instance;

  Future<void> _openApplySheet() async {
    final coverCtrl = TextEditingController();
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        bool busy = false;
        String? error;
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Apply: ${widget.posting.title}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(error!,
                        style: const TextStyle(color: AppColors.danger)),
                  ),
                TextField(
                  controller: coverCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Cover letter (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setSheet(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            await _api.apply(
                                widget.posting.id, coverCtrl.text.trim());
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          } catch (e) {
                            setSheet(() {
                              busy = false;
                              error = e.toString();
                            });
                          }
                        },
                  child: Text(busy ? 'Submitting…' : 'Submit application'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (applied == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted.'),
          backgroundColor: AppColors.ink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.posting;
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(p.title,
              style: const TextStyle(
                  fontSize: 23, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 6),
          Text(p.companyName,
              style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          _InfoRow(icon: Icons.location_on_outlined, label: p.location.isEmpty ? 'Not specified' : p.location),
          _InfoRow(icon: Icons.people_outline, label: '${p.slots} slot(s) available'),
          if (p.deadline != null)
            _InfoRow(icon: Icons.event_outlined, label: 'Deadline: ${p.deadline}'),
          const Divider(height: 32, color: AppColors.line),
          const Text('Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(p.description.isEmpty ? 'No description provided.' : p.description,
              style: const TextStyle(color: AppColors.inkSoft, height: 1.5)),
          if (p.requirements.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Requirements',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(p.requirements,
                style: const TextStyle(color: AppColors.inkSoft, height: 1.5)),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _openApplySheet,
            icon: const Icon(Icons.send_outlined, size: 18),
            label: const Text('Apply now'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppColors.inkSoft, fontSize: 14.5))),
        ],
      ),
    );
  }
}
