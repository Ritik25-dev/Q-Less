import mongoose from 'mongoose';

const foodItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  pic:{
    url:{type:String},
    publicId:{type:String}
  },
  isAvailable: { type: Boolean, default: true },
  category: String
});

export default mongoose.model('FoodItem', foodItemSchema);