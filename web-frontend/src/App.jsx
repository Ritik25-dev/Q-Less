import React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import AdminPanel from './AdminPanel';
import './App.css';

const queryClient = new QueryClient();

const router = createBrowserRouter([

  { path: '/',element: <AdminPanel /> }
  
]);

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  );
}

export default App;