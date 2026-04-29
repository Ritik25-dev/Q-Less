import React, { useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import io from 'socket.io-client';

// Use your laptop's IP if testing on different devices, otherwise localhost
const SOCKET_URL = 'http://localhost:5000';
const socket = io(SOCKET_URL);

const AdminDashboard = () => {
  const queryClient = useQueryClient();

  // 1. Fetch Active Orders using TanStack Query
  const { data: orders = [], isLoading } = useQuery({
    queryKey: ['activeOrders'],
    queryFn: async () => {
      const response = await fetch(`${SOCKET_URL}/api/orders/active`);
      if (!response.ok) throw new Error('Failed to fetch orders');
      return response.json();
    },
  });

  // 2. Mutation to update order status
  const mutation = useMutation({
    mutationFn: async ({ id, status }) => {
      const response = await fetch(`${SOCKET_URL}/api/orders/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      return response.json();
    },
    onSuccess: () => {
      // Refresh the list immediately after a change
      queryClient.invalidateQueries(['activeOrders']);
    },
  });

  // 3. Listen for Real-time Socket updates
  useEffect(() => {
    socket.on('new_order', (newOrder) => {
      // Play a notification sound
      const audio = new Audio('https://assets.mixkit.co/active_storage/sfx/2358/2358-preview.mp3');
      audio.play().catch(e => console.log("Audio play blocked by browser"));
      
      // Update the cache instantly without a full page refresh
      queryClient.setQueryData(['activeOrders'], (old) => [newOrder, ...old]);
    });

    return () => socket.off('new_order');
  }, [queryClient]);

  if (isLoading) return <div className="flex justify-center p-20 font-bold">Loading Kitchen Queue...</div>;

  return (
    <div className="min-h-screen bg-gray-50 p-4 md:p-8 font-sans">
      <div className="max-w-6xl mx-auto">
        <header className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-black text-gray-800">Canteen Kitchen</h1>
            <p className="text-gray-500 font-medium">Manage incoming student orders</p>
          </div>
          <div className="bg-white px-6 py-3 rounded-2xl shadow-sm border border-gray-200">
            <span className="text-sm uppercase tracking-wider font-bold text-gray-400">Live Queue</span>
            <div className="text-2xl font-black text-orange-500">{orders.length}</div>
          </div>
        </header>

        {/* Orders Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {orders.map((order) => (
            <OrderCard key={order._id} order={order} onUpdate={mutation.mutate} />
          ))}
        </div>

        {orders.length === 0 && (
          <div className="text-center p-20 bg-white rounded-3xl border-2 border-dashed border-gray-200">
            <p className="text-gray-400 font-medium">No active orders. Canteen is quiet!</p>
          </div>
        )}
      </div>
    </div>
  );
};


const OrderCard = ({ order, onUpdate }) => {
  const statusColors = {
    pending: 'border-orange-500 bg-orange-50 text-orange-700',
    preparing: 'border-blue-500 bg-blue-50 text-blue-700',
    ready: 'border-green-500 bg-green-50 text-green-700',
  };

  return (
    <div className={`bg-white rounded-3xl p-6 shadow-sm border-t-8 transition-all hover:shadow-md ${statusColors[order.status] || 'border-gray-200'}`}>
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-bold text-gray-800">{order.studentName}</h3>
          <span className="text-xs font-bold opacity-60 uppercase">{new Date(order.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
        </div>
        <div className="text-xs font-black uppercase px-2 py-1 rounded bg-white/50">{order.status}</div>
      </div>

      <div className="space-y-2 mb-6">
        {order.items.map((item, idx) => (
          <div key={idx} className="flex justify-between text-sm">
            <span className="text-gray-600 font-medium">{item.name}</span>
            <span className="font-bold text-gray-800">x{item.quantity}</span>
          </div>
        ))}
      </div>

      <div className="flex flex-col gap-2">
        {order.status === 'pending' && (
          <button 
            onClick={() => onUpdate({ id: order._id, status: 'preparing' })}
            className="w-full bg-orange-500 text-white font-bold py-3 rounded-xl hover:bg-orange-600">
            Accept Order
          </button>
        )}
        {order.status === 'preparing' && (
          <button 
            onClick={() => onUpdate({ id: order._id, status: 'ready' })}
            className="w-full bg-blue-600 text-white font-bold py-3 rounded-xl hover:bg-blue-700">
            Mark Ready
          </button>
        )}
        {order.status === 'ready' && (
          <button 
            onClick={() => onUpdate({ id: order._id, status: 'completed' })}
            className="w-full bg-gray-800 text-white font-bold py-3 rounded-xl hover:bg-black">
            Order Picked Up
          </button>
        )}
      </div>
    </div>
  );
};

export default AdminDashboard;