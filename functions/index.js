const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.updateAdminDashboard = functions.firestore
    .document("Orders/{orderId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      // Check if 'deliveryCompleted' changed from false -> true
      if (!before.deliveryCompleted && after.deliveryCompleted) {
        const totalAmount = after.totalAmount || 0;

        const dashboardRef = db.collection("admin").doc("dashboard");

        return db.runTransaction(async (transaction) => {
          const dashboardDoc = await transaction.get(dashboardRef);

          if (!dashboardDoc.exists) {
          // If no dashboard document exists, create it
            transaction.set(dashboardRef, {
              totalOrdersDelivered: 1,
              totalEarnings: totalAmount,
            });
          } else {
          // Update existing dashboard document
            transaction.update(dashboardRef, {
              totalOrdersDelivered: admin.firestore.FieldValue.increment(1),
              totalEarnings: admin.firestore.FieldValue.increment(totalAmount),
            });
          }
        });
      }

      return null;
    });
