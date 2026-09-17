import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../services/messaging_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _messagingService = MessagingService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUid = _messagingService.currentUid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: _messagingService.streamConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.chat_bubble_2,
                      size: 44,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Messages Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                      ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Start a conversation by visiting a doctor\'s profile and tapping the Message button.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLightSecondary,
                        height: 1.5,
                        ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return _buildConversationTile(convo, currentUid);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation convo, String currentUid) {
    final isPatient = currentUid == convo.patientId;
    final otherName = isPatient ? convo.doctorName : convo.patientName;
    final otherId = isPatient ? convo.doctorId : convo.patientId;
    final unreadCount =
        isPatient ? convo.unreadCountPatient : convo.unreadCountDoctor;
    final specialty = isPatient ? convo.doctorSpecialty : null;

    // Build initials for avatar
    final initials = otherName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  conversationId: convo.id,
                  receiverId: otherId,
                  receiverName: otherName,
                  receiverSpecialty: specialty,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight, width: 0.5),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name, specialty, and last message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              otherName,
                              style: TextStyle(
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: AppTheme.primaryNavy,
                                ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (convo.lastMessageTime != null)
                            Text(
                              _formatTime(convo.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 11,
                                color: unreadCount > 0
                                    ? AppTheme.primaryTeal
                                    : AppTheme.textLightDisabled,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                ),
                            ),
                        ],
                      ),
                      if (specialty != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryTeal,
                            ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              convo.lastMessage ?? 'No messages yet',
                              style: TextStyle(
                                fontSize: 13,
                                color: unreadCount > 0
                                    ? AppTheme.primaryNavy
                                    : AppTheme.textLightSecondary,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(time.year, time.month, time.day);

    if (dateDay == today) return DateFormat('h:mm a').format(time);
    if (dateDay == yesterday) return 'Yesterday';
    if (now.difference(time).inDays < 7) return DateFormat('EEE').format(time);
    return DateFormat('MMM d').format(time);
  }
}
