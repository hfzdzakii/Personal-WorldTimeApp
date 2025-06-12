import 'package:flutter/material.dart';
import 'package:a_world_time_app/services/world_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

  List<WorldTime> locations = [
    WorldTime(url: 'Europe/London', location: 'London', flag: 'uk.png'),
    WorldTime(url: 'Europe/Berlin', location: 'Athens', flag: 'greece.png'),
    WorldTime(url: 'Africa/Cairo', location: 'Cairo', flag: 'egypt.png'),
    WorldTime(url: 'Africa/Nairobi', location: 'Nairobi', flag: 'kenya.png'),
    WorldTime(url: 'America/Chicago', location: 'Chicago', flag: 'usa.png'),
    WorldTime(url: 'America/New_York', location: 'New York', flag: 'usa.png'),
    WorldTime(url: 'Asia/Seoul', location: 'Seoul', flag: 'south_korea.png'),
    WorldTime(url: 'Asia/Jakarta', location: 'Jakarta', flag: 'indonesia.png'),
  ];

  List<String> allZones = [];

  Future<void> safePrefs(WorldTime args) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('location', args.location);
    await prefs.setString('flag', args.flag);
    await prefs.setString('url', args.url);
  }

  void updateTime(index) async {
    WorldTime instance = locations[index];
    bool success = await instance.getTime();
    if (!success) return;
    await safePrefs(instance);
    if (!mounted) return;
    Navigator.pop(
      context,
      {
        'location': instance.location,
        'flag': instance.flag,
        'time': instance.time,
        'isDayTime': instance.isDayTime,
      },
    );
  }

  final TextEditingController _controller = TextEditingController();

  void handleSubmit() async {
    String texts = _controller.text.trim();
    List<String>text = texts.split('/');
    FocusScope.of(context).unfocus();
    if (texts.isNotEmpty) {
      _controller.clear();
      WorldTime instance = WorldTime(location: text[text.length-1], flag: '-', url: texts);
      bool success = await instance.getTime();
      if (!success) return;
      await safePrefs(instance);
      if (!mounted) return;
      Navigator.pop(
        context,
        {
          'location': instance.location,
          'flag': instance.flag,
          'time': instance.time,
          'isDayTime': instance.isDayTime,
        },
      );
    }
  }

  void callTimeZones() {
    ListTimeZone timeZones = ListTimeZone();
    timeZones.getTimeZones().then((dataZones) {
      if (!mounted) return;
      setState(() {
        allZones = List<String>.from(dataZones);
      });
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callTimeZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          'Choose a Location',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            allZones.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator()
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return allZones.where((option) {
                            return option.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                          });
                        },
                        onSelected: (String option) {
                          _controller.text = option;
                        },
                                              
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          // _controller.text = textEditingController.text;
                          return TextField(
                            controller: textEditingController, //=====
                            focusNode: focusNode,
                            onEditingComplete: onFieldSubmitted,
                            onSubmitted: (_) => handleSubmit(),
                            decoration: InputDecoration(
                              labelText: 'Search Timezone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              borderRadius: BorderRadius.circular(10.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 32,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index){
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: (){
                                        onSelected(option);
                                      },
                                    );
                                  }
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: handleSubmit,
                      icon: Icon(Icons.send),
                      tooltip: 'Submit',
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 4.0),
                    child: Card(
                      child: ListTile(
                        tileColor: Colors.grey[100],
                        onTap: () {
                          updateTime(index);
                        },
                        title: Text(locations[index].location),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/flags/${locations[index].flag}'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

                  // Expanded(
                  //   child: TextField(
                  //     controller: _controller,
                  //     onSubmitted: (_) => handleSubmit(),
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(30.0),
                  //       ),
                  //       label: Text('Input Region/City'),
                  //     ),
                  //   ),
                  // ),