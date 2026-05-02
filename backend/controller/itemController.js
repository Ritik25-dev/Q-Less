import Admin from "../models/admin.js";
import FoodItem from "../models/FoodItem.js";


export const addItems = async (req,res) => {
    try{
        const data = req.body;
        const admin = req.admin;

        const AdminRole = await Admin.findById(admin._id).role

        if(AdminRole !== 'Admin') return res.status(403).json({message:'Unauthorized Access'})

        if(!data) return res.status(400).json({message:'Add atleast one item'})

        await FoodItem.insertMany(data);
        return res.status(200).json({message:'Item added successfully'})

    }catch(err){
        return res.status(500).json({message:'Internal Server Error'})
    }
}

export const getItem  = async(req,res)=>{
    try{
        const admin = req.admin;

        const AdminRole = await Admin.findById(admin._id).role

        if(AdminRole !== 'Admin') return res.status(403).json({message:'Unauthorized Access'})

        const data = await FoodItem.find().lean();
        return res.status(200).json(data)

    }catch(err){
        res.status(500).json({message:"Internal Server Error"})
    }
}

export const deleteItem = async(req,res)=>{
    try{
        const admin = req.admin;

        const AdminRole = await Admin.findById(admin._id).role

        if(AdminRole !== 'Admin') return res.status(403).json({message:'Unauthorized Access'})
        
        const {id} = req.params;
        if(!id) return res.status(400).json({message:"Invalid item"})
        const result = await FoodItem.deleteOne({_id:id})

        if (result.deletedCount === 0) {
            return res.status(404).json({ message: "Item not found" });
        }

        res.status(200).json({message:"Item deleted successfully"})

    }catch(err){
        res.status(500).json({message:"Internal Server Error"})
    }
}