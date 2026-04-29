import express from 'express';
import Order from '../models/order.js';

const router = express.Router();

router.get('/active', async (req, res) => {
  try {
    const orders = await Order.find({ status: { $ne: 'completed' } }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(req.params.id, { status }, { new: true });
    
    const io = req.app.get('socketio');
    io.emit(`order_update_${order._id}`, order);
    
    res.json(order);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

router.post('/place', async (req, res) => {
  try {
    const newOrder = new Order(req.body);
    await newOrder.save();

    const io = req.app.get('socketio');
    
    io.emit('new_order', newOrder); 

    res.status(201).json(newOrder);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

export default router;