import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService.instance;
  List<NotificationItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _items = null;
    });
    try {
      final raw = await _api.getNotifications();
      setState(() => _items = raw
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList());
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllRead();
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_items == null) return const LoadingView();
    if (_items!.isEmpty) {
      return const EmptyView(
        title: 'No notifications',
        hint: 'Updates about your applications will appear here.',
        icon: Icons.notifications_none,
      );
    }
    final hasUnread = _items!.any((n) => !n.isRead);
    return Column(
      children: [
        if (hasUnread)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextButton(
                onPressed: _markAllRead,
                child: const Text('Mark all read'),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.teal,
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _items![i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead ? AppColors.surface : AppColors.tealSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        n.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        size: 20,
                        color: n.isRead ? AppColors.muted : AppColors.teal,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(n.message,
                            style: TextStyle(
                                color: AppColors.ink,
                                fontWeight: n.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                height: 1.4)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
