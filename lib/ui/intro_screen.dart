import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/core/view_models/introscreen_view_model/intro_screen_view_model_provider.dart';
import 'package:grocery_app/ui/home_page.dart';

class IntroScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    ///accessing live state from [IntroScreenViewModel] using [introScreenViewModelProvider]
    var introModel = watch(introScreenViewModelProvider);

    Widget _buildPageIndicator(bool isCurrentPage) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        height: isCurrentPage ? 10.0 : 6.0,
        width: isCurrentPage ? 10.0 : 6.0,
        decoration: BoxDecoration(
          color: isCurrentPage ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        ///TODO: edit [title] (name of your store or app)
        title: Text("Groccery"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: PageView(
          controller: introModel.controller,
          onPageChanged: introModel.setPage,
          children: <Widget>[
            ///here are 3 [SlideTile]
            ///TODO: Edit [title],["desc"],["imagePath"] is [SlideTiles] as per your store services, statements,...
            SlideTile(
              imagePath: "assets/vectorpaint.png",
              title: "Search",
              desc:
                  "Discover Restaurants offering the best fast food food near you on Foodwa",
            ),
            SlideTile(
              imagePath: "assets/vectorpaint.png",
              title: "Order",
              desc:
                  "Our veggie plan is filled with delicious seasonal vegetables, whole grains, beautiful cheeses and vegetarian proteins",
            ),
            SlideTile(
              imagePath: "assets/vectorpaint.png",
              title: "Eat",
              desc:
                  "Food delivery or pickup from local restaurants, Explore restaurants that deliver near you.",
            )
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ///[2] is (total number of [SlideTile]) - 1
          introModel.pageIndex != 2
              ? TextButton(
                  onPressed: () {
                    introModel.controller.animateToPage(2,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.linear);
                  },
                  child: Text(
                    "SKIP",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              : SizedBox(
                  width: 64,
                ),
          Row(
            children: [
              ///[3] is total number of [SlideTile]
              for (int i = 0; i < 3; i++)
                i == introModel.pageIndex
                    ? _buildPageIndicator(true)
                    : _buildPageIndicator(false),
            ],
          ),

          ///[2] is (total number of [SlideTile]) - 1
          introModel.pageIndex != 2
              ? TextButton(
                  onPressed: () {
                    introModel.controller.animateToPage(
                        introModel.pageIndex + 1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.linear);
                  },
                  child: Text(
                    "NEXT",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    introModel.saveSeen();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Text(
                    "DONE",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class SlideTile extends StatelessWidget {
  final String imagePath, title, desc;
  SlideTile({this.imagePath, this.title, this.desc});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/vectorpaint.png", height: 250),
          ),
          SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
