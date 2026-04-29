import React from 'react';
import './FoodCard.css'
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

const FoodCard = ({data}) => {
  return (
    <div className='foodCard'>
      <div className="foodLeftContainer">
        <img src={data?.pic?.url} alt={data?.name} className="foodImage" />
        <div className="foodDetails">
          <span className="foodCategory">{data?.category}</span>
          <h3 className="foodName">{data?.name}</h3>
          <p className="foodPrice">₹ {data?.price}</p>
          <p className={`availability ${data?.isAvailable ? 'available' : 'unavailable'}`}>
            {data?.isAvailable ? '● In Stock' : '● Out of Stock'}
          </p>
        </div>
      </div>

      <div className="foodRightContainer">
        <EditIcon className="btn-update"/>
        <DeleteIcon className="btn-delete"/>
      </div>
    </div>
  );
};

export default FoodCard;