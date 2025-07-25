import React, { useState, useEffect, createContext, useContext } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from 'firebase/auth';
import { getFirestore, collection, addDoc, query, orderBy, onSnapshot, serverTimestamp, deleteDoc, doc } from 'firebase/firestore';

const FirebaseContext = createContext(null);

const FirebaseProvider = ({ children }) => {
  const [app, setApp] = useState(null);
  const [db, setDb] = useState(null);
  const [auth, setAuth] = useState(null);
  const [userId, setUserId] = useState(null);
  const [isAuthReady, setIsAuthReady] = useState(false);

  useEffect(() => {
    try {
      const firebaseConfig = JSON.parse(typeof __firebase_config !== 'undefined' ? __firebase_config : '{}');
      const initializedApp = initializeApp(firebaseConfig);
      setApp(initializedApp);

      const firestoreDb = getFirestore(initializedApp);
      setDb(firestoreDb);
      const firebaseAuth = getAuth(initializedApp);
      setAuth(firebaseAuth);

      const initialAuthToken = typeof __initial_auth_token !== 'undefined' ? __initial_auth_token : null;

      if (initialAuthToken) {
        signInWithCustomToken(firebaseAuth, initialAuthToken)
          .catch(error => {
            console.error("Error signing in with custom token:", error);
            signInAnonymously(firebaseAuth).catch(err => console.error("Error signing in anonymously:", err));
          });
      } else {
        signInAnonymously(firebaseAuth)
          .catch(error => console.error("Error signing in anonymously:", error));
      }

      const unsubscribe = onAuthStateChanged(firebaseAuth, (user) => {
        if (user) {
          setUserId(user.uid);
        } else {
          setUserId(null);
        }
        setIsAuthReady(true);
      });

      return () => unsubscribe();
    } catch (error) {
      console.error("Failed to initialize Firebase:", error);
      setIsAuthReady(true);
    }
  }, []);

  return (
    <FirebaseContext.Provider value={{ app, db, auth, userId, isAuthReady }}>
      {children}
    </FirebaseContext.Provider>
  );
};

const useFirebase = () => useContext(FirebaseContext);

const ExpenseForm = ({ onAddExpense }) => {
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      console.log('Please enter a valid positive amount.');
      return;
    }
    if (!description.trim()) {
      console.log('Please enter a description.');
      return;
    }
    onAddExpense(parsedAmount, description.trim());
    setAmount('');
    setDescription('');
  };

  return (
    <form onSubmit={handleSubmit} className="p-4 bg-gray-800 rounded-lg shadow-lg mb-6">
      <h2 className="text-2xl font-semibold text-white mb-4">Add New Expense</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <div>
          <label htmlFor="amount" className="block text-sm font-medium text-gray-300 mb-1">Amount</label>
          <input
            type="number"
            id="amount"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="e.g., 25.50"
            className="w-full p-3 rounded-md bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            step="0.01"
            required
          />
        </div>
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-300 mb-1">Description</label>
          <input
            type="text"
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="e.g., Groceries, Dinner"
            className="w-full p-3 rounded-md bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            required
          />
        </div>
      </div>
      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-md transition duration-300 ease-in-out transform hover:scale-105 shadow-md"
      >
        Add Expense
      </button>
    </form>
  );
};

const ExpenseList = ({ expenses, onDeleteExpense, totalExpenses }) => {
  return (
    <div className="bg-gray-800 rounded-lg shadow-lg p-4">
      <div className="flex justify-between items-center mb-4 pb-2 border-b border-gray-700">
        <h2 className="text-2xl font-semibold text-white">Your Expenses</h2>
        <div className="text-lg font-bold text-blue-400">
          Total: ${totalExpenses.toFixed(2)}
        </div>
      </div>
      {expenses.length === 0 ? (
        <p className="text-gray-400 text-center py-8">No expenses recorded yet. Add one above!</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-700">
            <thead>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Description</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Date</th>
                <th className="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody className="bg-gray-800 divide-y divide-gray-700">{
              expenses.map((expense) => (
                <tr key={expense.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white">${expense.amount.toFixed(2)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white">{expense.description}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    {new Date(expense.timestamp?.toDate()).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      onClick={() => onDeleteExpense(expense.id)}
                      className="text-red-600 hover:text-red-800 transition duration-300 ease-in-out"
                      aria-label="Delete expense"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))
            }</tbody>
          </table>
        </div>
      )}
    </div>
  );
};

const ExpenseTrackerContent = () => {
  const { db, userId, isAuthReady } = useFirebase();
  const [expenses, setExpenses] = useState([]);
  const [totalExpenses, setTotalExpenses] = useState(0);

  const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';

  useEffect(() => {
    if (db && userId && isAuthReady) {
      const expensesCollectionRef = collection(db, `artifacts/${appId}/users/${userId}/expenses`);
      const q = query(expensesCollectionRef, orderBy('timestamp', 'desc'));

      const unsubscribe = onSnapshot(q, (snapshot) => {
        const expensesData = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setExpenses(expensesData);
        setTotalExpenses(expensesData.reduce((sum, expense) => sum + expense.amount, 0));
      }, (error) => {
        console.error("Error fetching expenses:", error);
      });

      return () => unsubscribe();
    }
  }, [db, userId, isAuthReady, appId]);

  const addExpense = async (amount, description) => {
    if (!db || !userId) {
      console.error("Firestore not initialized or user not authenticated.");
      console.log("Application not ready. Please try again.");
      return;
    }

    try {
      const expensesCollectionRef = collection(db, `artifacts/${appId}/users/${userId}/expenses`);
      await addDoc(expensesCollectionRef, {
        amount: amount,
        description: description,
        timestamp: serverTimestamp(),
      });
    } catch (e) {
      console.error("Error adding document: ", e);
      console.log("Failed to add expense. Please try again.");
    }
  };

  const deleteExpense = async (id) => {
    if (!db || !userId) {
      console.error("Firestore not initialized or user not authenticated.");
      console.log("Application not ready. Please try again.");
      return;
    }

    try {
      const expenseDocRef = doc(db, `artifacts/${appId}/users/${userId}/expenses`, id);
      await deleteDoc(expenseDocRef);
    } catch (e) {
      console.error("Error deleting document: ", e);
      console.log("Failed to delete expense. Please try again.");
    }
  };

  if (!isAuthReady) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-900 text-white">
        <div className="text-lg">Loading application...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-900 text-gray-100 font-sans p-4 md:p-8">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');
        body { font-family: 'Inter', sans-serif; }
      `}</style>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-4xl font-bold text-center text-blue-400 mb-8">Personal Expense Tracker</h1>
        <p className="text-center text-gray-400 mb-6">
          User ID: <span className="font-mono bg-gray-800 px-2 py-1 rounded text-sm">{userId || 'Not Authenticated'}</span>
        </p>

        <ExpenseForm onAddExpense={addExpense} />
        <ExpenseList expenses={expenses} onDeleteExpense={deleteExpense} totalExpenses={totalExpenses} />
      </div>
    </div>
  );
};

export default function App() {
  return (
    <FirebaseProvider>
      <ExpenseTrackerContent />
    </FirebaseProvider>
  );
}
