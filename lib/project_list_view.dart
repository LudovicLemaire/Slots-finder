import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import "string_extension.dart";

import 'main.dart';
import 'slots_view.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({Key? key}) : super(key: key);

  @override
  _ProjectListView createState() => _ProjectListView();
}

class _ProjectListView extends State<ProjectListView> {
  List<Map<String, dynamic>> _projects = [];
  bool _recievedRequest = false;

  void _setProjects(List<Map<String, dynamic>> newProjectList) {
    setState(() {
      _projects = newProjectList;
    });
  }

  void _setRecievedProject(bool v) {
    setState(() {
      _recievedRequest = v;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await getProjects(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _projects.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Material(
                child: ListView.separated(
                    itemCount: _projects.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _itemList(context, position);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    })),
          )
        : !_recievedRequest
            ? const SizedBox.shrink()
            : const Center(
                child: Padding(
                padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: Text(
                  'You don\'t have any project that are "waiting for correction"',
                  textAlign: TextAlign.center,
                ),
              ));
  }

  Widget _itemList(BuildContext context, int i) {
    return ListTile(
      title: Row(children: [
        const Icon(Icons.arrow_right),
        Text(
          (_projects[i]['project']['name'] as String).toTitleCase(),
        )
      ]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlotView(
              id: _projects[i]['current_team_id'],
              name: _projects[i]['project']['name'],
              slug: _projects[i]['project']['slug'],
            ),
          ),
        );
      },
    );
  }

  Future<bool> getProjects(BuildContext context) async {
    String userToken =
        Provider.of<GlobalViewModel>(context, listen: false).userToken;
    final responseProjects =
        await http.get(Uri.parse('https://api.intra.42.fr/v2/me/'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
    });

    if (responseProjects.statusCode != 200) {
      return false;
    } else {
      List<Map<String, dynamic>> pr = [];
      List<Map<String, dynamic>> projectList = List.from(
          (await jsonDecode(responseProjects.body))['projects_users']);
      for (var project in projectList) {
        if (project['status'] == 'waiting_for_correction') {
          pr.add(project);
        }
      }
      _setProjects(pr);
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
      _setRecievedProject(true);
      return true;
    }
  }
}
