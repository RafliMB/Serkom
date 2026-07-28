import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> createUser(String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  Future<void> addToCart(Map<String, dynamic> item) async {
    await _db.collection('users').doc(uid).collection('carts').add(item);
  }

  Stream<QuerySnapshot> getCartStream() {
    return _db.collection('users').doc(uid).collection('carts').snapshots();
  }

  Future<void> removeCartItem(String docId) async {
    await _db.collection('users').doc(uid).collection('carts').doc(docId).delete();
  }

  Future<void> updateCartQty(String docId, int newQty) async {
    if (newQty < 1) return;
    await _db.collection('users').doc(uid).collection('carts').doc(docId).update({'qty': newQty});
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    WriteBatch batch = _db.batch();

    DocumentReference orderRef = _db.collection('orders').doc(); 
    batch.set(orderRef, orderData);

    var cartDocs = await _db.collection('users').doc(uid).collection('carts').get();

    for (var doc in cartDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
  
  Future<void> toggleFavorite(int productId) async {
    var ref = _db.collection('users').doc(uid).collection('favorites').doc(productId.toString());
    var doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({'product_id': productId, 'created_at': FieldValue.serverTimestamp()});
    }
  }

  Stream<List<int>> getFavoritesStream() {
    return _db.collection('users').doc(uid).collection('favorites').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc['product_id'] as int).toList()
    );
  }
}