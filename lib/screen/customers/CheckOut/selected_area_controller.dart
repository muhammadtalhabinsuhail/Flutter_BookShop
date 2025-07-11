import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/selected_area_model.dart';

class SelectedAreaController {
  static final CollectionReference _areaCollection =
      FirebaseFirestore.instance.collection('SelectedArea');

  // Get all areas
  static Future<List<SelectedAreaModel>> getAllAreas() async {
    try {
      QuerySnapshot querySnapshot = await _areaCollection.get();
      return SelectedAreaModel.fromQuerySnapshot(querySnapshot);
    } catch (e) {
      print('Error getting areas: $e');
      return [];
    }
  }

  // Add area
  static Future<bool> addArea(SelectedAreaModel area) async {
    try {
      await _areaCollection.add(area.toMap());
      return true;
    } catch (e) {
      print('Error adding area: $e');
      return false;
    }
  }

  // Delete area
  static Future<bool> deleteArea(String areaId) async {
    try {
      await _areaCollection.doc(areaId).delete();
      return true;
    } catch (e) {
      print('Error deleting area: $e');
      return false;
    }
  }

  // Update area
  static Future<bool> updateArea(String areaId, SelectedAreaModel area) async {
    try {
      await _areaCollection.doc(areaId).update(area.toMap());
      return true;
    } catch (e) {
      print('Error updating area: $e');
      return false;
    }
  }
}