import 'package:flutter/material.dart';
import 'package:dolbyio_comms_sdk_flutter/dolbyio_comms_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/widgets/circular_progress_indicator.dart';
import '/widgets/dolby_title.dart';
import '/widgets/input_text_field.dart';
import '/widgets/primary_button.dart';
import '/widgets/text_form_field.dart';
import 'join_screen.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatelessWidget {

  const LoginScreen({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      child: Scaffold(
          body: Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  DolbyTitle(title: 'Dolby.io', subtitle: 'Flutter SDK',),
                  LoginScreenContent()
                ],
              )
          )
      ),
    );
  }
}

class LoginScreenContent extends StatefulWidget {

  const LoginScreenContent({Key? key}) : super(key: key);

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent> {
  final formKey = GlobalKey<FormState>();
  final _dolbyioCommsSdkFlutterPlugin = DolbyioCommsSdk.instance;
  TextEditingController accessTokenTextController = TextEditingController();
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController externalIdTextController = TextEditingController();
  late String? _sessionStatus, _accessToken;
  late SharedPreferences _preferences;
  String keyAccessToken = 'access token';
  bool isSessionOpen = false, isLogging = false, isInitialized = false;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    initSessionStatus();
  }

  Future<void> initSessionStatus() async {
    await _dolbyioCommsSdkFlutterPlugin.session.isOpen().then((isOpen) {
      if (isOpen) {
        setState(() {
          _sessionStatus = 'open';
          isSessionOpen = true;
        });
      } else {
        setState(() => _sessionStatus = 'close');
        isSessionOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        InputTextFormField(
                            labelText: 'Access token',
                            controller: accessTokenTextController,
                            focusColor: Colors.deepPurple
                        ),
                        const SizedBox(height: 16),
                        InputTextFormField(
                            labelText: 'Username',
                            controller: usernameTextController,
                            focusColor: Colors.deepPurple
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 16),
                InputTextField(
                    labelText: 'External ID (optional)',
                    controller: externalIdTextController,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                    color: Colors.deepPurple,
                    widgetText: isLogging
                        ? const WhiteCircularProgressIndicator()
                        : const Text('Login'),
                    onPressed: () { onLoginButtonPressed(); }
                )
              ],
            ),
          ),
        ),
      );
  }

  void onLoginButtonPressed() async {
    final isValidForm = formKey.currentState!.validate();
    if (isValidForm) {
      setState(() => isLogging = true);
      await initializeSdk();
      if(isInitialized){
        openSession();
      }
    } else {
      developer.log('Cannot log in');
    }
  }

  Future<void> initializeSdk() async {
    _accessToken = accessTokenTextController.text;
    await _dolbyioCommsSdkFlutterPlugin
        .initializeToken(_accessToken, () => getRefreshToken())
        .then((value) => setState(() => isInitialized = true))
        .onError((error, stackTrace) => onError('Error during initializing sdk', error));
    _preferences.setString(keyAccessToken, _accessToken ?? '');
  }

  void openSession() {
    var participantInfo = ParticipantInfo(usernameTextController.text, null, externalIdTextController.text);
    _dolbyioCommsSdkFlutterPlugin.session
        .open(participantInfo)
        .then((value) => checkSessionStatus())
        .onError((error, stackTrace) {
      setState(() => isLogging = false);
      onError('Error during opening session', error);
    });
  }

  void checkSessionStatus() async {
    await initSessionStatus();
    developer.log('Session is: $_sessionStatus');
    if (isSessionOpen) navigateToJoinConference();
  }

  void navigateToJoinConference() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) =>
            JoinConference(username: usernameTextController.text)
        )
    );
    setState(() => isLogging = false);
  }

  Future<String?> getRefreshToken() async {
    return _accessToken;
  }

  void onError(String message, Object? error) {
    developer.log(message, error: error);
  }

  Future initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();

    _accessToken = _preferences.getString(keyAccessToken);
    setState(() => accessTokenTextController.text = _accessToken ?? '');
  }
}
