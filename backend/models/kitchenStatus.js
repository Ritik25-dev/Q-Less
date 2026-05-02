import mongoose from 'mongoose'


const kitchenStatusSchema = new mongoose.Schema({
    date:{type:Date, default:Date.now },
    open:{type:Boolean, default:false},
    orderNo:{type:Number, default:1}
})

const KitchenStatus = mongoose.model('kitchenstatus', kitchenStatusSchema);
export default KitchenStatus;