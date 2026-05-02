import KitchenStatus from '../models/kitchenStatus.js';
import Order from '../models/order.js';
import User from '../models/user.js';

export const placeOrder = async (req, res) => {
  try {
    const userId = req.user._id;


    const user = await User.findById(userId);
    if (!user) return res.status(403).json({ message: 'Invalid request' });

    const { items, totalAmount, status } = req.body;
    if (!items || !totalAmount || !status) {
      return res.status(400).json({ message: 'Invalid request: Missing fields' });
    }

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);

    const kitchenStatus = await KitchenStatus.findOne({date:today});

    if (!kitchenStatus) {
      return res.status(404).json({ message: 'Kitchen status not set for today. Please contact admin.' });
    }

    if (!kitchenStatus.open) {
      return res.status(403).json({ message: 'Kitchen is currently closed.' });
    }

   
    const newOrder = new Order({
      orderNo: kitchenStatus.orderNo,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: status || 'Pending'
    });

    await newOrder.save();

    kitchenStatus.orderNo += 1;

    req.io.emit('new_order_placed', newOrder);

    await kitchenStatus.save();
    
    res.status(201).json(newOrder); 

  } catch (error) {
    console.error("Error placing order:", error);
    res.status(500).json({ error: "Failed to place order" });
  }
};


export const getMyOrders = async (req, res) => {
  try {
    const userId = req.user._id; 

    const orders = await Order.find({userId:userId})
      .sort({ createdAt: -1 })
      .populate({
        path: 'items',
        populate: {
          path: 'foodId',
          select: 'name pic'
        }
      })
      .lean();

    res.status(200).json(orders);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Failed to fetch orders from server." });
  }
};


export const updateOrderStatus = async (req, res) => {
  try {
    const { id, status } = req.body;
    
    const updatedOrder = await Order.findByIdAndUpdate(
      {_id:id}, 
      { status }, 
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: 'Order not found' });
    }

    req.io.emit('order_status_changed', updatedOrder);
    
    req.io.to(updatedOrder.userId.toString()).emit('your_order_updated', updatedOrder);

    res.status(200).json(updatedOrder);
  } catch (error) {
    console.log(error)
    res.status(500).json({ message: 'Error updating status', error: error.message });
  }
};

export const getOrders = async (req, res) => {
  try {

    const {status} = req.params;
    const startOfDay = new Date();
    startOfDay.setUTCHours(0,0,0,0)

    const endOfDay = new Date();
    endOfDay.setUTCHours(23,59,59,999)

    const orders = await Order.find({ status: status,
     createdAt: { 
        $gte: startOfDay, 
        $lte: endOfDay 
    }
    }).populate({
      path:'items',
      populate:{
        path:'foodId',
        select: 'name pic'
      }
    })
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: "Error fetching orders", error });
  }
};