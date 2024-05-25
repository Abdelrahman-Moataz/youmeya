import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youmeya/consent/consent.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>(); // Add GlobalKey<FormState>

  ///text controller

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var languageController = TextEditingController();
  var passwordRetypeController = TextEditingController();
  var nameController = TextEditingController();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var addressController = TextEditingController();
  var moreDetailsController = TextEditingController();
  var buildingNameController = TextEditingController();
  var buildingNumberController = TextEditingController();
  var floorNumberController = TextEditingController();
  var flatNumberController = TextEditingController();

  ///login method

  Future<UserCredential?> loginMethod(
      {required BuildContext context,
      required TextEditingController emailController,
      required TextEditingController passwordController}) async {
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      print(currentUser);
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      print(e.toString());
      switch (e.code) {
        case ' 3583':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        default:
          errorMessage = e.code;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }

    return userCredential;
  }

  // Future<UserCredential?> loginMethod({context}) async {
  //   UserCredential? userCredential;
  //
  //   try {
  //     userCredential = await auth.signInWithEmailAndPassword(
  //         email: emailController.text, password: passwordController.text);
  //   } on FirebaseAuthException catch (e) {
  //     VxToast.show(context, msg: e.toString());
  //   }
  //   return userCredential;
  // }

  ///signup method

  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
      print(currentUser);
      print(userCredential);

    }
    return userCredential;
  }

  ///storing data method
  storeUserData({password, email}) async {
    DocumentReference store =
        fireStore.collection(userCollection).doc(currentUser!.uid);
    store.set({
      'name': "name",
      'password': password,
      'email': email,
      'imageUrl': '',
      'phone_number': "",
      'id': currentUser!.uid,
    });
  }

  ///storing complete reg method

  storeUserCompleteData({
    name,
    phoneNumber,
  }) async {
    DocumentReference store =
        fireStore.collection(userCollection).doc(currentUser!.uid);
    store.update({
      'name': name,
      'phone_number': phoneNumber,
      'id': currentUser!.uid,
    });
  }

  /// sstore the location data

  storeUserLocationData(
      {address,
      buildingName,
      buildingNumber,
      floorNumber,
      flatNumber,
      moreDetails}) async {
    DocumentReference store = fireStore.collection(locationCollection).doc();
    store.set({
      'address': address,
      'buildingName': buildingName,
      'buildingNumber': buildingNumber,
      'floorNumber': floorNumber,
      'flatNumber': flatNumber,
      'moreDetails': moreDetails,
      'id': currentUser!.uid,
    });
  }

  /// google signup method

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> storeUserDataToFirestore(
      UserCredential userCredential, File image) async {
    User user = userCredential.user!;

    // Upload image to Firebase Storage
    String imageURL = await uploadImageToStorage(image, user.uid);

    // Store user data including image URL in Firestore
    FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': imageURL,
      // Add more fields as needed
    });
  }

  Future<String> uploadImageToStorage(File imageFile, String userID) async {
    // Get a reference to the storage service
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$userID.jpg');

    // Upload file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Await the upload completion and get the image URL
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageURL = await taskSnapshot.ref.getDownloadURL();

    return imageURL;
  }

  ///signOut method

  signOutMethod(BuildContext context) async {
    try {
      // Sign out from the authentication service
      await auth.signOut();
      await currentUser!.delete();
      VxToast.show(context, msg: "Signed out successfully.");
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  Future<void> clearAppData() async {
    // Clear files stored in the app's directory
    final appDir = await getApplicationDocumentsDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }

    // Clear temporary directory
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  }
}
