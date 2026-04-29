import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    email:{
        type:String,
        required
    },
    password:{
        type:String,
        required
    },
    name:{
        type:String,
        required
    },
    phone:{
        type:String,
        required
    },
    createdAt: { type: Date, default: Date.now }
}) 
const User = mongoose.model('User',userSchema);
export default User