import React from 'react'
import { useQuery} from '@tanstack/react-query';
import { getItem } from '../api/get.api';
import FoodCard from './FoodCard';
import './ItemView.css'
import AddFoodItem from '../AddFoodItem';
import { useState } from 'react';


const ItemView = () => {

    const {data,isPending,isError,error} = useQuery({
        queryKey:['foodItems'],
        queryFn: () => getItem(),
        staleTime: 1000 * 60 * 5 
    })
    const [showAddForm, setShowAddForm] = useState(false);

    const handleClick = () =>{
        return <AddFoodItem/>
    }

  return (
    <>
    <div className='itemContainer'>
        {data && data.map((val,idx)=>(
            <FoodCard key={idx} data={val}/>
        ))}
        <div className="addItem" onClick={()=>setShowAddForm(true)}>
            <p>+</p>
        </div>
    </div>
    {showAddForm && <AddFoodItem onClose={() => setShowAddForm(false)} />}
    </>

  )
}

export default ItemView