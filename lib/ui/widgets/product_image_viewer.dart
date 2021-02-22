import 'package:flutter/material.dart';

class ProductImageViewer extends StatefulWidget {
  final List images;

  ProductImageViewer({this.images});
  @override
  _ProductImageViewerState createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  int pageIndex = 0;
  void setIndex(int value) {
    setState(() {
      pageIndex = value;
    });
  }

  void setController(int value) {
    _pageController.animateToPage(value,
        duration: Duration(milliseconds: 200), curve: Curves.easeInCirc);
  }

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PageView(
            onPageChanged: (value) => setIndex(value),
            controller: _pageController,
            children: widget.images
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,vertical: 16
                    ),
                    child: Image.network(
                      e,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,vertical: 16
            ),
            child: ListView.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index) => Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setIndex(index);
                      setController(index);
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        color: pageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.network(widget.images[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  )
                ],
              ),
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      ],
    );
  }
}
