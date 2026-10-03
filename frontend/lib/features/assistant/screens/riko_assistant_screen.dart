import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_services.dart';
import '../../../core/widgets/riko_avatar.dart';
import '../../../core/widgets/riko_expression.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final String? opportunityId;
  final DateTime time;

  ChatMessage({
    required this.isUser,
    required this.text,
    this.opportunityId,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

/// Riko Chat Assistant interface matching Reference Showcase Screen 6.
class RikoAssistantScreen extends StatefulWidget {
  const RikoAssistantScreen({super.key});

  @override
  State<RikoAssistantScreen> createState() => _RikoAssistantScreenState();
}

class _RikoAssistantScreenState extends State<RikoAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  final List<String> _quickSuggestions = const [
    'Find cybersecurity hackathons',
    'Show internships closing soon',
    'Recommend opportunities for me',
    'What are the best AI challenges?',
  ];

  @override
  void initState() {
    super.initState();
    final user = AppServices.auth.currentUser;
    final name = (user?.name.trim().isNotEmpty ?? false) ? user!.name.trim().split(' ').first : 'there';

    _messages.add(
      ChatMessage(
        isUser: false,
        text: "Hey $name! 👋 I'm Riko, your Opportunity Scout. What kind of hackathons, internships, or events can I scout for you today?",
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text.trim()));
      _inputController.clear();
    });
    _scrollToBottom();

    // Generate intelligent simulated scout response from local opportunities
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      final lower = text.toLowerCase();
      String replyText;
      String? matchedOppId;

      if (lower.contains('cyber') || lower.contains('security')) {
        replyText = "Got it! I found the top cybersecurity opportunities. The National Cyber Challenge by IIT Bombay and ISRO Workshop are active now! 🚀";
        matchedOppId = 'opp_7';
      } else if (lower.contains('intern') || lower.contains('job')) {
        replyText = "Scouted the best internships for you! Flipkart Product Design Intern and CrowdStrike Security Analyst are accepting applications.";
        matchedOppId = 'opp_2';
      } else if (lower.contains('closing') || lower.contains('soon') || lower.contains('deadline')) {
        replyText = "Here are the opportunities closing very soon. The ISRO Workshop and CrowdStrike Internship deadlines are approaching in under 4 days!";
        matchedOppId = 'opp_3';
      } else if (lower.contains('ai') || lower.contains('genai') || lower.contains('ml')) {
        replyText = "Found 2 premier AI hackathons! Google GenAI Hackathon 2025 has ₹5,00,000 in prizes and Microsoft AI Challenge is open.";
        matchedOppId = 'opp_1';
      } else {
        replyText = "I analyzed your interests and scouted 4 tailored hackathons and workshops across India that match your profile. Check this out:";
        matchedOppId = 'opp_1';
      }

      setState(() {
        _messages.add(ChatMessage(isUser: false, text: replyText, opportunityId: matchedOppId));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const RikoAvatar(
              expression: RikoExpression.happy,
              size: 38,
              showGlow: true,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Riko',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.auto_awesome, size: 13, color: AppColors.primaryBright),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online Scout',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Quick Suggestion Chips Cloud
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickSuggestions.length,
                itemBuilder: (context, index) {
                  final chip = _quickSuggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(chip),
                      labelStyle: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.softLavender,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surfaceSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _handleSendMessage(chip),
                    ),
                  );
                },
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: AppRadii.inputRadius,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSendMessage,
                        decoration: InputDecoration(
                          hintText: 'Ask Riko anything...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleSendMessage(_inputController.text),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Riko Message
    final opp = msg.opportunityId != null ? AppServices.opportunities.getById(msg.opportunityId!) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RikoAvatar(
            expression: RikoExpression.helpful,
            size: 34,
            showGlow: true,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                if (opp != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.code_rounded, color: AppColors.primaryLight, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opp.title,
                                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${opp.organization} · Deadline in ${opp.daysLeft} days',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OpportunityDetailScreen(opportunityId: opp.id),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View Opportunity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
