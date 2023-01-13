import 'package:chats_app/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../utils/const_value.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final RoundedLoadingButtonController roundedLoadingButtonController =
      RoundedLoadingButtonController();

  late AnimationController _animationController;

  final globalKey = GlobalKey<FormState>();
  late Animation<Alignment> tween;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    tween =
        Tween<Alignment>(end: Alignment.center, begin: Alignment.topCenter)
            .animate(CurvedAnimation(curve: Curves.bounceOut, parent: _animationController));
    _animationController.forward();
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ConstValue.backgroundColor,
        body: Form(
          key: globalKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              child:AlignTransition(
                alignment: tween,
                child: Card(
                  elevation: ConstValue.btnElevation,
                  color: ConstValue.frontColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ///          textfield for name .........................................................
                        TextFormField(
                          controller: nameController,
                          validator: nullValidation,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: ConstValue.textFillColor,
                              border: const OutlineInputBorder(),
                              hintText: 'Name'),
                        ),

                        ///          textfield for number .........................................................

                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            validator: phoneNumberValidation,
                            keyboardType: TextInputType.phone,
                            controller: numberController,
                            maxLength: 13,
                            decoration: InputDecoration(
                              hintText: 'Number',
                              filled: true,
                              fillColor: ConstValue.textFillColor,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),

                        ///          button for verification .........................................................

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RoundedLoadingButton(
                              controller: roundedLoadingButtonController,
                              color: Colors.indigoAccent,
                              elevation: ConstValue.btnElevation,
                              onPressed: () async {
                                if (globalKey.currentState!.validate()) {
                                  ConstValue.prefs!.setString(
                                      ConstValue.userNumber,
                                      numberController.text.toString());
                                await  ConstValue.prefs!.setString(
                                      ConstValue.userName,
                                      nameController.text.toString());
                                  await phoneVerification(
                                      roundController: roundedLoadingButtonController,
                                      context: context);
                                }
                              },
                              child: const Text('Login')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              builder: (context, child) =>   child!,
            ),
          ),
        ));
  }
}
