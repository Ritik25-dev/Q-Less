import React from 'react';
import './OrderCard.css';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import IconButton from '@mui/material/IconButton';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { changeStatus } from '../api/post.api';

const OrderCard = ({ data, onEdit, onDelete }) => {
 
  const statusClass = data?.status?.toLowerCase().replace(/\s+/g, '-');
  const queryClient = useQueryClient()

  const statusMutation = useMutation({
    mutationFn: (data) => changeStatus(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pending'] })
      queryClient.invalidateQueries({ queryKey: ['ready'] })
      queryClient.invalidateQueries({ queryKey: ['delivered'] })
    }
  })

  const onchangeStatus = (status,id) =>{
    const val = status == 'Pending'?'Ready':status == 'Ready'?'Delivered':null;
    if(!val) return;
    const data = {
      status:val,
      id:id
    }
    statusMutation.mutate(data)
  }

  return (
    <div className='orderCard'>
      <div className="orderHeader">
        <span className="orderNo">Order #{data?.orderNo}</span>
        <div className="actionButton" onClick={()=> onchangeStatus(data?.status,data?._id)}>
            <p className={`statusBtn ${data?.status}`}>{data?.status == 'Pending'? 'Mark Ready': data?.status=='Ready'?'Mark Delivered':null}</p>
        </div>
      </div>

      <div className="orderBody">
        <div className="foodList">
          {data?.items?.map((item, idx) => (
            <div className="foodItem" key={idx}>
              <span className="foodName">{item?.foodId?.name}</span>
              <span className="foodQty">x{item?.quantity}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="orderFooter">
        <p className="orderPrice">₹{data?.totalAmount?.toLocaleString()}</p>
        <span className={`statusBadge ${statusClass}`}>
          {data?.status}
        </span>
      </div>
    </div>
  );
};

export default OrderCard;