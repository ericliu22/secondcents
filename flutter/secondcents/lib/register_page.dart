import 'package:flutter/material.dart';
import 'package:secondcents/globals.dart';
import 'package:secondcents/schemas/user.dart';
import 'package:realm/realm.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();

  static final fullNameValidCharacters =
      RegExp(r'^[a-zA-Z0-9]+(?:\s[a-zA-Z0-9]+)*$');
  static final usernameValidCharacters = RegExp(r'^[a-zA-Z0-9]*$');

  String _msg = '';

  Future fullNameTest() async {
    if (_fullNameController.text.toString().toLowerCase().trim() == '') {
      setState(
        () {
          _msg = 'Please enter your full name.';
        },
      );
    } else if (!fullNameValidCharacters
            .hasMatch(_fullNameController.text.toString().trim()) ||
        _fullNameController.text.toString().trim().contains("_")) {
      setState(
        () {
          _msg = 'Full name contains invalid characters';
        },
      );
    } else {
      setState(
        () {
          _msg = '';
        },
      );
      usernameUniqueTest();
    }
  }

  Future usernameUniqueTest() async {
    await FirebaseFirestore.instance
        .collection('users')
        .limit(1)
        .where('Username',
            isEqualTo: _usernameController.text.toString().trim())
        .get()
        .then(
          (querySnapshot) => querySnapshot.docs.forEach(
            (result) {
              if (result.get != null) {
                // print(querySnapshot);
                setState(
                  () {
                    _msg = 'The username you entered is already taken.';
                  },
                );
              }
            },
          ),
        );

    if (!usernameValidCharacters
            .hasMatch(_usernameController.text.toString().trim()) ||
        _usernameController.text.toString().trim().contains(" ") ||
        _usernameController.text.toString().trim().contains("_")) {
      setState(
        () {
          _msg = 'Username contains invalid characters';
        },
      );
    } else if (_usernameController.text.toString().trim() == '') {
      setState(
        () {
          _msg = 'Please enter a username.';
        },
      );
    } else if (_msg == 'The username you entered is already taken.') {
      print('damn');
    } else {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return CreateProfilePage();
      //     },
      //   ),
      // );
      signUp();
    }
  }

  //check if password matches
  bool passwordConfirmed() {
    if (_passwordController.text.toString().trim() ==
        _confirmPasswordController.text.toString().trim()) {
      return true;
    } else {
      return false;
    }
  }

  Future signUp() async {
    try {
      if (passwordConfirmed()) {
        //create user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.toString().trim(),
            password: _passwordController.text.toString().trim());

        final user = FirebaseAuth.instance.currentUser!;
        //add user details
        addUserDetails(
          _fullNameController.text.toString().trim(),
          _usernameController.text.toString().toLowerCase().trim(),
          _emailController.text.toString().toLowerCase().trim(),
          user.uid,
        );

        setState(
          () {
            _msg = '';
          },
        );
      } else {
        setState(
          () {
            _msg = 'The passwords you entered do not match.';
          },
        );
      }
      //go to createprofile page

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return CreateProfilePage();
      //     },
      //   ),
      // );

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              const CreateProfilePage(),
          transitionDuration: const Duration(microseconds: 0),
          reverseTransitionDuration: const Duration(microseconds: 0),
        ),
      );

      // profileConfigured = false;
    } on FirebaseAuthException catch (e) {
      setState(
        () {
          _msg = e.message!;
        },
      );
    }
  }

  //adding new user
  Future addUserDetails(
      String fullname, String username, String email, String uid) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(uid);

    final json = ({
      'Full Name': fullname,
      'Username': username,
      'Email': email,
      'uid': uid,
      'imageUrl': '',
      'Bio': '',
      'Metrics': {
        'Following': [],
        'Followers': [],
        'Cents': 0,
      },
      'SeenPosts': [],
      'keywords': {},
      'Notifications': {},
    });
    await docUser.set(json).then((value) {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //spacer

                const SizedBox(height: 60),
                //TwoCent Logo
                GradientText(
                  'TwoCents',
                  style: Theme.of(context).textTheme.headline1,
                  gradient: LinearGradient(
                    colors: [
                      gradientTop,
                      gradientBottom,
                    ],
                    // begin: Alignment.topCenter,
                    // end: Alignment.bottomCenter,
                  ),
                ),

                //spacer
                const SizedBox(height: 0),

                Text(
                  'Sign up. It\'s easy!',
                  style: Theme.of(context).textTheme.headline4,
                ),

                //spacer
                const SizedBox(height: 30),

                //Name textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        style: Theme.of(context).textTheme.headline4,
                        controller: _fullNameController,
                        maxLength: 30,
                        autocorrect: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //spacer
                const SizedBox(height: 10),

                //Username textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        style: Theme.of(context).textTheme.headline4,
                        controller: _usernameController,
                        maxLength: 30,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //spacer
                const SizedBox(height: 10),

                //Email textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        style: Theme.of(context).textTheme.headline4,
                        controller: _emailController,
                        maxLength: 320,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //spacer
                const SizedBox(height: 10),

                //Password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        style: Theme.of(context).textTheme.headline4,
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //spacer
                const SizedBox(height: 10),

                //confirm password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        style: Theme.of(context).textTheme.headline4,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //spacer
                const SizedBox(height: 10),

                //sign up button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(
                    onTap: fullNameTest,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: customBlack,
                        // gradient: LinearGradient(
                        //   colors: [
                        //     gradientTop,
                        //     gradientBottom,
                        //     // Colors.white,
                        //     // Colors.white,
                        //   ],
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        // ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style:
                              Theme.of(context).textTheme.headline3?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),

                //sized
                const SizedBox(height: 30),

                //log in

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Login now',
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),

                //spacer
                const SizedBox(height: 10),

                SizedBox(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      // _msg != '' ? _msg : "",
                      _msg == 'The email address is badly formatted.'
                          ? 'Please enter a valid email address.'
                          : _msg != ''
                              ? _msg
                              : "",
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
