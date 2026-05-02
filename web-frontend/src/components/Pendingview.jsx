import React, { use, useEffect } from 'react'
import OrderCard from './OrderCard'
import './PendingView.css'
import { QueryClient, useQuery, useQueryClient } from '@tanstack/react-query';
import { io } from 'socket.io-client';
import { getOrders } from '../api/get.api';
import { toast } from 'react-toastify';
import { socket } from '../socket';

const Pendingview = () => {

    const queryClient = useQueryClient()
    const { data: orders = [], isLoading,error,isError } = useQuery({
    queryKey: ['pending'],
    queryFn: () => getOrders('Pending'),
  });

  useEffect(() => {
        socket.emit('join_admin_room');

        socket.on('new_order_placed', (data) => {

            const audio = new Audio('https://assets.mixkit.co/active_storage/sfx/2358/2358-preview.mp3');
            audio.play().catch(err => {
            console.log("Audio playback failed. Note: Browsers require a user click on the page before sound can play automatically.");
            });

            toast.info("New order received!");
            queryClient.invalidateQueries({ queryKey: ['pending'] });
        });

        socket.on('order_status_changed', () => {
            queryClient.invalidateQueries({ queryKey: ['pending'] });
        });

        return () => {
            socket.off('new_order_placed');
            socket.off('order_status_changed');
        };
    }, [queryClient]);

    useEffect(() => {
        if (isError) {
            toast.error(error.message || "Failed to load orders");
        }
    }, [error, isError]);

    if (isLoading) return <p>Loading orders...</p>;
  return (
    <div className='pendingView'>
        <h1>Pending</h1>
        {
            orders && orders.map((val,idx)=>(
                <OrderCard key={idx} data={val}/>
            ))
        }
    </div>
  )
}

export default Pendingview