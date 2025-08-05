import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart' as chat;
import '../components/chat_search_bar.dart';
import '../components/chat_list_item.dart';
import '../components/empty_chat_state.dart';
import '../../../../../shared/utils/guest_utils.dart';
import 'hushh_bot_chat_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => chat.ChatBloc()..add(const chat.LoadChatsEvent()),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, chat.ChatItem chatItem) {
    if (chatItem.isBot && chatItem.id == 'hushh_bot') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HushhBotChatPage(chatId: chatItem.id),
        ),
      );
    } else {
      // TODO: Navigate to other chat types
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This chat type is not implemented yet'),
        ),
      );
    }
  }
}
