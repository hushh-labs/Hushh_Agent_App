import 'package:flutter/material.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(bool)? onValidationChanged;

  const EmailTextField({super.key, this.controller, this.onValidationChanged});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _controller.text;
    bool isValid = false;
    
    if (email.isEmpty) {
      setState(() {
        _errorText = null;
      });
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _errorText = 'Please enter a valid email address';
        });
      } else {
        setState(() {
          _errorText = null;
        });
        isValid = true;
      }
    }
    
    // Notify parent about validation status
    widget.onValidationChanged?.call(isValid);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.disabled,
        cursorColor: const Color.fromARGB(
          255,
          179,
          183,
          189,
        ).withValues(alpha: 0.5),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w300,
        ),
        keyboardType: TextInputType.emailAddress,
        controller: _controller,
        keyboardAppearance: Brightness.light,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: "Enter email address",
          errorText: _errorText,
          hintStyle: TextStyle(
            color: const Color.fromARGB(
              255,
              179,
              183,
              189,
            ).withValues(alpha: 0.5),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xff8391a1).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}