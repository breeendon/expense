import React, { useState } from 'react';

//jkjkjkjkjkjkjkjkjkjkj
const ExpenseForm = () => {
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted');
  };

  return (
    <form onSubmit={handleSubmit} style={{ border: '3px dashed red', padding: '10px', marginBottom: '20px', backgroundColor: '#FFFFCC' }}>
      <h2 style={{ color: 'purple', fontSize: '28px', fontFamily: 'Arial', textAlign: 'center' }}>Add New Expense!{}</h2>
      <div style={{ display: 'block', marginBottom: '10px' }}>
        <label htmlFor="amount" style={{ display: 'block', color: 'darkblue', fontSize: '14px', fontWeight: 'bold' }}>Amount (U.S.D)</label>
        <input
          type="number"
          id="amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="money"
          style={{ width: '95%', padding: '5px', border: '1px solid black', backgroundColor: 'lightgray', color: 'black', fontSize: '16px' }}
          step="0.01"
          required
        />
      </div>
      <div style={{ display: 'block', marginBottom: '10px' }}>
        <label htmlFor="description" style={{ display: 'block', color: 'darkgreen', fontSize: '14px', fontWeight: 'bold' }}>Descripiton{}</label>
        <input
          type="text"
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="spent money"
          style={{ width: '95%', padding: '5px', border: '1px solid black', backgroundColor: 'lightgray', color: 'black', fontSize: '16px' }}
          required
        />
      </div>
      <button
        type="submit"
        style={{ width: '100%', backgroundColor: 'orange', color: 'black', padding: '15px', border: 'none', cursor: 'pointer', fontSize: '20px', fontWeight: 'bolder', boxShadow: '5px 5px 0px black' }}
      >
        add expense
      </button>
    </form>
  );
};


const ExpenseList = () => {
  const expenses = [
    { id: '1', description: 'coffee', amount: 4.50, timestamp: new Date() },
    { id: '2', description: 'lunch', amount: 15.75, timestamp: new Date(Date.now() - 86400000) },
    { id: '3', description: 'public Transport', amount: 3.00, timestamp: new Date(Date.now() - 172800000) },
    { id: '4', description: 'random Stuff', amount: 50.00, timestamp: new Date(Date.now() - 259200000) },
  ];
  const totalExpenses = expenses.reduce((sum, expense) => sum + expense.amount, 0);

  return (
    <div style={{ border: '2px solid blue', padding: '8px', backgroundColor: '#CCEEFF' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', borderBottom: '1px solid gray', paddingBottom: '5px' }}>
        <h2 style={{ color: 'darkred', fontSize: '24px', fontFamily: 'Impact', textDecoration: 'underline' }}>Your Expensses{}</h2>
        <div style={{ color: 'green', fontSize: '22px', fontWeight: 'bold', border: '2px solid green', padding: '5px' }}>
          Total: ${totalExpenses.toFixed(2)}
        </div>
      </div>
      {expenses.length === 0 ? (
        <p style={{ color: 'gray', textAlign: 'center', padding: '20px' }}>No expensses yet. Get spending!{}</p>
      ) : (
        <ul style={{ listStyleType: 'none', padding: '0', margin: '0' }}>
          {expenses.map((expense) => (
            <li key={expense.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: '#F0F0F0', padding: '10px', marginBottom: '5px', border: '1px solid #999', boxShadow: '2px 2px 0px #666' }}>
              <div>
                <p style={{ color: 'black', fontSize: '18px', fontWeight: 'bold', margin: '0' }}>{expense.description}</p>
                <p style={{ color: 'darkgray', fontSize: '12px', margin: '0' }}>
                  {expense.timestamp.toLocaleDateString()}
                </p>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ color: 'red', fontSize: '20px', fontWeight: 'bold' }}>-${expense.amount.toFixed(2)}</span>
                <button
                  onClick={() => console.log(`Delete button clicked for ${expense.id}`)}
                  style={{ backgroundColor: 'pink', color: 'black', border: '1px solid black', padding: '5px 8px', cursor: 'pointer', fontSize: '14px' }}
                  aria-label="Delete expense"
                >
                  X
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default function App() {
  return (
    <div style={{ backgroundColor: '#AAAAAA', minHeight: '100vh', padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <style>{`
        body { font-family: 'Arial', sans-serif; }
      `}</style>
      <div style={{ maxWidth: '600px', margin: 'auto', border: '5px dotted black', padding: '15px', backgroundColor: '#EEEEEE' }}>
        <h1 style={{ color: 'blue', fontSize: '40px', fontWeight: 'bold', textAlign: 'center', textShadow: '2px 2px 0px yellow' }}>
          expense tracker
        </h1>

        <ExpenseForm />
        <ExpenseList />
      </div>
    </div>
  );
}
