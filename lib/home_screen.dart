import 'package:flutter/material.dart';
import 'package:fluttercrud/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  //Gets all the data from the DB
  void _refreshData() async {
    final data = await SQLHelper.getData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  //Adds a record to the DB
  Future<void> _addData() async {
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

  //Updates a record in the db
  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

  //Deletes a record from the db
  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.white,
      content: Text(
        "Deleted!",
        style: TextStyle(color: Colors.indigo),
      ),
    ));
    _refreshData();
  }

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData["title"];
      _descController.text = existingData["desc"];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 5,
        context: context,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 30,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Title"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: "Description"),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addData();
                        }
                        if (id != null) {
                          await _updateData(id);
                        }
                        _titleController.text = "";
                        _descController.text = "";
                        //Hides the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          id == null ? "Add" : "Update",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text("Poly-Crud"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allData.length,
              itemBuilder: (context, index) => Card(
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _allData[index]['title'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      subtitle: Text(_allData[index]['desc']),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            onPressed: () {showBottomSheet(_allData[index]['id']);},
                            icon: Icon(Icons.edit, color: Colors.indigo)),
                        IconButton(
                            onPressed: () {
                              _deleteData(_allData[index]['id']);
                            },
                            icon: Icon(Icons.delete, color: Colors.indigo))
                      ]),
                    ),
                  )),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => showBottomSheet(null)),
        child: Icon(Icons.add),
      ),
    );
  }
}
