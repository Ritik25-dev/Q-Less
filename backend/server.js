import express from 'express'
import mongoose from 'mongoose'
import dotenv from 'dotenv'
import cors from 'cors'
import itemRoutes from './routes/itemRoutes.js'

dotenv.config()

const app = express()


app.use(cors({
    origin: process.env.FRONTEND,
    credentials: true
}))

app.use(express.json())

app.use(itemRoutes);

const start = async () => {
  try{
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB Successfully!')
    const port = process.env.PORT;

    app.listen(port, ()=>{
      console.log(`Server is running on port ${port}`)
    })
  }catch(err){
    console.error('Server Error:', err)
  }
}

start();