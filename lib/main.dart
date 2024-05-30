import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


//Defines the api and parses the data, taking the variables used to be fetched for the app.
Future<List<Team>> fetchData() async {
  final String apiKey = '97a89e360ca645578e61db4d4e270089';
  final Uri url = Uri.parse(' /v4/competitions/PL/standings');
  final Map<String, String> headers = {
    'X-Auth-Token': apiKey,
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> standings = responseData['standings'][0]['table'];
      return standings.map((teamData) => Team.fromJson(teamData)).toList();
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error fetching data: $error');
    return [];
  }
}

//For the goalscorers of the league.
Future<List<Scorers>> fetchScorerData() async {
  final String apiKey = '97a89e360ca645578e61db4d4e270089';
  final Uri scorerUrl = Uri.parse('http://api.football-data.org/v4/competitions/PL/scorers');
  final Map<String, String> headers = {
    'X-Auth-Token': apiKey,
  };

  try {
    final response = await http.get(scorerUrl, headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseScorerData = jsonDecode(response.body);
      if (responseScorerData.containsKey('scorers')) {
        final List<dynamic> scorers = responseScorerData['scorers'] ?? [];
        return scorers.map((scorerData) => Scorers.fromJson(scorerData)).toList();
      } else {
        print('No scorers data found');
        return [];
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error fetching data: $error');
    return [];
  }
}



void main() {
  runApp(MyApp());
}



class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late Future<List<Team>> futureTeams;
  @override

  int _selectedIndex = 0;

  // Navigate to the respective page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initState() {
    super.initState();
    futureTeams = fetchData(); // Call fetchData() when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premier League App',
          style: TextStyle(color: Colors.white, fontSize: 30.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
      ),


    //Background of home page
    body: Container(
      decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('asset/vecteezy_zigzag-blue-background-epl-premier-league-thumbnail-video_35674774.jpg'), // Path to your background image
        fit: BoxFit.cover,
    ),
    ),

      child: Center(
        child: _selectedIndex == 0
            ? ExtendableWidget()
            : _selectedIndex == 1
            ? StatsPage()
            : Text('Other Page Content'),
      ),
    ),
      //The bottom buttons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Stats',
            icon: Icon(Icons.info),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),

            ),
        ],
      ),
    );
  }
}
class ExtendableWidget extends StatefulWidget {
  @override
  _ExtendableWidgetState createState() => _ExtendableWidgetState();
}

class _ExtendableWidgetState extends State<ExtendableWidget> {
  late Future<List<Team>> futureTeams;

  @override
  void initState() {
    super.initState();
    futureTeams = fetchData(); // Call fetchData() when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
   return Column(
      children: <Widget>[
        Expanded(
          child: ExpansionTile(
            title: const Text('Standings', style: TextStyle(color: Colors.white)),
            children: <Widget>[
              FutureBuilder<List<Team>>(
                future: futureTeams,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    final teams = snapshot.data!;
                    return SizedBox(
                      height: 800.0,
                      child: ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return ListTile(
                            title: Text('${team.position}. ${team.name}',  style: TextStyle(color: Colors.white)),
                            subtitle: Text('Points: ${team.points}, Goals: ${team.goalsFor}, Goals Against: ${team.goalsAgainst}', style: TextStyle(color: Colors.white)),

                            leading: Image.network(team.crest, width: 50, height: 50, fit: BoxFit.cover),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeWidget(),
    );
  }
}

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Future<List<Scorers>> futureScorers;

  @override
  void initState() {
    super.initState();
    futureScorers = fetchScorerData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('asset/vecteezy_zigzag-blue-background-epl-premier-league-thumbnail-video_35674774.jpg'), // Path to your background image
        fit: BoxFit.cover,
        ),
        ),

      child: FutureBuilder<List<Scorers>>(
        future: futureScorers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final scorers = snapshot.data!;
            return ListView.builder(
              itemCount: scorers.length,
              itemBuilder: (context, index) {
                final scorer = scorers[index];
                return ListTile(
                  title: Text('${index + 1}. ${scorer.playerName}', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Goals: ${scorer.goalsScored}, Appearances: ${scorer.appearances}, Date of Birth: ${scorer.dateOfBirth}, Assists: ${scorer.assists}, Penalties: ${scorer.penaltiesScored}', style: TextStyle(color:Colors.white)),
                );
              },
            );
          }
        },
      ),
    ),
    );
  }
}



class Team {
  final String name;
  final int position;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final String crest;
  Team({required this.name, required this.position, required this.points, required this.goalsFor, required this.goalsAgainst, required this.crest});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['team']['name'],
      position: json['position'],
      points: json['points'],
      goalsFor: json['goalsFor'],
      goalsAgainst: json['goalsAgainst'],
      crest: json['team']['crest'],
    );
  }
}

class Scorers {
  final String playerName;
  final String position;
  final int goalsScored;
  final int appearances;
  final String dateOfBirth;
  final int assists;
  final int penaltiesScored;

  Scorers({
    required this.playerName,
    required this.position,
    required this.goalsScored,
    required this.appearances,
    required this.dateOfBirth,
    required this.assists,
    required this.penaltiesScored,
  });

  factory Scorers.fromJson(Map<String, dynamic> json) {
    return Scorers(
      playerName: json['player']['name'] ?? 'Unknown',
      position: json['position'] ?? 'Unknown',
      goalsScored: json['goals'] ?? 0,
      appearances: json['player']['appearances'] ?? 0,
      dateOfBirth: json['player']['dateOfBirth'] ?? 'Unknown',
      penaltiesScored: json['penalties'] ?? 0,
      assists: json['assists'] ?? 0,
    );
  }
}

