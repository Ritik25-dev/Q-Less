import express from 'express';
import FoodItem from '../models/FoodItem.js';
import { addItems, deleteItem, getItem } from '../controller/itemController.js';

const router = express.Router();

router.route('/addItem').post(addItems);
router.route('/getItem').get(getItem);
router.route('/deleteItem/:id').delete(deleteItem)

export default router;