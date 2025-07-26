import React, { useState, useEffect, createContext, useContext } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from 'firebase/auth';
import { getFirestore, collection, addDoc, query, orderBy, onSnapshot, serverTimestamp, deleteDoc, doc, where, Timestamp } from 'firebase/firestore';

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
  const [category, setCategory] = useState('Groceries');

  const categories = ['Groceries', 'Utilities', 'Transport', 'Entertainment', 'Dining Out', 'Shopping', 'Health', 'Education', 'Other'];

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
    onAddExpense(parsedAmount, description.trim(), category);
    setAmount('');
    setDescription('');
    setCategory('Groceries');
  };

  return (
    <form onSubmit={handleSubmit} className="p-6 bg-gray-800 rounded-xl shadow-2xl mb-8 border border-gray-700">
      <h2 className="text-3xl font-extrabold text-blue-400 mb-6 text-center">Add New Expense</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <div>
          <label htmlFor="amount" className="block text-sm font-medium text-gray-300 mb-2">Amount</label>
          <input
            type="number"
            id="amount"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="e.g., 25.50"
            className="w-full p-3 rounded-lg bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200"
            step="0.01"
            required
          />
        </div>
        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-300 mb-2">Description</label>
          <input
            type="text"
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="e.g., Groceries, Dinner"
            className="w-full p-3 rounded-lg bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200"
            required
          />
        </div>
        <div className="col-span-full">
          <label htmlFor="category" className="block text-sm font-medium text-gray-300 mb-2">Category</label>
          <select
            id="category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full p-3 rounded-lg bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 appearance-none bg-no-repeat bg-right-center pr-8"
            style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20' fill='%239CA3AF'%3E%3Cpath fill-rule='evenodd' d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z' clip-rule='evenodd'/%3E%3C/svg%3E")`, backgroundSize: '1.5rem' }}
          >
            {categories.map(cat => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>
      </div>
      <button
        type="submit"
        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition duration-300 ease-in-out transform hover:scale-105 shadow-lg text-lg"
      >
        Add Expense
      </button>
    </form>
  );
};

const ExpenseList = ({ expenses, onDeleteExpense, totalExpenses, categorySummary, onExportCsv }) => {
  return (
    <div className="bg-gray-800 rounded-xl shadow-2xl p-6 border border-gray-700">
      <div className="flex justify-between items-center mb-6 pb-4 border-b border-gray-700">
        <h2 className="text-3xl font-extrabold text-blue-400">Your Expenses</h2>
        <div className="text-xl font-bold text-green-400 bg-gray-700 px-4 py-2 rounded-lg shadow-md">
          Total: ${totalExpenses.toFixed(2)}
        </div>
      </div>

      <div className="mb-8 p-5 bg-gray-700 rounded-lg shadow-inner border border-gray-600">
        <h3 className="text-2xl font-semibold text-white mb-4">Summary by Category</h3>
        {Object.keys(categorySummary).length === 0 ? (
          <p className="text-gray-400 text-center py-4">No categorized expenses for this view.</p>
        ) : (
          <ul className="space-y-3">
            {Object.entries(categorySummary).map(([cat, sum]) => (
              <li key={cat} className="flex justify-between items-center text-gray-200 text-lg border-b border-gray-600 pb-2 last:border-b-0">
                <span className="font-medium">{cat}:</span>
                <span className="font-bold text-blue-300">${sum.toFixed(2)}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <button
        onClick={onExportCsv}
        className="mb-6 w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-4 rounded-lg transition duration-300 ease-in-out transform hover:scale-105 shadow-lg text-lg"
      >
        Export to CSV
      </button>

      {expenses.length === 0 ? (
        <p className="text-gray-400 text-center py-8 text-lg">No expenses recorded yet. Add one above!</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-gray-700 shadow-md">
          <table className="min-w-full divide-y divide-gray-700">
            <thead className="bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Amount</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Description</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Category</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Date</th>
                <th className="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody className="bg-gray-800 divide-y divide-gray-700">{
              expenses.map((expense) => (
                <tr key={expense.id} className="hover:bg-gray-700 transition duration-150">
                  <td className="px-6 py-4 whitespace-nowrap text-base text-white font-semibold">${expense.amount.toFixed(2)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-base text-gray-200">{expense.description}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-base text-blue-300 font-medium">{expense.category || 'Uncategorized'}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-base text-gray-400">
                    {new Date(expense.timestamp?.toDate()).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-base font-medium">
                    <button
                      onClick={() => onDeleteExpense(expense.id)}
                      className="text-red-500 hover:text-red-700 transition duration-300 ease-in-out p-2 rounded-full hover:bg-red-900/20"
                      aria-label="Delete expense"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm6 0a1 1 0 11-2 0v6a1 1 0 112 0V8z" clipRule="evenodd" />
                      </svg>
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
  const [categorySummary, setCategorySummary] = useState({});
  const [filterMonth, setFilterMonth] = useState('');
  const [filterYear, setFilterYear] = useState('');

  const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';

  const getMonthOptions = () => {
    const months = [];
    for (let i = 0; i < 12; i++) {
      const date = new Date(2000, i, 1);
      months.push({ value: (i + 1).toString().padStart(2, '0'), label: date.toLocaleString('default', { month: 'long' }) });
    }
    return months;
  };

  const getYearOptions = () => {
    const years = [];
    const currentYear = new Date().getFullYear();
    for (let i = currentYear - 5; i <= currentYear + 1; i++) {
      years.push(i.toString());
    }
    return years;
  };

  useEffect(() => {
    if (db && userId && isAuthReady) {
      const expensesCollectionRef = collection(db, `artifacts/${appId}/users/${userId}/expenses`);
      let q = query(expensesCollectionRef, orderBy('timestamp', 'desc'));

      if (filterYear) {
        const year = parseInt(filterYear);
        let startPeriod, endPeriod;

        if (filterMonth) {
          const month = parseInt(filterMonth) - 1;
          startPeriod = Timestamp.fromDate(new Date(year, month, 1));
          endPeriod = Timestamp.fromDate(new Date(year, month + 1, 0, 23, 59, 59, 999));
        } else {
          startPeriod = Timestamp.fromDate(new Date(year, 0, 1));
          endPeriod = Timestamp.fromDate(new Date(year, 11, 31, 23, 59, 59, 999));
        }
        q = query(q, where('timestamp', '>=', startPeriod), where('timestamp', '<=', endPeriod));
      }

      const unsubscribe = onSnapshot(q, (snapshot) => {
        const expensesData = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setExpenses(expensesData);
        setTotalExpenses(expensesData.reduce((sum, expense) => sum + expense.amount, 0));

        const summary = expensesData.reduce((acc, expense) => {
          const category = expense.category || 'Uncategorized';
          acc[category] = (acc[category] || 0) + expense.amount;
          return acc;
        }, {});
        setCategorySummary(summary);

      }, (error) => {
        console.error("Error fetching expenses:", error);
      });

      return () => unsubscribe();
    }
  }, [db, userId, isAuthReady, appId, filterMonth, filterYear]);

  const addExpense = async (amount, description, category) => {
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
        category: category,
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

  const exportToCsv = () => {
    if (expenses.length === 0) {
      console.log("No expenses to export.");
      return;
    }

    const headers = ['Amount', 'Description', 'Category', 'Date'];
    const rows = expenses.map(expense => [
      expense.amount.toFixed(2),
      `"${expense.description.replace(/"/g, '""')}"`,
      `"${(expense.category || 'Uncategorized').replace(/"/g, '""')}"`,
      new Date(expense.timestamp?.toDate()).toLocaleDateString(),
    ]);

    const csvContent = [
      headers.join(','),
      ...rows.map(e => e.join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    if (link.download !== undefined) {
      const url = URL.createObjectURL(blob);
      link.setAttribute('href', url);
      link.setAttribute('download', 'expenses.csv');
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } else {
      console.log("Your browser does not support downloading files directly.");
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

        <div className="p-6 bg-gray-800 rounded-xl shadow-2xl mb-8 border border-gray-700 flex flex-col sm:flex-row gap-6">
          <div className="flex-1">
            <label htmlFor="filterMonth" className="block text-sm font-medium text-gray-300 mb-2">Filter by Month</label>
            <select
              id="filterMonth"
              value={filterMonth}
              onChange={(e) => setFilterMonth(e.target.value)}
              className="w-full p-3 rounded-lg bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 appearance-none bg-no-repeat bg-right-center pr-8"
              style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20' fill='%239CA3AF'%3E%3Cpath fill-rule='evenodd' d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z' clip-rule='evenodd'/%3E%3C/svg%3E")`, backgroundSize: '1.5rem' }}
            >
              <option value="">All Months</option>
              {getMonthOptions().map(month => (
                <option key={month.value} value={month.value}>{month.label}</option>
              ))}
            </select>
          </div>
          <div className="flex-1">
            <label htmlFor="filterYear" className="block text-sm font-medium text-gray-300 mb-2">Filter by Year</label>
            <select
              id="filterYear"
              value={filterYear}
              onChange={(e) => setFilterYear(e.target.value)}
              className="w-full p-3 rounded-lg bg-gray-700 text-white border border-gray-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 appearance-none bg-no-repeat bg-right-center pr-8"
              style={{ backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20' fill='%239CA3AF'%3E%3Cpath fill-rule='evenodd' d='M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z' clip-rule='evenodd'/%3E%3C/svg%3E")`, backgroundSize: '1.5rem' }}
            >
              <option value="">All Years</option>
              {getYearOptions().map(year => (
                <option key={year} value={year}>{year}</option>
              ))}
            </select>
          </div>
        </div>

        <ExpenseList
          expenses={expenses}
          onDeleteExpense={deleteExpense}
          totalExpenses={totalExpenses}
          categorySummary={categorySummary}
          onExportCsv={exportToCsv}
        />
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
