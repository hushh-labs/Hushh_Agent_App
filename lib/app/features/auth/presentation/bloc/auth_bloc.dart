import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../data/models/countries_model.dart';
import '../../domain/usecases/send_phone_otp_usecase.dart';
import '../../domain/usecases/verify_phone_otp_usecase.dart';
import '../../domain/usecases/send_email_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import '../../domain/usecases/check_agent_card_exists_usecase.dart';
import '../../domain/usecases/create_agent_card_usecase.dart';
import '../../domain/entities/agent_card.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/enum.dart';

import '../../../../../shared/core/routing/routes.dart';
import '../pages/otp_verification.dart';

// Events
abstract class AuthEvent {}

class InitializeEvent extends AuthEvent {
  final bool shouldInitialize;
  InitializeEvent(this.shouldInitialize);
}

class OnCountryUpdateEvent extends AuthEvent {
  final BuildContext context;
  OnCountryUpdateEvent(this.context);
}

class OnPhoneUpdateEvent extends AuthEvent {
  final String value;
  OnPhoneUpdateEvent(this.value);
}

class SendPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;
  SendPhoneOtpEvent(this.phoneNumber);
}

class VerifyPhoneOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;
  VerifyPhoneOtpEvent({required this.phoneNumber, required this.otp});
}

class SendEmailOtpEvent extends AuthEvent {
  final String email;
  SendEmailOtpEvent(this.email);
}

class VerifyEmailOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  VerifyEmailOtpEvent({required this.email, required this.otp});
}

class CheckAgentCardEvent extends AuthEvent {
  final String agentId;
  CheckAgentCardEvent(this.agentId);
}

class CreateAgentCardEvent extends AuthEvent {
  final AgentCard agentCard;
  CreateAgentCardEvent(this.agentCard);
}

class SignOutEvent extends AuthEvent {}

class CheckAuthStateEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class InitializingState extends AuthState {
  final bool isInitState;
  InitializingState(this.isInitState);
}

class InitializedState extends AuthState {}

class CountryUpdatingState extends AuthState {}

class CountryUpdatedState extends AuthState {}

class PhoneUpdatingState extends AuthState {}

class PhoneUpdatedState extends AuthState {}

class SendingOtpState extends AuthState {}

class OtpSentState extends AuthState {}

class OtpSentFailureState extends AuthState {
  final String message;
  OtpSentFailureState(this.message);
}

class VerifyingOtpState extends AuthState {}

class OtpVerifiedState extends AuthState {
  final firebase_auth.UserCredential userCredential;
  OtpVerifiedState(this.userCredential);
}

class OtpVerificationFailureState extends AuthState {
  final String message;
  OtpVerificationFailureState(this.message);
}

class CheckingAgentCardState extends AuthState {}

class AgentCardExistsState extends AuthState {
  final bool exists;
  AgentCardExistsState(this.exists);
}

class AgentCardCheckFailureState extends AuthState {
  final String message;
  AgentCardCheckFailureState(this.message);
}

class CreatingAgentCardState extends AuthState {}

class AgentCardCreatedState extends AuthState {}

class AgentCardCreationFailureState extends AuthState {
  final String message;
  AgentCardCreationFailureState(this.message);
}

class SigningOutState extends AuthState {}

class SignedOutState extends AuthState {}

class SignOutFailureState extends AuthState {
  final String message;
  SignOutFailureState(this.message);
}

class AuthStateCheckedState extends AuthState {
  final bool isAuthenticated;
  final firebase_auth.User? user;
  AuthStateCheckedState({required this.isAuthenticated, this.user});
}

// Country Masks
const Map<String, String> countryMasks = {
  'US': '+1 (###) ###-####',
  'IN': '+91 ##### #####',
  'GB': '+44 #### ######',
  'CA': '+1 (###) ###-####',
  'AU': '+61 ### ### ###',
  'DE': '+49 ### #######',
  'FR': '+33 # ## ## ## ##',
  'IT': '+39 ### ### ####',
  'ES': '+34 ### ### ###',
  'BR': '+55 ## ##### ####',
  'MX': '+52 ### ### ####',
  'JP': '+81 ## #### ####',
  'KR': '+82 ## #### ####',
  'CN': '+86 ### #### ####',
  'RU': '+7 ### ### ####',
  'ZA': '+27 ## ### ####',
  'NG': '+234 ### ### ####',
  'EG': '+20 ### ### ####',
  'KE': '+254 ### ### ###',
  'GH': '+233 ## ### ####',
};

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late List<Country> _countryList;
  late List<Country> filteredCountries;
  late TextEditingController phoneController;
  var phoneNumberWithoutCountryCode = "";
  Country? selectedCountry;

  // Use cases
  final SendPhoneOtpUseCase _sendPhoneOtpUseCase;
  final VerifyPhoneOtpUseCase _verifyPhoneOtpUseCase;
  final SendEmailOtpUseCase _sendEmailOtpUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final CheckAgentCardExistsUseCase _checkAgentCardExistsUseCase;
  final CreateAgentCardUseCase _createAgentCardUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthBloc({
    required SendPhoneOtpUseCase sendPhoneOtpUseCase,
    required VerifyPhoneOtpUseCase verifyPhoneOtpUseCase,
    required SendEmailOtpUseCase sendEmailOtpUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required CheckAgentCardExistsUseCase checkAgentCardExistsUseCase,
    required CreateAgentCardUseCase createAgentCardUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _sendPhoneOtpUseCase = sendPhoneOtpUseCase,
       _verifyPhoneOtpUseCase = verifyPhoneOtpUseCase,
       _sendEmailOtpUseCase = sendEmailOtpUseCase,
       _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
       _checkAgentCardExistsUseCase = checkAgentCardExistsUseCase,
       _createAgentCardUseCase = createAgentCardUseCase,
       _signOutUseCase = signOutUseCase,
       super(AuthInitialState()) {
    on<InitializeEvent>(onInitializeEvent);
    on<OnCountryUpdateEvent>(onCountryUpdateEvent);
    on<OnPhoneUpdateEvent>(onPhoneUpdateEvent);
    on<SendPhoneOtpEvent>(onSendPhoneOtpEvent);
    on<VerifyPhoneOtpEvent>(onVerifyPhoneOtpEvent);
    on<SendEmailOtpEvent>(onSendEmailOtpEvent);
    on<VerifyEmailOtpEvent>(onVerifyEmailOtpEvent);
    on<CheckAgentCardEvent>(onCheckAgentCardEvent);
    on<CreateAgentCardEvent>(onCreateAgentCardEvent);
    on<SignOutEvent>(onSignOutEvent);
    on<CheckAuthStateEvent>(onCheckAuthStateEvent);

    // Initialize immediately
    _initializeCountries();

    // Listen to authentication state changes
    _listenToAuthStateChanges();
  }

  void _initializeCountries() {
    _countryList = countries;
    selectedCountry = _countryList.firstWhere(
      (item) => item.code == "IN",
      orElse: () => _countryList.first,
    );
    filteredCountries = _countryList;
    phoneController = TextEditingController();
  }

  void _listenToAuthStateChanges() {
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User is signed in
        add(CheckAuthStateEvent());
      } else {
        // User is signed out
        add(SignOutEvent());
      }
    });
  }

  FutureOr<void> onInitializeEvent(
    InitializeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(InitializingState(event.shouldInitialize));

    _countryList = countries;
    selectedCountry = _countryList.firstWhere(
      (item) => item.code == "IN",
      orElse: () => _countryList.first,
    );
    _countryList = countries;
    filteredCountries = _countryList;

    // Clear the phone controller to prevent auto-fill
    phoneController.clear();
    phoneNumberWithoutCountryCode = "";

    emit(InitializedState());
  }

  FutureOr<void> onPhoneUpdateEvent(
    OnPhoneUpdateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(PhoneUpdatingState());

    // Store only the digits from the phone number (without country code)
    final phoneDigits = phoneController.text
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    phoneNumberWithoutCountryCode = phoneDigits;

    // Check if phone number is complete based on country
    int phoneLengthBasedOnCountryCode = countries
        .firstWhere((element) => element.code == selectedCountry!.code)
        .maxLength;

    if (phoneDigits.length == phoneLengthBasedOnCountryCode) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    emit(PhoneUpdatedState());
  }

  FutureOr<void> onSendPhoneOtpEvent(
    SendPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(SendingOtpState());

    final params = SendPhoneOtpParams(
      phoneNumber: event.phoneNumber,
      onOtpSent: (phoneNumber) {
        // Navigation will be handled by the UI layer, not in BLoC
        // The UI can listen to OtpSentState and navigate accordingly
      },
    );

    final result = await _sendPhoneOtpUseCase(params);

    if (result is Success<void>) {
      emit(OtpSentState());
    } else if (result is Failed<void>) {
      emit(OtpSentFailureState(result.failure.message));
    }
  }

  FutureOr<void> onVerifyPhoneOtpEvent(
    VerifyPhoneOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingOtpState());

    try {
      // Create parameters for phone OTP verification
      final params = VerifyPhoneOtpParams(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );

      final result = await _verifyPhoneOtpUseCase(params);

      if (result is Success<firebase_auth.UserCredential>) {
        // Emit success state with Firebase user credential
        emit(OtpVerifiedState(result.data));
        
        // Check if agent card exists and handle accordingly
        final user = result.data.user;
        if (user != null) {
          add(CheckAgentCardEvent(user.uid));
        }
      } else if (result is Failed<firebase_auth.UserCredential>) {
        emit(OtpVerificationFailureState(result.failure.message));
      }
    } catch (e) {
      emit(OtpVerificationFailureState('OTP verification failed: ${e.toString()}'));
    }
  }

  FutureOr<void> onSendEmailOtpEvent(
    SendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(SendingOtpState());

    final params = SendEmailOtpParams(email: event.email);
    final result = await _sendEmailOtpUseCase(params);

    if (result is Success<void>) {
      emit(OtpSentState());
    } else if (result is Failed<void>) {
      emit(OtpSentFailureState(result.failure.message));
    }
  }

  FutureOr<void> onVerifyEmailOtpEvent(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingOtpState());

    try {
      // Create parameters for email OTP verification
      final params = VerifyEmailOtpParams(
        email: event.email,
        otp: event.otp,
      );

      final result = await _verifyEmailOtpUseCase(params);

      if (result is Success<firebase_auth.UserCredential>) {
        // Emit success state with Firebase user credential
        emit(OtpVerifiedState(result.data));
        
        // Check if agent card exists and handle accordingly
        final user = result.data.user;
        if (user != null) {
          add(CheckAgentCardEvent(user.uid));
        }
      } else if (result is Failed<firebase_auth.UserCredential>) {
        emit(OtpVerificationFailureState(result.failure.message));
      }
    } catch (e) {
      emit(OtpVerificationFailureState('Email OTP verification failed: ${e.toString()}'));
    }
  }

  FutureOr<void> onCheckAgentCardEvent(
    CheckAgentCardEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckingAgentCardState());

    final result = await _checkAgentCardExistsUseCase(
      CheckAgentCardExistsParams(agentId: event.agentId),
    );

    if (result is Success<bool>) {
      emit(AgentCardExistsState(result.data));
    } else if (result is Failed<bool>) {
      emit(AgentCardCheckFailureState(result.failure.message));
    }
  }

  FutureOr<void> onCreateAgentCardEvent(
    CreateAgentCardEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CreatingAgentCardState());

    final result = await _createAgentCardUseCase(
      CreateAgentCardParams(agentCard: event.agentCard),
    );

    if (result is Success<void>) {
      emit(AgentCardCreatedState());
    } else if (result is Failed<void>) {
      emit(AgentCardCreationFailureState(result.failure.message));
    }
  }

  FutureOr<void> onSignOutEvent(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(SigningOutState());

    final result = await _signOutUseCase();

    if (result is Success<void>) {
      emit(SignedOutState());
    } else if (result is Failed<void>) {
      emit(SignOutFailureState(result.failure.message));
    }
  }

  FutureOr<void> onCheckAuthStateEvent(
    CheckAuthStateEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final isAuthenticated = currentUser != null;
    emit(
      AuthStateCheckedState(
        isAuthenticated: isAuthenticated,
        user: currentUser,
      ),
    );
  }

  FutureOr<void> onCountryUpdateEvent(
    OnCountryUpdateEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CountryUpdatingState());
    bool isNumeric(String s) => s.isNotEmpty && double.tryParse(s) != null;

    filteredCountries = _countryList;
    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: event.context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (ctx, setStateCountry) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF7f7f97), width: 0.5),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                height: 40,
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                child: TextField(
                  onChanged: (value) {
                    filteredCountries = isNumeric(value)
                        ? _countryList
                              .where(
                                (country) => country.dialCode.contains(value),
                              )
                              .toList()
                        : _countryList
                              .where(
                                (country) => country.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
                              .toList();
                    setStateCountry(() {});
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: 'Search country',
                    hintStyle: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  itemBuilder: (ctx, index) => Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          selectedCountry = filteredCountries[index];
                          // Clear phone controller when country changes to prevent auto-fill
                          phoneController.clear();
                          phoneNumberWithoutCountryCode = "";
                          Navigator.of(context).pop();
                          FocusScope.of(context).unfocus();
                        },
                        leading: Text(
                          filteredCountries[index].flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          filteredCountries[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        trailing: Text(
                          '+${filteredCountries[index].dialCode}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Divider(thickness: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    emit(CountryUpdatedState());
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    return super.close();
  }
}