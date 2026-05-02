import React, { createContext, useContext } from 'react';
import { QueryClient, QueryClientProvider, useQuery } from '@tanstack/react-query';
import { createBrowserRouter, RouterProvider, Outlet, Navigate } from 'react-router-dom';
import AdminPanel from './AdminPanel';
import AdminDashboard from './AdminDashBoard';
import Login from './Login';
import { getAdmin } from './api/get.api';
import './App.css';
import { AdminRoute, SharedRoute } from './ProtectedRoute';

const queryClient = new QueryClient();


export const AuthContext = createContext();

const AppLayout = () => {
  const { data: admin, isLoading } = useQuery({
    queryKey: ['admin'],
    queryFn: getAdmin,
    retry: false,
    staleTime: 1000 * 60 * 60 * 12, 
  });

  if (isLoading) return <div className="loading">Checking Authentication...</div>;

  return (
    <AuthContext.Provider value={{ role: admin?.role , isLoading:isLoading}}>
      <Outlet />
    </AuthContext.Provider>
  );
};

const router = createBrowserRouter([
  {
    element: <AppLayout />,
    children: [
      { path: '/', element: <Login /> },
      {element:<AdminRoute/>,children:[
        { path: '/admin', element: <AdminPanel /> }
      ]},
      {element:<SharedRoute/>,children:[
        { path: '/dashboard', element: <AdminDashboard /> },
      ]}
      
    ]
  }
]);

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  );
}

export default App;