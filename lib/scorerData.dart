import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
