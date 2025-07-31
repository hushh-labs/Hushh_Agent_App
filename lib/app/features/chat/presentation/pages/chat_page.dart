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
        title: Row(
          children: [
            const Text(
              'Chats',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<chat.ChatBloc, chat.ChatState>(
        listener: (context, state) {
          if (state is chat.ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is chat.ChatLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<chat.ChatItem> chats = [];

          if (state is chat.ChatsLoadedState) {
            chats = state.filteredChats;
          }

          return Column(
            children: [
              // Search Bar
              ChatSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  GuestUtils.executeWithGuestCheck(
                    context,
                    'Chat Search',
                    () => context
                        .read<chat.ChatBloc>()
                        .add(chat.SearchChatsEvent(query)),
                  );
                },
              ),

              // Chat List
              Expanded(
                child: chats.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: EmptyChatState(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return ChatListItem(
                            chatItem: chat,
                            onTap: () => GuestUtils.executeWithGuestCheck(
                              context,
                              'Chat Messages',
                              () => _openChat(context, chat),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
