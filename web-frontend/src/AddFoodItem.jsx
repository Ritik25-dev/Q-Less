import React, { useState } from 'react';
import './AddFoodItem.css';
import { useMutation } from '@tanstack/react-query';
import { addItem } from './api/post.api';
import { toast } from 'react-toastify';
import CancelIcon from '@mui/icons-material/Cancel';

const AddFoodItem = ({onClose}) => {
  const intialData = {
    name:'',
    price:'',
    isAvailable:true,
    category:'Appetizer'
  }
  const [data,setData] = useState(intialData)

  const handleChange = (e)=>{
    const{id,value,type,checked} = e.target;
    setData((prevData) => ({
      ...prevData,
      [id]:type === 'checkbox'?checked:value
    }))
  }

  const addItemMutation = useMutation({
    mutationFn:addItem,
    onSuccess: (res)=>{
      toast.success(res.message)
      setData(intialData)
    },
    onError: (res)=>{
      toast.error(res.message)
    }
  })

  const handleSubmit = (e) =>{
    e.preventDefault()
    addItemMutation.mutate(data)
  }

  return (
    <div className="page-container">
      <div className="form-card">
        <div className="cancelBtn" onClick={onClose}>
            <CancelIcon/>
        </div>
        <div className="form-header">
          <h1>Add New Dish</h1>
          <p>Fill in the details to update your digital menu.</p>
        </div>

        <form className="food-form">
          <div className="input-group">
            <label htmlFor="name">Item Name</label>
            <input type="text" id="name" placeholder="e.g. Truffle Pasta" value={data?.name} onChange={handleChange}/>
          </div>

          <div className="row">
            <div className="input-group">
              <label htmlFor="price">Price</label>
              <input type="number" id="price" value={data?.price} onChange={handleChange}/>
            </div>

            <div className="input-group">
              <label htmlFor="category">Category</label>
              <select id="category" value={data?.category} onChange={handleChange}>
                <option value="">Select Category</option>
                <option value="appetizer">Appetizer</option>
                <option value="main">Main Course</option>
                <option value="dessert">Dessert</option>
                <option value="beverage">Beverage</option>
              </select>
            </div>
          </div>

          <div className="checkbox-group">
            <input type="checkbox" id="isAvailable" checked={data?.isAvailable} onChange={handleChange}/>
            <label htmlFor="isAvailable">Item is currently available for order</label>
          </div>

          <button type="submit" className="submit-btn" onClick={handleSubmit} disabled={addItemMutation.isPending}>
            Add to Menu
          </button>
        </form>
      </div>
    </div>
  );
};

export default AddFoodItem;