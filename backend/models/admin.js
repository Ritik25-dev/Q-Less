import mongoose from "mongoose";

const adminSchema = new mongoose.Schema({
    email:{
        type:String,
        required
    },
    password:{
        type:String,
        required
    }
})

const Admin = mongoose.model('Admin',adminSchema)
export default Admin