import mongoose from 'mongoose';

const orderSchema = new mongoose.Schema({
  orderNo:{
    type: String, 
    required
  },
  studentId:{
    type: mongoose.Schema.Types.ObjectId,
    ref:'User'
  },
  items: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FoodItem'
  }],
  status: { 
    type: String, 
    default: 'pending' 
  },
  createdAt: { type: Date, default: Date.now }
});

const Order = mongoose.model('Order', orderSchema);
export default Order;