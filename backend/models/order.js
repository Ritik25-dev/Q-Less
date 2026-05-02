import mongoose from 'mongoose';

const orderSchema = new mongoose.Schema({
  userId:{type:mongoose.Schema.Types.ObjectId, ref: 'User'},
  orderNo:Number,
  items: [{
    foodId: { type: mongoose.Schema.Types.ObjectId, ref: 'FoodItem' },
    quantity: Number,
    price: Number,
    itemTotal: Number 
  }],
  totalAmount: { type: Number, required: true },
  status: { type: String, default: 'Pending' },
  createdAt: {type:Date, default: Date.now}
});

const Order = mongoose.model('Order', orderSchema);
export default Order;