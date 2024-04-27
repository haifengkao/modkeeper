import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class ExpandableListScreen extends StatelessWidget {
  final List<ListItem> items = List.generate(
    5,
    (index) => ListItem(
      title: 'Item $index',
      subItems: List.generate(
        3,
        (subIndex) => SubItem(
          title: 'Sub Item $subIndex',
          isChecked: false,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expandable List'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ExpandableListItem(item: item);
        },
      ),
    );
  }
}

class ExpandableListItem extends StatefulWidget {
  final ListItem item;

  const ExpandableListItem({required this.item});

  @override
  _ExpandableListItemState createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.item.title),
          onTap: _toggleExpansion,
        ),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: widget.item.subItems.map((subItem) {
                return CheckboxListTile(
                  title: Text(subItem.title),
                  value: subItem.isChecked,
                  onChanged: (value) {
                    setState(() {
                      subItem.isChecked = value!;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class ListItem {
  final String title;
  final List<SubItem> subItems;

  ListItem({required this.title, required this.subItems});
}

class SubItem {
  String title;
  bool isChecked;

  SubItem({required this.title, required this.isChecked});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModKeeper',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
    home: ExpandableListScreen(),
    );
  }
}

