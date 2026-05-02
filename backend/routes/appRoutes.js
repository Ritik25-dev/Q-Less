import express from 'express';
import { getMenu } from '../controller/foodController.js';
import { placeOrder, getMyOrders, updateOrderStatus, getOrders } from '../controller/orderController.js';
import { protect, verifyJwt } from '../middleware/authMiddleware.js';

const router = express.Router();


router.get('/menu',protect, getMenu);


router.post('/orders',protect, placeOrder);
router.get('/orders',protect, getMyOrders);

router.get('/orders/:status',verifyJwt, getOrders);
router.post('/changeStatus',verifyJwt, updateOrderStatus); 
export default router;