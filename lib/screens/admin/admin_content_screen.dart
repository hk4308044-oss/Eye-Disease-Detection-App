import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/content_item.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/admin_data_table.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  static const List<ContentCategory> _categories = [
    ContentCategory.education,
    ContentCategory.screeningInfo,
    ContentCategory.recommendations,
    ContentCategory.faq,
    ContentCategory.announcement,
    ContentCategory.clinic,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCat = _categories[_tabController.index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<ContentItem>>(
        stream: _adminService.streamContentItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final allItems = snapshot.data ?? [];
          final filtered = allItems.where((item) {
            final matchesCat = item.category == currentCat;
            final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.content.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCat && matchesSearch;
          }).toList();

          return AdminDataTableCard(
            title: 'Content & Educational System Management',
            subtitle: 'Published articles, FAQs, announcements, and clinics directory.',
            searchHint: 'Search content titles or text...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            headerActions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: Text('Create ${currentCat.label.split(' ').first}'),
                onPressed: () => _showAddEditContentModal(context, category: currentCat),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ),
            ],
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppTheme.primaryTeal,
                  labelColor: AppTheme.primaryTeal,
                  unselectedLabelColor: AppTheme.textLightSecondary,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                  tabs: _categories.map((c) => Tab(text: c.label)).toList(),
                  onTap: (_) => setState(() {}),
                ),
                const Divider(height: 1),
                filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('No content items published in this category yet.', style: TextStyle(color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => _buildContentRow(context, filtered[i]),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentRow(BuildContext context, ContentItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.isPublished ? AppTheme.primaryTeal.withValues(alpha: 0.1) : const Color(0xFFD97706).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.isPublished ? Icons.article_outlined : Icons.drafts_outlined,
          color: item.isPublished ? AppTheme.primaryTeal : const Color(0xFFD97706),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: item.isPublished ? AppTheme.statusGreen.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.isPublished ? 'Published' : 'Draft',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: item.isPublished ? AppTheme.statusGreen : AppTheme.textLightSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Updated: ${DateFormat('dd MMM yyyy').format(item.updatedAt)} • Author: ${item.authorName}\n${item.content}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(item.isPublished ? Icons.visibility : Icons.visibility_off, color: AppTheme.primaryTeal, size: 20),
            tooltip: item.isPublished ? 'Unpublish' : 'Publish',
            onPressed: () async {
              final updated = item.copyWith(isPublished: !item.isPublished);
              await _adminService.saveContentItem(updated);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryNavy, size: 20),
            tooltip: 'Edit Content',
            onPressed: () => _showAddEditContentModal(context, item: item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.statusRed, size: 20),
            tooltip: 'Delete Content',
            onPressed: () async {
              await _adminService.deleteContentItem(item.id, item.title);
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditContentModal(BuildContext context, {ContentCategory? category, ContentItem? item}) {
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final subtitleCtrl = TextEditingController(text: item?.subtitle ?? '');
    final contentCtrl = TextEditingController(text: item?.content ?? '');
    bool isPublished = item?.isPublished ?? true;
    final cat = item?.category ?? category ?? ContentCategory.education;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateModal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item == null ? 'Create Content (${cat.label})' : 'Edit Content', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle / Category Tag')),
                const SizedBox(height: 10),
                TextField(controller: contentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Content Body')),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Publish Immediately', style: TextStyle(fontSize: 13, fontFamily: 'Inter')),
                  value: isPublished,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (v) => setStateModal(() => isPublished = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newItem = ContentItem(
                  id: item?.id ?? '',
                  category: cat,
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  isPublished: isPublished,
                  createdAt: item?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await _adminService.saveContentItem(newItem);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
