import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  
  @override
  List<Object> get props => [];
}

class LoadChatsEvent extends ChatEvent {
  const LoadChatsEvent();
}

class SearchChatsEvent extends ChatEvent {
  final String query;

  const SearchChatsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;
  final bool isBot;

  const SendMessageEvent({
    required this.chatId,
    required this.message,
    this.isBot = false,
  });

  @override
  List<Object> get props => [chatId, message, isBot];
}

class OpenChatEvent extends ChatEvent {
  final String chatId;

  const OpenChatEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class UploadFileEvent extends ChatEvent {
  final String chatId;
  final String fileType;

  const UploadFileEvent({
    required this.chatId,
    required this.fileType,
  });

  @override
  List<Object> get props => [chatId, fileType];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState();
}

class ChatsLoadedState extends ChatState {
  final List<ChatItem> chats;
  final List<ChatItem> filteredChats;

  const ChatsLoadedState({
    required this.chats,
    required this.filteredChats,
  });

  @override
  List<Object> get props => [chats, filteredChats];
}

class ChatMessagesLoadedState extends ChatState {
  final String chatId;
  final List<ChatMessage> messages;

  const ChatMessagesLoadedState({
    required this.chatId,
    required this.messages,
  });

  @override
  List<Object> get props => [chatId, messages];
}

class MessageSentState extends ChatState {
  final ChatMessage message;

  const MessageSentState(this.message);

  @override
  List<Object> get props => [message];
}

class FileUploadingState extends ChatState {
  const FileUploadingState();
}

class FileUploadedState extends ChatState {
  final String fileName;
  final String analysisResult;

  const FileUploadedState({
    required this.fileName,
    required this.analysisResult,
  });

  @override
  List<Object> get props => [fileName, analysisResult];
}

class ChatErrorState extends ChatState {
  final String message;

  const ChatErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// Data Models
class ChatItem {
  final String id;
  final String title;
  final String subtitle;
  final String avatarIcon;
  final String avatarColor;
  final String? lastMessageTime;
  final bool isBot;

  const ChatItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.avatarIcon,
    required this.avatarColor,
    this.lastMessageTime,
    this.isBot = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatInitialState()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<SearchChatsEvent>(_onSearchChats);
    on<SendMessageEvent>(_onSendMessage);
    on<OpenChatEvent>(_onOpenChat);
    on<UploadFileEvent>(_onUploadFile);
  }

  List<ChatItem> _allChats = [];
  Map<String, List<ChatMessage>> _chatMessages = {};

  void _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoadingState());
    
    try {
      // TODO: Implement actual chat loading from repository
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for now
      _allChats = [
        const ChatItem(
          id: 'hushh_bot',
          title: 'Hushh Bot',
          subtitle: 'Talk to Hushh Bot / upload bills for\nInsights',
          avatarIcon: 'smart_toy',
          avatarColor: '#A342FF',
          isBot: true,
        ),
      ];

      // Initialize Hushh Bot with welcome message
      _chatMessages['hushh_bot'] = [
        ChatMessage(
          id: 'welcome_1',
          text: 'Hello! I\'m Hushh Bot. How can I help you today? You can upload bills for insights or ask me anything!',
          isBot: true,
          timestamp: DateTime.now(),
        ),
      ];
      
      emit(ChatsLoadedState(
        chats: _allChats,
        filteredChats: _allChats,
      ));
    } catch (e) {
      emit(ChatErrorState('Failed to load chats: ${e.toString()}'));
    }
  }

  void _onSearchChats(SearchChatsEvent event, Emitter<ChatState> emit) {
    if (state is ChatsLoadedState) {
      final currentState = state as ChatsLoadedState;
      final filteredChats = event.query.isEmpty 
        ? currentState.chats
        : currentState.chats.where((chat) =>
            chat.title.toLowerCase().contains(event.query.toLowerCase()) ||
            chat.subtitle.toLowerCase().contains(event.query.toLowerCase())
          ).toList();

      emit(ChatsLoadedState(
        chats: currentState.chats,
        filteredChats: filteredChats,
      ));
    }
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.message,
        isBot: event.isBot,
        timestamp: DateTime.now(),
      );

      _chatMessages[event.chatId] = [
        ...(_chatMessages[event.chatId] ?? []),
        message,
      ];

      emit(ChatMessagesLoadedState(
        chatId: event.chatId,
        messages: _chatMessages[event.chatId]!,
      ));

      // Simulate bot response if user sent message
      if (!event.isBot && event.chatId == 'hushh_bot') {
        await Future.delayed(const Duration(seconds: 1));
        
        final botResponse = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _getBotResponse(event.message),
          isBot: true,
          timestamp: DateTime.now(),
        );

        _chatMessages[event.chatId] = [
          ...(_chatMessages[event.chatId] ?? []),
          botResponse,
        ];

        emit(ChatMessagesLoadedState(
          chatId: event.chatId,
          messages: _chatMessages[event.chatId]!,
        ));
      }
    } catch (e) {
      emit(ChatErrorState('Failed to send message: ${e.toString()}'));
    }
  }

  void _onOpenChat(OpenChatEvent event, Emitter<ChatState> emit) async {
    try {
      final messages = _chatMessages[event.chatId] ?? [];
      
      emit(ChatMessagesLoadedState(
        chatId: event.chatId,
        messages: messages,
      ));
    } catch (e) {
      emit(ChatErrorState('Failed to open chat: ${e.toString()}'));
    }
  }

  void _onUploadFile(UploadFileEvent event, Emitter<ChatState> emit) async {
    emit(const FileUploadingState());
    
    try {
      // TODO: Implement actual file upload logic
      await Future.delayed(const Duration(seconds: 2));
      
      const analysisResult = 'Analysis complete! Here are some insights:\n\n• Total amount: \$125.50\n• Category: Utilities\n• Compared to last month: +15%\n• Tip: Consider energy-saving options to reduce costs.';
      
      // Add upload confirmation message
      final uploadMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'File uploaded successfully! I\'m analyzing your bill...',
        isBot: true,
        timestamp: DateTime.now(),
      );

      _chatMessages[event.chatId] = [
        ...(_chatMessages[event.chatId] ?? []),
        uploadMessage,
      ];

      emit(ChatMessagesLoadedState(
        chatId: event.chatId,
        messages: _chatMessages[event.chatId]!,
      ));

      // Add analysis result after delay
      await Future.delayed(const Duration(seconds: 1));
      
      final analysisMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: analysisResult,
        isBot: true,
        timestamp: DateTime.now(),
      );

      _chatMessages[event.chatId] = [
        ...(_chatMessages[event.chatId] ?? []),
        analysisMessage,
      ];

      emit(ChatMessagesLoadedState(
        chatId: event.chatId,
        messages: _chatMessages[event.chatId]!,
      ));
      
    } catch (e) {
      emit(ChatErrorState('Failed to upload file: ${e.toString()}'));
    }
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (message.contains('bill') || message.contains('upload')) {
      return 'Great! You can upload your bills and I\'ll provide insights. Just tap the attachment icon and select your file.';
    } else if (message.contains('help')) {
      return 'I can help you with:\n• Analyzing bills and expenses\n• Providing financial insights\n• Answering questions about your account\n• General assistance';
    } else {
      return 'Thanks for your message! I\'m here to help with bills analysis and insights. Feel free to upload any bills or ask me questions.';
    }
  }
} 