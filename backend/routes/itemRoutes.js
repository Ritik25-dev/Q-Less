import express from 'express';
import { addItems, deleteItem, getItem } from '../controller/itemController.js';
import KitchenStatus from '../models/kitchenStatus.js';
import { verifyJwt } from '../middleware/authMiddleware.js';

const router = express.Router();

router.post('/addItem',verifyJwt,addItems)
router.get('/getItem',verifyJwt,getItem)
router.delete('/deleteItem/:id',verifyJwt,deleteItem)


export default router;