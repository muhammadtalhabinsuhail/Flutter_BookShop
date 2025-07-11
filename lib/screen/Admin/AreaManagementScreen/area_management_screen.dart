import 'package:flutter/material.dart';
import 'package:project/screen/customers/CheckOut/selected_area_controller.dart';
import 'package:project/screen/model/selected_area_model.dart';
import '../AdminDrawer.dart';

class AreaManagementScreen extends StatefulWidget {
  final int selectedIndex;
  
  const AreaManagementScreen({Key? key, this.selectedIndex = 8}) : super(key: key);

  @override
  _AreaManagementScreenState createState() => _AreaManagementScreenState();
}

class _AreaManagementScreenState extends State<AreaManagementScreen> {
  List<SelectedAreaModel> _areas = [];
  List<SelectedAreaModel> _filteredAreas = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<String> _selectedAreas = {};
  final _searchController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _isLoading = true;
    });

    _areas = await SelectedAreaController.getAllAreas();
    _filteredAreas = List.from(_areas);
    
    setState(() {
      _isLoading = false;
    });
  }

  void _filterAreas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = List.from(_areas);
      } else {
        _filteredAreas = _areas
            .where((area) => area.area.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedAreas.clear();
      }
    });
  }

  void _toggleAreaSelection(String areaId) {
    setState(() {
      if (_selectedAreas.contains(areaId)) {
        _selectedAreas.remove(areaId);
      } else {
        _selectedAreas.add(areaId);
      }
    });
  }

  Future<void> _addArea() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Area'),
        content: TextField(
          controller: _areaController,
          decoration: InputDecoration(
            labelText: 'Area Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _areaController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_areaController.text.trim().isNotEmpty) {
                SelectedAreaModel newArea = SelectedAreaModel(
                  area: _areaController.text.trim(),
                );
                
                bool success = await SelectedAreaController.addArea(newArea);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Area added successfully!')),
                  );
                  _areaController.clear();
                  Navigator.pop(context);
                  _loadAreas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add area')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _editArea(SelectedAreaModel area) async {
    _areaController.text = area.area;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Area'),
        content: TextField(
          controller: _areaController,
          decoration: InputDecoration(
            labelText: 'Area Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _areaController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_areaController.text.trim().isNotEmpty) {
                SelectedAreaModel updatedArea = SelectedAreaModel(
                  id: area.id,
                  area: _areaController.text.trim(),
                );
                
                bool success = await SelectedAreaController.updateArea(area.id!, updatedArea);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Area updated successfully!')),
                  );
                  _areaController.clear();
                  Navigator.pop(context);
                  _loadAreas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update area')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedAreas() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Areas'),
        content: Text('Are you sure you want to delete ${_selectedAreas.length} area(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              int successCount = 0;
              for (String areaId in _selectedAreas) {
                bool success = await SelectedAreaController.deleteArea(areaId);
                if (success) successCount++;
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$successCount area(s) deleted successfully')),
              );
              
              _toggleSelectionMode();
              _loadAreas();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AdminDrawer(isDarkMode: false, selectedNavIndex: widget.selectedIndex),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blue[600]))
                : _buildAreasList(),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _addArea,
              backgroundColor: Colors.blue[600],
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      title: _isSelectionMode
          ? Text('${_selectedAreas.length} selected')
          : const Text(
              'Area Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
      actions: [
        if (_isSelectionMode) ...[
          if (_selectedAreas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedAreas,
              tooltip: 'Delete Selected',
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSelectionMode,
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          if (_filteredAreas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAreas,
            tooltip: 'Refresh',
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search areas...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: _filterAreas,
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Total Areas: ${_filteredAreas.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          Spacer(),
          if (_isSelectionMode)
            Text(
              '${_selectedAreas.length} selected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAreasList() {
    if (_filteredAreas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_outlined,
              size:44,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No areas found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add delivery areas for your customers',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredAreas.length,
      itemBuilder: (context, index) {
        final area = _filteredAreas[index];
        final isSelected = _selectedAreas.contains(area.id);
        
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 2,
          child: ListTile(
            leading: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleAreaSelection(area.id!);
                    },
                    activeColor: Colors.blue[600],
                  )
                : CircleAvatar(
                   radius: 16,
                    backgroundColor: Colors.blue[600],
                    child: Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
            title: Text(
              area.area,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: _isSelectionMode
                ? null
                : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editArea(area);
                      } else if (value == 'delete') {
                        _deleteArea(area);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
            onTap: () {
              if (_isSelectionMode) {
                _toggleAreaSelection(area.id!);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleAreaSelection(area.id!);
              }
            },
            selected: isSelected,
            selectedTileColor: Colors.blue[50],
          ),
        );
      },
    );
  }

  Future<void> _deleteArea(SelectedAreaModel area) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Area'),
        content: Text('Are you sure you want to delete "${area.area}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              bool success = await SelectedAreaController.deleteArea(area.id!);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Area deleted successfully')),
                );
                _loadAreas();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete area')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}