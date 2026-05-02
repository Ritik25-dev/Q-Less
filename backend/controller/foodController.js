import FoodItem from '../models/FoodItem.js';

export const getMenu = async (req, res) => {
  try {
    const foodItems = await FoodItem.find({ isAvailable: true });
    res.status(200).json(foodItems);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching menu', error: error.message });
  }
};


