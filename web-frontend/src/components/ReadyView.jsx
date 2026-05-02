import React, { useEffect } from 'react'
import OrderCard from './OrderCard'
import './PendingView.css'
import { useQuery } from '@tanstack/react-query';
import { io } from 'socket.io-client';
import { getOrders } from '../api/get.api';
import { toast } from 'react-toastify';

const ReadyView = () => {
    const { data: orders = [], isLoading,error,isError } = useQuery({
    queryKey: ['ready'],
    queryFn: () => getOrders('Ready'),
  });

  useEffect(()=>{
    if(isError){
        toast.error(error)
    }
  },[error,isError])
  return (
    <div className='pendingView'>
        <h1>Ready</h1>
        {
            orders && orders.map((val,idx)=>(
                <OrderCard key={idx} data={val}/>
            ))
        }
    </div>
  )
}

export default ReadyView