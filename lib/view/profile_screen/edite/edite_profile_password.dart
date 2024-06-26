import 'package:youmeya/consent/consent.dart';
import 'package:youmeya/controllers/profile_controller.dart';

class EditeProfilePassword extends StatelessWidget {
  const EditeProfilePassword({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProfileController());
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: borderColor,
                  ),
                ),
                const Text(
                  "Edite my Password",
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notification_add_outlined,
                      color: whiteColor),
                )
              ],
            ),
            20.heightBox,
            Obx(
              () => Column(
                children: [
                  40.heightBox,
                  customTextField(
                      title: "Password",
                      hint: "**********",
                      isPass: false,
                      controller: controller.newPassController),
                  20.heightBox,
                  controller.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(mainColor),
                        )
                      : SizedBox(
                          width: context.screenWidth - 60,
                          child: ourButton(
                              onPress: () async {
                                controller.isLoading(true);

                                // if all password matched data base
                                await controller.updateProfilePassword(
                                  password: controller.newPassController.text,
                                );
                                VxToast.show(context, msg: "Updated");
                                Get.back();
                                                            },
                              color: mainColor,
                              textColor: whiteColor,
                              title: "save")),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
