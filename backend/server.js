import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cors from 'cors';
import http from 'http';          
import { Server } from 'socket.io';

import authRoutes from './routes/authRoutes.js';
import appRoutes from './routes/appRoutes.js';
import itemRoutes from './routes/itemRoutes.js';
import cookieParser from 'cookie-parser';




dotenv.config();

const app = express();
const server = http.createServer(app);


const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT']
  },
  transports: ["websocket", "polling"],
});

app.use(cookieParser());

app.use((req, res, next) => {
  req.io = io;
  next();
});

app.use(cors({ origin: process.env.FRONTEND, credentials: true }));
app.use(express.json());


app.use(authRoutes);
app.use(appRoutes);
app.use(itemRoutes);


io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);

  socket.on('joinUserRoom', (userId) => {
    socket.join(userId);
  });

  socket.on('joinAdminRoom', () => {
    socket.join('admin_room');
    console.log(`Admin panel connected and joined admin_room.`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

const start = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB Successfully!');
    const port = process.env.PORT || 5000;

    
    server.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  } catch (err) {
    console.error('Server Error:', err);
  }
};

start();