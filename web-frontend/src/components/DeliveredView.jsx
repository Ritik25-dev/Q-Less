import React, { useEffect } from 'react'
import OrderCard from './OrderCard'
import './PendingView.css'
import { useQuery } from '@tanstack/react-query';
import { io } from 'socket.io-client';
import { getOrders } from '../api/get.api';
import { toast } from 'react-toastify';

const DeliveredView = () => {
    const { data: orders = [], isLoading,error,isError } = useQuery({
    queryKey: ['delivered'],
    queryFn: () => getOrders('Delivered'),
  });

  useEffect(()=>{
    if(isError){
        toast.error(error)
    }
  },[error,isError])
  return (
    <div className='pendingView'>
        <h1>Delivered</h1>
        {
            orders && orders.map((val,idx)=>(
                <OrderCard key={idx} data={val}/>
            ))
        }
    </div>
  )
}

export default DeliveredView