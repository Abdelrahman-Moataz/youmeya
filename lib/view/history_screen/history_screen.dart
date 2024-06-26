import 'package:youmeya/consent/consent.dart';
import 'package:youmeya/controllers/card_controller.dart';
import 'package:youmeya/view/history_screen/history_widget/card_wdget.dart';
import 'package:youmeya/view/history_screen/history_widget/notification.dart';
import 'package:youmeya/view/order_details/order_details.dart';

import '../../services/firestore_services.dart';



class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

   var controller = Get.put(CartController());

    return SafeArea(
      child: Scaffold(

        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(""),
                  const Text(
                    "History",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  notificationWidget(h: h * 0.05),
                ],
              ),
              20.heightBox,
              SizedBox(
                height: h * 0.76,
                child: StreamBuilder(
                  stream: FireStoreServices.getAllOrders(currentUser!.uid),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(mainColor),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: "No order yet".text.color(bottom).make(),
                      );
                    } else {
                      var data = snapshot.data!.docs;

                      return ListView(
                          shrinkWrap: true,

                          children: List.generate(
                        data.length,
                        (index) => CardWidget(
                            onpress: ()async {
                              await controller.updateOrderStatus(
                                review: controller.reviewController.text,
                                rating: controller.ratingReviewController.text,
                                  orderId: data[index].id,);

                            },
                            date: data[index]['order_date'],

                            orderStatus: data[index]['order_placed']==true &&
                                data[index]['order_confirmed']==false &&
                                data[index]['order_on_delivery']==false &&
                                data[index]['order_delivered']==false

                                ? "order Placed":
                            data[index]['order_placed']==true &&
                                data[index]['order_confirmed']==true &&
                                data[index]['order_on_delivery']==false &&
                                data[index]['order_delivered']==false  ?
                                "Confirmed" :
                            data[index]['order_placed']==true &&
                                data[index]['order_confirmed']==true &&
                                data[index]['order_on_delivery']==true &&
                                data[index]['order_delivered']==false  ?
                                "order on delivery" :
                            data[index]['order_placed']==true &&
                                data[index]['order_confirmed']==true &&
                                data[index]['order_on_delivery']==true &&
                                data[index]['order_delivered']==true ?
                                "Order delivered" : "Done"
                            ,
                            OrderNumber: data[index]['order_code'],
                            context1: context,
                            number: data[index]['orders'].length.toString(),
                            context2: context,
                            onTap: () {
                              Get.to(() =>  OrderDetails(
                                title: data[index]['collection_id'],
                              ));
                            }),
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
